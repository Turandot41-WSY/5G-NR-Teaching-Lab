function r=uni06_student_trial(c)
% One actual PUSCH trial, extracted from run_uni06; no teacher output writes.
validateattributes(c.RB,{'numeric'},{'scalar','integer','>=',1,'<=',24});
validateattributes(c.lossdB,{'numeric'},{'scalar','finite','nonnegative'});
validateattributes(c.alpha,{'numeric'},{'scalar','>=',0,'<=',1});
validateattributes(c.rate,{'numeric'},{'scalar','>',0,'<',1});
assert(c.mu==1,'Uni06:Numerology','This lab uses mu=1 and 30 kHz spacing.');
rng(c.seed,'twister');
carrier=nrCarrierConfig(NSizeGrid=24,SubcarrierSpacing=30,NCellID=7);
pusch=nrPUSCHConfig(PRBSet=0:c.RB-1,Modulation='QPSK',NumLayers=1,RNTI=7);
pusch.DMRS.DMRSAdditionalPosition=2;
[ix,info]=nrPUSCHIndices(carrier,pusch);
dx=nrPUSCHDMRSIndices(carrier,pusch); ds=nrPUSCHDMRS(carrier,pusch);
tbs=nrTBS('QPSK',1,c.RB,info.NREPerPRB,c.rate);
bandwidthHz=c.RB*12*30e3;
noiseDbm=-174+10*log10(bandwidthHz)+c.noiseFiguredB;
[powerDbm,commandDbm]=uni06_power(c.lossdB,c.alpha,c.RB,c.mu,c.p0dBm,c.pmaxdBm,0,0);
snrDb=powerDbm-c.lossdB-noiseDbm;
bits=randi([0 1],tbs,1,'int8');
enc=nrULSCH(TargetCodeRate=c.rate); setTransportBlock(enc,bits);
cw=enc('QPSK',1,info.G,0); symbols=nrPUSCH(carrier,pusch,cw);
grid=nrResourceGrid(carrier); grid(ix)=symbols; grid(dx)=ds;
[tx,oi]=nrOFDMModulate(carrier,grid,Windowing=0);
% Unit RE energy; attenuation is normalized out and carried by SNR.
sampleNoiseVariance=1/(oi.Nfft*10^(snrDb/10));
rx=tx+sqrt(sampleNoiseVariance/2)*complex(randn(size(tx)),randn(size(tx)));
rxgrid=nrOFDMDemodulate(carrier,rx);
[hest,nest]=nrChannelEstimate(carrier,rxgrid,dx,ds,CDMLengths=pusch.DMRS.CDMLengths);
nest=max(nest,1e-9);
[rd,hd]=nrExtractResources(ix,rxgrid,hest);
[eq,csi]=nrEqualizeMMSE(rd,hd,nest);
llr=nrPUSCHDecode(carrier,pusch,eq,nest); if iscell(llr),llr=llr{1};end
dec=nrULSCHDecoder(TargetCodeRate=c.rate,TransportBlockLength=tbs,MaximumLDPCIterationCount=12);
[decoded,crc]=dec(llr.*repelem(csi,2),'QPSK',1,0);
if iscell(decoded),decoded=decoded{1};end
r=struct('config',c,'carrier',carrier,'pusch',pusch,'grid',grid,'tx',tx,'rx',rx, ...
    'hest',hest,'symbols',symbols,'eq',eq,'bits',bits,'decoded',decoded, ...
    'crc',logical(crc),'bitErrors',sum(decoded~=bits),'tbs',tbs, ...
    'evmPercent',100*sqrt(mean(abs(eq-symbols).^2)), ...
    'bandwidthHz',bandwidthHz,'noiseDbm',noiseDbm,'powerDbm',powerDbm, ...
    'commandDbm',commandDbm,'snrDb',snrDb,'sampleNoiseVariance',sampleNoiseVariance, ...
    'estimatedNoise',nest,'Nfft',oi.Nfft,'sampleRate',oi.SampleRate);
assert(r.powerDbm<=c.pmaxdBm+1e-10,'Uni06:Power','Power exceeds the configured cap.');
end
