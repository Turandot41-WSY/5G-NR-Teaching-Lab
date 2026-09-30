function run_uni07
root=fileparts(mfilename('fullpath'));out=fullfile(root,'results');if ~isfolder(out),mkdir(out);end
figdir=fullfile(root,'..','..','notes','99 Attachments','5G','Uni Labs','Uni-07');if ~isfolder(figdir),mkdir(figdir);end
diary(fullfile(out,'run.log'));cleanup=onCleanup(@()diary('off'));disp(version);ver;
cfg=struct('seed',7007,'SNRdB',[-5 0 5 10 15 20],'nTrials',24,'rho',0.9,'delaySlots',4,'rate',0.48,'RB',6);
rng(cfg.seed,'twister');carrier=nrCarrierConfig(NSizeGrid=6,SubcarrierSpacing=30,NCellID=7);
csirs=nrCSIRSConfig(NumRB=6,RowNumber=3,SymbolLocations=6,SubcarrierLocations=0,Density='one');
ci=nrCSIRSIndices(carrier,csirs);cs=nrCSIRS(carrier,csirs);cg=nrResourceGrid(carrier,2);cg(ci)=cs;
[ct,oi]=nrOFDMModulate(carrier,cg,Windowing=0);W=uni07_codebook;
modes=["Ideal SVD" "Measured SVD" "Current PMI" "Delayed PMI" "Adaptive rank"];
rows=[];reps={};
for snr=cfg.SNRdB
 for trial=1:cfg.nTrials
  H0=complex(randn(2),randn(2))/sqrt(2);H=cfg.rho^cfg.delaySlots*H0+sqrt(1-cfg.rho^(2*cfg.delaySlots))*complex(randn(2),randn(2))/sqrt(2);
  nv=1/(oi.Nfft*10^(snr/10));
  y=ct*H.'+sqrt(nv/2)*complex(randn(size(ct)),randn(size(ct)));yg=nrOFDMDemodulate(carrier,y);
  [hh,nn]=nrChannelEstimate(carrier,yg,ci,cs,CDMLengths=[2 1]);Hm=squeeze(mean(mean(hh,1),2));
  y0=ct*H0.'+sqrt(nv/2)*complex(randn(size(ct)),randn(size(ct)));yg0=nrOFDMDemodulate(carrier,y0);
  [hh0,~]=nrChannelEstimate(carrier,yg0,ci,cs,CDMLengths=[2 1]);Hold=squeeze(mean(mean(hh0,1),2));
  [~,~,V]=svd(H);[~,~,Vm]=svd(Hm);[~,pmi]=max(sum(abs(Hm*W).^2,1));[~,oldpmi]=max(sum(abs(Hold*W).^2,1));
  nmse=norm(Hm-H,'fro')^2/norm(H,'fro')^2;
  for mode=1:numel(modes)
   nl=1;switch mode,case 1,w=V(:,1);case 2,w=Vm(:,1);case 3,w=W(:,pmi);case 4,w=W(:,oldpmi);otherwise,w=W(:,pmi);if min(svd(Hm))^2*10^(snr/10)/2>5,nl=2;w=[1 1;1 -1]/2;end;end
   predicted=10*log10(sum(abs(Hm*w).^2,'all')/nl)+snr;
   modulation='QPSK';qm=2;if predicted>12,modulation='16QAM';qm=4;end
   pdsch=nrPDSCHConfig(PRBSet=0:5,Modulation=modulation,NumLayers=nl,RNTI=7);
   pdsch.DMRS.DMRSAdditionalPosition=2;
   [ix,info]=nrPDSCHIndices(carrier,pdsch);dx=nrPDSCHDMRSIndices(carrier,pdsch);ds=nrPDSCHDMRS(carrier,pdsch);
   tbs=nrTBS(modulation,nl,6,info.NREPerPRB,cfg.rate);bits=randi([0 1],tbs,1,'int8');enc=nrDLSCH(TargetCodeRate=cfg.rate);setTransportBlock(enc,bits);
   cw=enc(modulation,nl,info.G,0);sy=nrPDSCH(carrier,pdsch,cw);lg=nrResourceGrid(carrier,nl);lg(ix)=sy;lg(dx)=ds;
   tg=reshape(reshape(lg,[],nl)*w.',72,14,2);tx=nrOFDMModulate(carrier,tg,Windowing=0);
   rx=tx*H.'+sqrt(nv/2)*complex(randn(size(tx)),randn(size(tx)));rg=nrOFDMDemodulate(carrier,rx);
   [he,ne]=nrChannelEstimate(carrier,rg,dx,ds,CDMLengths=pdsch.DMRS.CDMLengths);ne=max(ne,1e-9);
   [rd,hd]=nrExtractResources(ix,rg,he);[eq,csi]=nrEqualizeMMSE(rd,hd,ne);
   llr=nrPDSCHDecode(carrier,pdsch,eq,ne);if ~iscell(llr),llr={llr};end
   csil=nrLayerDemap(csi);llr{1}=llr{1}.*repelem(csil{1},qm);
   dec=nrDLSCHDecoder(TargetCodeRate=cfg.rate,TransportBlockLength=tbs,MaximumLDPCIterationCount=12);
   [bh,crc]=dec(llr,modulation,nl,0);if iscell(bh),bh=bh{1};end
   gain=sum(abs(H*w).^2,'all');evm=100*sqrt(mean(abs(eq(:)-sy(:)).^2));
   rows(end+1,:)=[snr trial mode nl qm pmi-1 oldpmi-1 nmse gain predicted tbs double(crc) sum(bh~=bits) evm tbs*(1-double(crc))/0.001/1e6];
   if trial==1 && ismember(snr,[0 10 20])
    reps{end+1}=struct('snr',snr,'mode',mode,'H',H,'Hm',Hm,'Hold',Hold,'CSIgrid',cg,'CSIRx',yg,'Hgrid',hh,'w',w,'txgrid',tg,'tx',tx,'rx',rx,'eq',eq,'symbols',sy,'crc',crc,'rank',nl);
   end
  end
 end
 fprintf('Completed SNR %g dB\n',snr);
end
trials=array2table(rows,VariableNames={'SNRdB','Trial','Mode','Rank','Qm','PMI','DelayedPMI','NMSE','Gain','PredictedSNRdB','TBS','CRC','BitErrors','EVMPercent','GoodputMbps'});
summary=[];for snr=cfg.SNRdB,for mode=1:numel(modes),t=trials(trials.SNRdB==snr & trials.Mode==mode,:);[lo,hi]=wilson(sum(t.CRC),height(t));summary(end+1,:)=[snr mode mean(t.CRC) lo hi mean(t.GoodputMbps) std(t.GoodputMbps)/sqrt(height(t))*2.0687 mean(t.Gain) mean(t.NMSE) mean(t.Rank) mean(t.Qm) mean(t.EVMPercent)];end;end
results=array2table(summary,VariableNames={'SNRdB','Mode','BLER','Lower95','Upper95','GoodputMbps','GoodputHalfCI95','Gain','NMSE','MeanRank','MeanQm','EVMPercent'});
matlabVersion=version;toolboxes=ver;save(fullfile(out,'run.mat'),'cfg','carrier','csirs','W','modes','trials','results','reps','matlabVersion','toolboxes');writetable(trials,fullfile(out,'trials.csv'));writetable(results,fullfile(out,'summary.csv'));
figures={};set(groot,'defaultFigureVisible','off','defaultAxesFontSize',20,'defaultTextFontSize',20);
fields={'BLER','GoodputMbps','Gain','NMSE','MeanRank','MeanQm','EVMPercent'};labels={'Transport block error fraction','Delivered payload (Mbit/s)','Effective channel power gain','Channel NMSE','Mean spatial rank','Mean modulation order (bits/symbol)','RMS EVM (%)'};
for j=1:numel(fields),f=newfig;hold on;for mode=1:numel(modes),t=results(results.Mode==mode,:);plot(t.SNRdB,t.(fields{j}),'-o',LineWidth=2);end;xlabel('Noise reference SNR (dB)');ylabel(labels{j});legend(modes,Location='best',FontSize=15);grid on;title(labels{j});keep(f,fields{j});end
f=newfig;hold on;for mode=[3 4 5],t=results(results.Mode==mode,:);errorbar(t.SNRdB,t.BLER,t.BLER-t.Lower95,t.Upper95-t.BLER,'-o',LineWidth=2);end;legend(modes([3 4 5]));xlabel('SNR (dB)');ylabel('BLER and Wilson 95% interval');grid on;keep(f,'BLER intervals');
f=newfig;hold on;for mode=[1 3 4 5],t=results(results.Mode==mode,:);errorbar(t.SNRdB,t.GoodputMbps,t.GoodputHalfCI95,'-o',LineWidth=2);end;legend(modes([1 3 4 5]));xlabel('SNR (dB)');ylabel('Payload Mbit/s and t interval');grid on;keep(f,'Throughput intervals');
for snr=[0 10 20]
 t=trials(trials.SNRdB==snr & trials.Mode==3,:);f=newfig;histogram(t.PMI,-.5:1:3.5);xlabel('Reported PMI index');ylabel('Trials');title(sprintf('PMI selections at %g dB',snr));keep(f,sprintf('PMI SNR %g',snr));
 f=newfig;imagesc(0:3,0:3,accumarray([t.DelayedPMI+1 t.PMI+1],1,[4 4]));axis xy;axis square;xticks(0:3);yticks(0:3);colorbar;xlabel('Current PMI');ylabel('Delayed PMI');title(sprintf('Feedback agreement counts at %g dB',snr));keep(f,sprintf('PMI agreement SNR %g',snr));
 f=newfig;hold on;for mode=[1 3 4],t=trials(trials.SNRdB==snr & trials.Mode==mode,:);plot(sort(t.Gain),(1:height(t))/height(t),LineWidth=2);end;legend(modes([1 3 4]));xlabel('Effective channel power gain');ylabel('Empirical cumulative fraction');grid on;title(sprintf('Gain distribution at %g dB',snr));keep(f,sprintf('Gain CDF SNR %g',snr));
end
r=reps{8};
f=newfig;imagesc(abs(cg(:,:,1)));axis xy;xlabel('OFDM symbol index + 1');ylabel('Subcarrier index + 1');colorbar;title('CSI-RS port one resource map');keep(f,'CSI resource grid');
f=newfig;imagesc(abs(r.Hgrid(:,:,1,1)));axis xy;xlabel('OFDM symbol index + 1');ylabel('Subcarrier index + 1');colorbar;title('Estimated channel receive one port one');keep(f,'CSI estimated channel grid');
f=newfig;bar([abs(r.H(:)) abs(r.Hm(:)) abs(r.Hold(:))]);xlabel('Channel matrix element');ylabel('Magnitude');legend('Current truth','Current estimate','Old estimate');title('Two by two channel estimate');keep(f,'Channel matrix comparison');
f=newfig;plot(real(W),imag(W),'o',MarkerSize=12,LineWidth=2);axis equal;grid on;xlabel('Real weight');ylabel('Imaginary weight');title('Two port rank one codebook weights');keep(f,'Codebook weights');
for k=1:3,r=reps{(k-1)*5+3};f=newfig;scatter(real(r.eq(:)),imag(r.eq(:)),8,'filled');axis equal;grid on;xlabel('In phase');ylabel('Quadrature');title(sprintf('Current PMI at %g dB, rank %d',r.snr,r.rank));keep(f,sprintf('Received constellation SNR %g',r.snr));end
writetable(cell2table(figures,VariableNames={'File','Title'}),fullfile(out,'figures.csv'));test_uni07;
assert(height(trials)==720 && numel(figures(:,1))>=24);assert(any(trials.Rank==2));assert(any(trials.CRC==0)&&any(trials.CRC==1));fprintf('PASS actual CSI and PDSCH chain, rank adaptation, finite sample intervals.\n');
 function f=newfig,f=figure(Position=[100 100 1440 900]);end
 function keep(f,ttl),file=['Uni-07 - ' ttl ' v2.png'];exportgraphics(f,fullfile(figdir,file),Resolution=150);close(f);figures(end+1,:)={file,ttl};end
end
function [lo,hi]=wilson(k,n)
z=1.95996398454005;p=k/n;d=1+z^2/n;c=(p+z^2/(2*n))/d;h=z*sqrt(p*(1-p)/n+z^2/(4*n^2))/d;lo=max(0,c-h);hi=min(1,c+h);
end
