function r=uni07_student_trial(c,m,mode)
% One actual LDPC/PDSCH trial from run_uni07, using the supplied CSI capture.
validateattributes(mode,{'numeric'},{'scalar','integer','>=',1,'<=',5});
validateattributes(c.rate,{'numeric'},{'scalar','>',0,'<',1});
assert(isequal(c,m.config),'Uni07:StaleCSI','Regenerate CSI after changing the configuration.');
rng(c.seed+100,'twister'); % Reset for reproducible comparisons of modes.
modes=["Ideal SVD" "Measured SVD" "Current PMI" "Delayed PMI" "Adaptive rank"];
nl=1;
switch mode
    case 1
        [~,~,V]=svd(m.H); w=V(:,1); % Only precoding uses channel truth.
    case 2
        [~,~,V]=svd(m.Hm); w=V(:,1);
    case 3
        w=m.W(:,m.pmi);
    case 4
        w=m.W(:,m.oldpmi); % Only PMI is delayed; quality below is current.
    otherwise
        w=m.W(:,m.pmi);
        if min(svd(m.Hm))^2*10^(c.snrDb/10)/2>c.rankThreshold
            nl=2; w=[1 1;1 -1]/2;
        end
end
predictedDb=10*log10(sum(abs(m.Hm*w).^2,'all')/nl)+c.snrDb;
modulation='QPSK'; qm=2;
if predictedDb>c.modulationThresholdDb,modulation='16QAM';qm=4;end
carrier=m.carrier;
pdsch=nrPDSCHConfig(PRBSet=0:c.RB-1,Modulation=modulation,NumLayers=nl,RNTI=7);
pdsch.DMRS.DMRSAdditionalPosition=2;
[ix,info]=nrPDSCHIndices(carrier,pdsch);
dx=nrPDSCHDMRSIndices(carrier,pdsch); ds=nrPDSCHDMRS(carrier,pdsch);
tbs=nrTBS(modulation,nl,c.RB,info.NREPerPRB,c.rate);
bits=randi([0 1],tbs,1,'int8'); enc=nrDLSCH(TargetCodeRate=c.rate); setTransportBlock(enc,bits);
cw=enc(modulation,nl,info.G,0); symbols=nrPDSCH(carrier,pdsch,cw);
lg=nrResourceGrid(carrier,nl); lg(ix)=symbols; lg(dx)=ds;
grid=reshape(reshape(lg,[],nl)*w.',12*c.RB,14,2);
tx=nrOFDMModulate(carrier,grid,Windowing=0);
nv=m.sampleNoiseVariance;
rx=tx*m.H.'+sqrt(nv/2)*complex(randn(size(tx)),randn(size(tx)));
rxgrid=nrOFDMDemodulate(carrier,rx);
[hest,nest]=nrChannelEstimate(carrier,rxgrid,dx,ds,CDMLengths=pdsch.DMRS.CDMLengths);
nest=max(nest,1e-9); [rd,hd]=nrExtractResources(ix,rxgrid,hest);
[eq,csi]=nrEqualizeMMSE(rd,hd,nest);
llr=nrPDSCHDecode(carrier,pdsch,eq,nest); if ~iscell(llr),llr={llr};end
csil=nrLayerDemap(csi); llr{1}=llr{1}.*repelem(csil{1},qm);
dec=nrDLSCHDecoder(TargetCodeRate=c.rate,TransportBlockLength=tbs,MaximumLDPCIterationCount=12);
[decoded,crc]=dec(llr,modulation,nl,0); if iscell(decoded),decoded=decoded{1};end
r=struct('mode',modes(mode),'rank',nl,'modulation',modulation,'qm',qm,'w',w, ...
    'predictedDb',predictedDb,'gain',sum(abs(m.H*w).^2,'all'),'pdsch',pdsch, ...
    'grid',grid,'tx',tx,'rx',rx,'hest',hest,'estimatedNoise',nest,'eq',eq, ...
    'symbols',symbols,'bits',bits,'decoded',decoded,'tbs',tbs,'crc',logical(crc), ...
    'bitErrors',sum(decoded~=bits),'evmPercent',100*sqrt(mean(abs(eq(:)-symbols(:)).^2)), ...
    'deliveredBits',tbs*(1-double(crc)));
assert(abs(sum(abs(w).^2,'all')-1)<1e-10,'Uni07:Power','Precoder total power must equal one.');
end
