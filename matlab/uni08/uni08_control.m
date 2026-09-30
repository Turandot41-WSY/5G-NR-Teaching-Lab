function r=uni08_control(kind,o)
% Standalone explicit control fixture; does not alter run_uni08.
% r=uni08_control("RAR"|"MSG4",struct('rnti',...,'slot',...))
% r=uni08_control("ACK",struct('slot',...,'ack',0|1))
% Optional seed, snrDB, rxRnti, absent, and fields (DCI field overrides).
% Requires external higher-layer CORESET/search-space/PUCCH configuration.
% Current Uni08 SIB1 does NOT supply that configuration. One known candidate
% is received here; no blind candidate search or monitoring-window proof.
% Sources: TS38.212 V18.8.0 7.3.1.2.1,7.3.2-7.3.4;
% TS38.211 V18.9.0 7.3.2,7.4.1.3,6.3.2.3;
% TS38.213 V18.8.0 9.2.1/Table9.2.1-1,9.2.3,10.1.
% https://www.3gpp.org/ftp/Specs/archive/38_series/38.212/38212-i80.zip
% https://www.3gpp.org/ftp/Specs/archive/38_series/38.211/38211-i90.zip
% https://www.3gpp.org/ftp/Specs/archive/38_series/38.213/38213-i80.zip
% https://www.mathworks.com/help/5g/ref/nrpdcchconfig.html
% https://www.mathworks.com/help/5g/ref/nrdcidecode.html
% https://www.mathworks.com/help/5g/ref/nrpucch0.html
if nargin<2,o=struct;end
o=defaults(o,struct('seed',80800,'snrDB',20,'slot',0,'absent',false));
old=rng;rng(o.seed,'twister');cleanup=onCleanup(@()rng(old)); %#ok<NASGU>
c=nrCarrierConfig(NSizeGrid=24,SubcarrierSpacing=30,NCellID=321, ...
    NSlot=mod(o.slot,20),NFrame=mod(426+floor(o.slot/20),1024));
if kind=="ACK",r=feedback(c,o);return;end
c.NStartGrid=4; % Recovered initial DL BWP occupies CRB4..27; UL stays0..23.
assert(any(kind==["RAR" "MSG4"]),'UNI08:ControlKind','Unknown control kind.');
assert(isfield(o,'rnti'),'UNI08:MissingRNTI','Caller must supply the CRC RNTI.');
if ~isfield(o,'rxRnti'),o.rxRnti=o.rnti;end
% FR1 licensed spectrum,24RB CORESET0 width, no SFN/repetition extensions.
if kind=="RAR"
    names={'riv','td','vrb','mcs','scaling','reserved'}; widths=[9 4 1 5 2 16];
    v=struct('riv',264,'td',0,'vrb',0,'mcs',4,'scaling',0,'reserved',0);
else
    names={'format','riv','td','vrb','mcs','ndi','rv','harq','dai','tpc','pri','feedback'};
    widths=[1 9 4 1 5 1 2 4 2 2 3 3];
    v=struct('format',1,'riv',264,'td',0,'vrb',0,'mcs',4,'ndi',1,'rv',0, ...
        'harq',0,'dai',0,'tpc',1,'pri',0,'feedback',4);
end
if isfield(o,'fields'),v=defaults(o.fields,v);end
if kind=="MSG4"
    assert(v.format==1 && v.dai==0,'UNI08:UnsupportedExtension', ...
        'DL format bit must be1 and reserved DAI must be0 in this fixture.');
else
    assert(v.reserved==0,'UNI08:ReservedBits','Reserved bits must be0.');
