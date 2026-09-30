function t=uni03_tx
% Actual SSB/PDCCH/PDSCH waveform; local UPER SIB1 occupies the DL-SCH TB.
uni03_setup; rng(63003,'twister');
c=uni01_config; c.captureResourceBlocks=28;
s=uni01_tx(c); a=c.receiver; a.sampleRate=s.sampleRate;
t.mib=uni01_rx(s.waveform,a); assert(~t.mib.crcError);
q=uni03_table(t.mib);
info=struct('SubcarrierSpacingCommon',30,'k_SSB',0,'NFrame',426, ...
 'DMRSTypeAPosition',2,'PDCCHConfigSIB1',struct('controlResourceSetZero',0,'searchSpaceZero',0));
[p,pat]=hPDCCH0Configuration(0,info,[30 30],321,10);
carrier=nrCarrierConfig('NCellID',321,'NSizeGrid',24,'SubcarrierSpacing',30,'NSlot',1,'NFrame',426);
dci=DCIFormat1_0_SIRNTI(24); dci.FrequencyDomainResources=168;
dci.TimeDomainResources=0; dci.ModulationCoding=4;
dciBits=toBits(dci); p.AggregationLevel=4; p.AllocatedCandidate=2;
g=nrResourceGrid(carrier);
[pi,ps,pdi]=nrPDCCHResources(carrier,p);
dcicw=nrDCIEncode(dciBits,65535,numel(pi)*2);
g(pi)=nrPDCCH(dcicw,p.DMRSScramblingID,p.RNTI); g(pdi)=ps;
[pdsch,k0]=hSIB1PDSCHConfiguration(dci,24,2,pat); assert(k0==0);
[di,diInfo]=nrPDSCHIndices(carrier,pdsch);
tcr=308/1024;
tbs=nrTBS(pdsch.Modulation,1,8,diInfo.NREPerPRB,tcr,0);
fixture=jsondecode(fileread(fullfile(fileparts(mfilename('fullpath')),'sib1-fixture.json')));
tb=int8([fixture.bits(:);zeros(tbs-numel(fixture.bits),1)]);
enc=nrDLSCH('TargetCodeRate',tcr); setTransportBlock(enc,tb);
cw=enc(pdsch.Modulation,1,diInfo.G,0);
g(di)=nrPDSCH(carrier,pdsch,cw);
dm=nrPDSCHDMRSIndices(carrier,pdsch); g(dm)=nrPDSCHDMRS(carrier,pdsch);
grid=[s.grid zeros(336,14)]; rows=49:336;
grid(rows,15:28)=g;
cap=nrCarrierConfig('NCellID',321,'NSizeGrid',28,'SubcarrierSpacing',30,'NFrame',426);
[wave,oi]=nrOFDMModulate(cap,grid,'Windowing',0);
t.grid=grid;t.waveform=wave;t.sampleRate=oi.SampleRate;t.carrier=carrier;
t.transportBits=tb;t.sib1BitLength=numel(fixture.bits);t.dciBits=dciBits;t.dci=dci;
t.pdcch=p;t.pdsch=pdsch;t.pdschIndices=di;t.pdcchIndices=pi;t.pdschDMRSIndices=dm;
t.codedBits=cw;t.targetCodeRate=tcr;t.config=c;t.table=q;t.ofdmInfo=oi;
end
