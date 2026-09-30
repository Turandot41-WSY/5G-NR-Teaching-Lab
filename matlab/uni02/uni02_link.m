function a=uni02_link(snrDb,doppler,additional,seed,wrongIdentity)
% An ideal OFDM diagonal channel fixture; no ICI, timing or CFO acquisition.
rng(seed,'twister');
c=nrCarrierConfig('NSizeGrid',24,'SubcarrierSpacing',30,'NCellID',42);
p=nrPDSCHConfig('PRBSet',0:23,'SymbolAllocation',[0 14],'Modulation','QPSK','NumLayers',1,'NID',42,'RNTI',7);
p.DMRS.DMRSConfigurationType=1; p.DMRS.DMRSTypeAPosition=2;
p.DMRS.DMRSLength=1; p.DMRS.DMRSAdditionalPosition=additional;
p.DMRS.NumCDMGroupsWithoutData=1; p.DMRS.NIDNSCID=42;
di=nrPDSCHDMRSIndices(c,p); ds=nrPDSCHDMRS(c,p);
[dataInd,pinfo]=nrPDSCHIndices(c,p); bits=randi([0 1],pinfo.G,1);
x=nrPDSCH(c,p,bits); tx=nrResourceGrid(c); tx(dataInd)=x; tx(di)=ds;
k=(0:287).'; t=(0:13)*0.0005/14;
% Two deterministic paths; random common phase per independent trial.
phase=2*pi*rand; H=(1+0.72*exp(-1i*2*pi*k/96))*exp(1i*(phase+2*pi*doppler*t));
H=H/sqrt(1+0.72^2); nv=10^(-snrDb/10);
noise=sqrt(nv/2)*(randn(size(tx))+1i*randn(size(tx)));
rx=H.*tx+noise;
pr=p; if wrongIdentity, pr.DMRS.NIDNSCID=43; end
ref=nrPDSCHDMRS(c,pr);
[hh,nest]=nrChannelEstimate(c,rx,di,ref,'CDMLengths',[1 1]);
[eq,csi]=nrEqualizeMMSE(rx(dataInd),hh(dataInd),nest);
[llr,~]=nrPDSCHDecode(c,p,eq,nest);
bhat=llr{1}<0;
[perfect,~]=nrEqualizeMMSE(rx(dataInd),H(dataInd),nv);
[pll,~]=nrPDSCHDecode(c,p,perfect,nv);
mask=zeros(size(tx)); mask(dataInd)=1; mask(di)=2;
pp=p; pp.EnablePTRS=true; pp.PTRS.TimeDensity=1; pp.PTRS.FrequencyDensity=2;
pti=nrPDSCHPTRSIndices(c,pp); pt=nrPDSCHPTRS(c,pp);
a=struct('snrDb',snrDb,'doppler',doppler,'additional',additional,'seed',seed,'wrongIdentity',wrongIdentity,...
 'carrier',c,'pdsch',p,'tx',tx,'rx',rx,'H',H,'Hhat',hh,'mask',mask,'dataIndices',dataInd,'dmrsIndices',di,'dmrs',ds,...
 'x',x,'eq',eq,'perfect',perfect,'csi',csi,'llr',llr{1},'bits',bits,'bhat',bhat,'nData',numel(dataInd),'nDMRS',numel(di),...
 'nPTRS',numel(pti),'ptrsIndices',pti,'ptrs',pt,'noiseVariance',nv,'noiseEstimate',nest,...
 'ber',mean(bits~=bhat),'perfectBer',mean(bits~=(pll{1}<0)),...
 'evm',sqrt(mean(abs(eq-x).^2)/mean(abs(x).^2)),...
 'nmse',mean(abs(hh(:)-H(:)).^2)/mean(abs(H(:)).^2));
end