end
bits=zeros(sum(widths),1,'int8');offset=0;
for k=1:numel(names)
    val=v.(names{k});assert(val>=0 && val<2^widths(k) && val==fix(val));
    bits(offset+(1:widths(k)))=int8(dec2bin(val,widths(k))'-'0');offset=offset+widths(k);
end
% Explicit fixture: two OFDM symbols,24PRBs, eight CCEs, first AL4 candidate.
cs=nrCORESETConfig(CORESETID=0,FrequencyResources=ones(1,4),Duration=2, ...
    CCEREGMapping='interleaved',REGBundleSize=6,InterleaverSize=2,ShiftIndex=c.NCellID);
ss=nrSearchSpaceConfig(SearchSpaceID=1,CORESETID=0,SearchSpaceType='common', ...
    SlotPeriodAndOffset=[1 0],Duration=1,StartSymbolWithinSlot=0,NumCandidates=[0 0 2 1 0]);
p=nrPDCCHConfig(NSizeBWP=24,NStartBWP=4,CORESET=cs,SearchSpace=ss, ...
    RNTI=0,DMRSScramblingID=[],AggregationLevel=4,AllocatedCandidate=1);
[di,rs,dm]=nrPDCCHResources(c,p);
cw=nrDCIEncode(bits,o.rnti,2*numel(di));sym=nrPDCCH(cw,c.NCellID,0);
g=nrResourceGrid(c);g(di)=sym;g(dm)=rs;
[tx,rx,rg,nv,oi]=channel(c,g,o);
[h,ne]=nrChannelEstimate(c,rg,dm,rs);ne=max(ne,1e-9);
[y,he]=nrExtractResources(di,rg,h);[eq,csi]=nrEqualizeMMSE(y,he,ne);
llr=nrPDCCHDecode(eq,c.NCellID,0,ne).*repelem(csi,2);
[decoded,mask]=nrDCIDecode(llr,numel(bits),8,o.rxRnti);
fields=struct;offset=0;
for k=1:numel(names)
    fields.(names{k})=double(decoded(offset+(1:widths(k))))'*2.^(widths(k)-1:-1:0)';
    offset=offset+widths(k);
end
% Exhaustive type1 RIV inversion avoids the long-allocation branch ambiguity.
prbs=[];
for start=0:23
 for len=1:24-start
  if len-1<=12,riv=24*(len-1)+start;else,riv=24*(24-len+1)+23-start;end
  if riv==fields.riv,prbs=start+(0:len-1);end
 end
end
r=struct('kind',kind,'txBits',bits,'rxBits',decoded,'crc',double(mask), ...
 'fields',fields,'fieldNames',{names},'fieldWidths',widths,'prbs',prbs, ...
 'crcRNTI',o.rnti,'rxCRCIdentity',o.rxRnti,'symbolScramblingRNTI',0, ...
 'grid',g,'rxGrid',rg,'waveform',tx,'rxWaveform',rx,'symbols',sym,'equalized',eq, ...
 'llr',llr,'noiseVarianceTime',nv,'noiseEstimateGrid',ne,'channelEstimate',h, ...
 'carrier',c,'pdcch',p,'dataIndices',di,'dmrsIndices',dm,'sampleRate',oi.SampleRate, ...
 'seed',o.seed,'snrDB',o.snrDB,'slot',o.slot,'firstCCE',0,'nCCE',8, ...
 'boundary','Explicit control configuration; one known candidate; no SIB-derived search space');
if kind=="MSG4",r.feedbackSlot=o.slot+fields.feedback+1;end
end

function r=feedback(c,o)
% Explicit pucch-ResourceCommon0, firstCCE0,NCCE8,PRI0 -> rPUCCH0.
% Table9.2.1-1: format0,symbols12..13,PRBoffset0,initialCSset{0,3}.
% Resource0 chooses CS0,firsthopPRB0,secondhopPRB23 in24RB UL BWP.
o=defaults(o,struct('ack',1));assert(any(o.ack==[0 1]));
p=nrPUCCH0Config(NSizeBWP=24,NStartBWP=0,SymbolAllocation=[12 2], ...
    PRBSet=0,FrequencyHopping='intraSlot',SecondHopStartPRB=23, ...
    GroupHopping='neither',HoppingID=c.NCellID,InitialCyclicShift=0);
di=nrPUCCHIndices(c,p);sym=nrPUCCH(c,p,int8(o.ack));
g=nrResourceGrid(c);g(di)=sym;
[tx,rx,rg,nv,oi]=channel(c,g,o);
y=nrExtractResources(di,rg);
[b,~,metric]=nrPUCCHDecode(c,p,[1 0],y,1/10^(o.snrDB/10));
if iscell(b),b=b{1};end
detected=~isempty(b) && all(b>=0);rxACK=NaN;if detected,rxACK=double(b(1));end
r=struct('kind',"ACK",'txACK',o.ack,'rxACK',rxACK,'detected',detected, ...
 'metric',metric,'grid',g,'rxGrid',rg,'waveform',tx,'rxWaveform',rx, ...
 'symbols',sym,'receivedSymbols',y,'indices',di,'carrier',c,'pucch',p, ...
 'slot',o.slot,'seed',o.seed,'snrDB',o.snrDB,'absent',o.absent, ...
 'sampleRate',oi.SampleRate,'noiseVarianceTime',nv,'resourceCommon',0,'rPUCCH',0, ...
 'boundary','Explicit common resource0; aligned AWGN; no SIB-derived PUCCH configuration');
end

function [tx,rx,rg,nv,oi]=channel(c,g,o)
[tx,oi]=nrOFDMModulate(c,g,Windowing=0);nv=1/(oi.Nfft*10^(o.snrDB/10));
rx=tx;if o.absent,rx(:)=0;end
rx=rx+sqrt(nv/2)*complex(randn(size(rx)),randn(size(rx)));
rg=nrOFDMDemodulate(c,rx,CyclicPrefixFraction=.5);
end

function a=defaults(a,b)
for f=string(fieldnames(b))',if ~isfield(a,f),a.(f)=b.(f);end,end
end
