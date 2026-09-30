function m=uni07_student_measure(c)
% Actual old/current CSI-RS observations, extracted from run_uni07.
validateattributes(c.RB,{'numeric'},{'scalar','integer','>=',4,'<=',24});
validateattributes(c.snrDb,{'numeric'},{'scalar','finite'});
validateattributes(c.rho,{'numeric'},{'scalar','>=',0,'<=',1});
validateattributes(c.delaySlots,{'numeric'},{'scalar','integer','nonnegative'});
rng(c.seed,'twister');
carrier=nrCarrierConfig(NSizeGrid=c.RB,SubcarrierSpacing=30,NCellID=7);
csirs=nrCSIRSConfig(NumRB=c.RB,RowNumber=3,SymbolLocations=6,SubcarrierLocations=0,Density='one');
ci=nrCSIRSIndices(carrier,csirs); cs=nrCSIRS(carrier,csirs);
cg=nrResourceGrid(carrier,2); cg(ci)=cs;
[ct,oi]=nrOFDMModulate(carrier,cg,Windowing=0);
H0=complex(randn(2),randn(2))/sqrt(2);
H=c.rho^c.delaySlots*H0+sqrt(1-c.rho^(2*c.delaySlots))*complex(randn(2),randn(2))/sqrt(2);
nv=1/(oi.Nfft*10^(c.snrDb/10));
y=ct*H.'+sqrt(nv/2)*complex(randn(size(ct)),randn(size(ct)));
yg=nrOFDMDemodulate(carrier,y);
[hh,nn]=nrChannelEstimate(carrier,yg,ci,cs,CDMLengths=[2 1]);
Hm=squeeze(mean(mean(hh,1),2));
y0=ct*H0.'+sqrt(nv/2)*complex(randn(size(ct)),randn(size(ct)));
yg0=nrOFDMDemodulate(carrier,y0);
[hh0,~]=nrChannelEstimate(carrier,yg0,ci,cs,CDMLengths=[2 1]);
Hold=squeeze(mean(mean(hh0,1),2));
W=uni07_codebook;
[~,pmi]=max(sum(abs(Hm*W).^2,1)); [~,oldpmi]=max(sum(abs(Hold*W).^2,1));
m=struct('config',c,'carrier',carrier,'csirs',csirs,'grid',cg,'tx',ct, ...
    'rxgrid',yg,'hgrid',hh,'H',H,'H0',H0,'Hm',Hm,'Hold',Hold,'W',W, ...
    'pmi',pmi,'oldpmi',oldpmi,'nmse',norm(Hm-H,'fro')^2/norm(H,'fro')^2, ...
    'sampleNoiseVariance',nv,'estimatedNoise',nn,'Nfft',oi.Nfft,'sampleRate',oi.SampleRate);
end
