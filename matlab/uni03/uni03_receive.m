function r=uni03_receive(m,grid,opt)
% Consume recovered Uni01 MIB and synchronized 28RB capture grid.
% Receiver has no transmitted bits or candidate index. Grid origin=frame slot0.
if nargin<3,opt=struct;end
uni03_setup;
q=uni03_table(m); si=65535; shift=0; slots=q.monitorSlots; mcsOverride=[];
if isfield(opt,'siRNTI'),si=opt.siRNTI;end
if isfield(opt,'offsetRB'),shift=opt.offsetRB;end
if isfield(opt,'slots'),slots=opt.slots;end
if isfield(opt,'mcs'),mcsOverride=opt.mcs;end
r=struct('dciCRC',true,'transportCRC',true,'transportBits',int8([]),'candidateTrace',[], ...
 'table',q,'dciBits',[],'dci',struct,'acceptedSlot',NaN);
if ~q.isMonitoringFrame,return;end
info=struct('SubcarrierSpacingCommon',m.subcarrierSpacingCommon,'k_SSB',m.kSsb, ...
 'NFrame',m.systemFrameNumber,'DMRSTypeAPosition',m.dmrsTypeAPosition, ...
 'PDCCHConfigSIB1',struct('controlResourceSetZero',q.index,'searchSpaceZero',q.searchSpaceZero));
[p,pat]=hPDCCH0Configuration(m.ssbIndex,info,[30 30],m.cellID,10);
carrier=nrCarrierConfig('NCellID',m.cellID,'NSizeGrid',q.nrb,'SubcarrierSpacing',30,'NFrame',m.systemFrameNumber);
dci=DCIFormat1_0_SIRNTI(q.nrb);
first=49-12*q.offsetRB+12*shift; rows=first:first+q.nrb*12-1;
if min(rows)<1 || max(rows)>size(grid,1),return;end
for sl=slots
 if 14*(sl+1)>size(grid,2),continue;end
 carrier.NSlot=sl; g=grid(rows,sl*14+(1:14));
 [inds,rs,ri]=nrPDCCHSpace(carrier,p);
 for al=3:4
  for ci=1:size(inds{al},2)
   [h,nv]=nrChannelEstimate(g,ri{al}(:,ci),rs{al}(:,ci));nv=max(nv,1e-9);
   [rx,he]=nrExtractResources(inds{al}(:,ci),g,h);
   eq=nrEqualizeMMSE(rx,he,nv); llr=nrPDCCHDecode(eq,p.DMRSScramblingID,0,nv);
   [b,crc]=nrDCIDecode(llr,dci.Width,8,si);
   r.candidateTrace(end+1,:)=[sl 2^(al-1) ci double(crc) mean(abs(eq).^2)];
   if crc==0
    r.dciCRC=false;r.dciBits=b;r.acceptedSlot=sl;r.pdcchEqualized=eq;r.pdcchLLR=llr;
    r.aggregationLevel=2^(al-1);r.candidate=ci;break;
   end
  end
  if ~r.dciCRC,break;end
 end
 if ~r.dciCRC,break;end
end
if r.dciCRC,return;end
dci=fromBits(dci,r.dciBits);
if ~isempty(mcsOverride),dci.ModulationCoding=mcsOverride;end
r.dci=struct('frequencyRIV',dci.FrequencyDomainResources,'timeDomain',dci.TimeDomainResources, ...
 'mcs',dci.ModulationCoding,'rv',dci.RedundancyVersion,'systemInformationIndicator',dci.SystemInformationIndicator);
[pdsch,k0]=hSIB1PDSCHConfiguration(dci,q.nrb,m.dmrsTypeAPosition,pat);
carrier.NSlot=sl+k0;g=grid(rows,(sl+k0)*14+(1:14));
dm=nrPDSCHDMRSIndices(carrier,pdsch);rs=nrPDSCHDMRS(carrier,pdsch);
[h,nv]=nrChannelEstimate(g,dm,rs);nv=max(nv,1e-9);
[di,diInfo]=nrPDSCHIndices(carrier,pdsch);[rx,he]=nrExtractResources(di,g,h);
[eq,csi]=nrEqualizeMMSE(rx,he,nv);cw=nrPDSCHDecode(carrier,pdsch,eq,nv);
cw{1}=cw{1}.*repelem(csi,2);
mt=nrPDSCHMCSTables;tcr=mt.QAM64Table.TargetCodeRate(mt.QAM64Table.MCSIndex==dci.ModulationCoding);
tbs=nrTBS(pdsch.Modulation,1,numel(pdsch.PRBSet),diInfo.NREPerPRB,tcr,0);
dec=nrDLSCHDecoder('TransportBlockLength',tbs,'TargetCodeRate',tcr,'MaximumLDPCIterationCount',25);
[bits,crc]=dec(cw,pdsch.Modulation,1,dci.RedundancyVersion);
r.transportBits=bits;r.transportCRC=crc;r.pdschEqualized=eq;r.pdschReceived=rx;
r.pdschLLR=cw{1};r.channelEstimate=h;r.noiseVariance=nv;r.pdsch=pdsch;
r.targetCodeRate=tcr;r.transportBlockLength=tbs;r.pdschIndices=di;r.rows=rows;
end
