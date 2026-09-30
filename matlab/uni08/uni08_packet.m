function r=uni08_packet(direction,payload,snrDB,residual,rnti,prbs,slot)
% Actual NR data waveform with a supplied grant, practical DM-RS receiver.
% Known scheduling after SIB1 is a declared integration simplification.
% Carrier is a 24RB active BWP within the SIB1 51RB cell, SCS30kHz.
if nargin<7,slot=0;end
startRB=0;if direction=="DL",startRB=4;end
c=nrCarrierConfig(NSizeGrid=24,NStartGrid=startRB,SubcarrierSpacing=30,NCellID=321,NSlot=mod(slot,20),NFrame=426+floor(slot/20));
rate=308/1024;
if direction=="UL"
    p=nrPUSCHConfig(PRBSet=prbs,Modulation='QPSK',NumLayers=1,RNTI=rnti,MappingType='A',SymbolAllocation=[0 14]);
    p.DMRS.DMRSAdditionalPosition=0;
    [di,pi]=nrPUSCHIndices(c,p); dm=nrPUSCHDMRSIndices(c,p); rs=nrPUSCHDMRS(c,p);
    enc=nrULSCH(TargetCodeRate=rate);
else
    p=nrPDSCHConfig(PRBSet=prbs,Modulation='QPSK',NumLayers=1,RNTI=rnti,MappingType='A',SymbolAllocation=[2 12]);
    p.DMRS.DMRSAdditionalPosition=0;
    [di,pi]=nrPDSCHIndices(c,p); dm=nrPDSCHDMRSIndices(c,p); rs=nrPDSCHDMRS(c,p);
    enc=nrDLSCH(TargetCodeRate=rate);
end
tbs=nrTBS(p.Modulation,1,numel(prbs),pi.NREPerPRB,rate);
assert(numel(payload)<=tbs && mod(tbs,8)==0);
% Caller supplies a MAC PDU; pad with LCID63 and zero padding when space remains.
pad=tbs-numel(payload); suffix=zeros(pad,1,'int8');
if pad>=8, suffix(1:8)=int8(dec2bin(63,8)'-'0'); end
tb=[int8(payload(:));suffix]; setTransportBlock(enc,tb); cw=enc(p.Modulation,1,pi.G,0);
if direction=="UL", sym=nrPUSCH(c,p,cw); else, sym=nrPDSCH(c,p,cw); end
g=nrResourceGrid(c); g(di)=sym;g(dm)=rs; [tx,oi]=nrOFDMModulate(c,g,Windowing=0);
L=numel(tx);guard=2048;assert(abs(residual)<guard);
buf=[zeros(guard+residual,1);tx;zeros(guard-residual,1)];
nv=1/(oi.Nfft*10^(snrDB/10)); noise=sqrt(nv/2)*complex(randn(L,1),randn(L,1));
rx=buf(guard+(1:L))+noise;
rg=nrOFDMDemodulate(c,rx,CyclicPrefixFraction=.5);
[h,ne]=nrChannelEstimate(c,rg,dm,rs,CDMLengths=p.DMRS.CDMLengths);ne=max(ne,1e-9);
[rd,he]=nrExtractResources(di,rg,h);[eq,csi]=nrEqualizeMMSE(rd,he,ne);
if direction=="UL"
    llr=nrPUSCHDecode(c,p,eq,ne);if iscell(llr),llr=llr{1};end
    dec=nrULSCHDecoder(TargetCodeRate=rate,TransportBlockLength=tbs,MaximumLDPCIterationCount=25);
    [decoded,crc]=dec(llr.*repelem(csi,2),p.Modulation,1,0);
else
    llr=nrPDSCHDecode(c,p,eq,ne);llr=llr{1};
    dec=nrDLSCHDecoder(TargetCodeRate=rate,TransportBlockLength=tbs,MaximumLDPCIterationCount=25);
    [decoded,crc]=dec({llr.*repelem(csi,2)},p.Modulation,1,0);
end
if iscell(decoded),decoded=decoded{1};end
r=struct('direction',direction,'payload',decoded(1:numel(payload)), ...
    'crc',double(crc),'bitErrors',sum(decoded~=tb),'tbs',tbs,'payloadBits',numel(payload), ...
    'evm',100*sqrt(mean(abs(eq-sym).^2)/mean(abs(sym).^2)), ...
    'grid',g,'rxGrid',rg,'waveform',tx,'rx',rx,'symbols',sym,'equalized',eq, ...
    'llr',llr,'channel',h,'dmrsIndices',dm,'dataIndices',di,'noise',ne, ...
    'sampleRate',oi.SampleRate,'nfft',oi.Nfft,'residual',residual,'snrDB',snrDB,'rnti',rnti);
end
