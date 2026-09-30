function run_uni06
root=fileparts(mfilename('fullpath')); out=fullfile(root,'results'); if ~isfolder(out),mkdir(out);end
figdir=fullfile(root,'..','..','notes','99 Attachments','5G','Uni Labs','Uni-06'); if ~isfolder(figdir),mkdir(figdir);end
diary(fullfile(out,'run.log')); cleanup=onCleanup(@()diary('off'));
cfg=struct('seed',6007,'mu',1,'p0dBm',-90,'pmaxdBm',23,'noiseFiguredB',5,'nTrials',24, ...
    'lossdB',[90 100 110 115 120 125 130 135],'alphas',[0.8 1],'RBs',[6 24],'rate',0.48);
rng(cfg.seed,'twister'); disp(version); ver; disp(cfg);
carrier=nrCarrierConfig(NSizeGrid=24,SubcarrierSpacing=30,NCellID=7);
rows=[]; summary=[]; reps=struct('loss',{},'grid',{},'tx',{},'rx',{},'hest',{},'symbols',{},'eq',{},'crc',{},'Nfft',{},'fs',{});
for M=cfg.RBs
 pusch=nrPUSCHConfig(PRBSet=0:M-1,Modulation='QPSK',NumLayers=1,RNTI=7);
 pusch.DMRS.DMRSAdditionalPosition=2;
 [ix,inf]=nrPUSCHIndices(carrier,pusch); dx=nrPUSCHDMRSIndices(carrier,pusch); ds=nrPUSCHDMRS(carrier,pusch);
 tbs=nrTBS('QPSK',1,M,inf.NREPerPRB,cfg.rate); B=M*12*30e3;
 N=-174+10*log10(B)+cfg.noiseFiguredB;
 for alpha=cfg.alphas
  for pl=cfg.lossdB
   [pt,raw]=uni06_power(pl,alpha,M,cfg.mu,cfg.p0dBm,cfg.pmaxdBm,0,0);
   snr=pt-pl-N; errors=0; evm=[];
   for trial=1:cfg.nTrials
    bits=randi([0 1],tbs,1,'int8'); enc=nrULSCH(TargetCodeRate=cfg.rate); setTransportBlock(enc,bits);
    cw=enc('QPSK',1,inf.G,0); sy=nrPUSCH(carrier,pusch,cw);
    txgrid=nrResourceGrid(carrier);txgrid(ix)=sy;txgrid(dx)=ds;
    [tx,oi]=nrOFDMModulate(carrier,txgrid,Windowing=0);
    % Normalize after path attenuation: the noise variance carries the link budget.
    nv=1/(oi.Nfft*10^(snr/10));noise=sqrt(nv/2)*complex(randn(size(tx)),randn(size(tx)));
    rx=tx+noise;rg=nrOFDMDemodulate(carrier,rx);
    [he,ne]=nrChannelEstimate(carrier,rg,dx,ds,CDMLengths=pusch.DMRS.CDMLengths);ne=max(ne,1e-9);
    [rd,hd]=nrExtractResources(ix,rg,he);[eq,csi]=nrEqualizeMMSE(rd,hd,ne);
    llr=nrPUSCHDecode(carrier,pusch,eq,ne);if iscell(llr),llr=llr{1};end
    dec=nrULSCHDecoder(TargetCodeRate=cfg.rate,TransportBlockLength=tbs,MaximumLDPCIterationCount=12);
    [bh,crc]=dec(llr.*repelem(csi,2),'QPSK',1,0);if iscell(bh),bh=bh{1};end
    e=100*sqrt(mean(abs(eq-sy).^2));errors=errors+double(crc);evm(end+1)=e;
    rows(end+1,:)=[M alpha pl trial pt raw snr crc sum(bh~=bits) e tbs ne];
    if M==6 && alpha==1 && trial==1 && ismember(pl,[90 120 135])
     reps(end+1)=struct('loss',pl,'grid',txgrid,'tx',tx,'rx',rx,'hest',he,'symbols',sy,'eq',eq,'crc',crc,'Nfft',oi.Nfft,'fs',oi.SampleRate);
    end
   end
   [lo,hi]=wilson(errors,cfg.nTrials);bler=errors/cfg.nTrials;
   summary(end+1,:)=[M alpha pl pt raw snr tbs errors cfg.nTrials bler lo hi tbs*(1-bler)/0.0005/1e6 mean(evm) N];
   fprintf('RB=%d alpha=%.1f PL=%g: errors=%d/%d SNR=%.2f\n',M,alpha,pl,errors,cfg.nTrials,snr);
  end
 end
end
trials=array2table(rows,VariableNames={'RB','Alpha','LossdB','Trial','TxPowerdBm','CommanddBm','SNRdB','CRC','BitErrors','EVMPercent','TBS','EstimatedNoise'});
results=array2table(summary,VariableNames={'RB','Alpha','LossdB','TxPowerdBm','CommanddBm','SNRdB','TBS','Errors','Trials','BLER','Lower95','Upper95','GoodputMbps','EVMPercent','NoisedBm'});
writetable(trials,fullfile(out,'trials.csv'));writetable(results,fullfile(out,'summary.csv'));
matlabVersion=version;toolboxes=ver;save(fullfile(out,'run.mat'),'cfg','carrier','results','trials','reps','matlabVersion','toolboxes');
figures={};set(groot,'defaultFigureVisible','off','defaultAxesFontSize',20,'defaultTextFontSize',20);
for alpha=cfg.alphas
 q=results(results.Alpha==alpha,:);
 chart(q,'TxPowerdBm','Transmit power (dBm)',sprintf('Power clamp alpha %.1f',alpha));
 chart(q,'SNRdB','Receive SNR (dB)',sprintf('SNR alpha %.1f',alpha));
 chart(q,'BLER','Transport block error fraction',sprintf('Decoded BLER alpha %.1f',alpha));
 chart(q,'GoodputMbps','Delivered payload (Mbit/s)',sprintf('Goodput alpha %.1f',alpha));
 chart(q,'EVMPercent','RMS EVM (%)',sprintf('Receiver EVM alpha %.1f',alpha));
end
q=results(results.Alpha==1,:);q.Headroom=cfg.pmaxdBm-q.CommanddBm;
chart(q,'Headroom','Command headroom (dB)','Power headroom');
q.Width=q.Upper95-q.Lower95;chart(q,'Width','95% interval width','Finite sample uncertainty');
q.Energy=10.^((q.TxPowerdBm-30)/10)./(q.GoodputMbps*1e6)*1e9;q.Energy(~isfinite(q.Energy))=NaN;
chart(q,'Energy','RF transmit energy (nJ / delivered bit)','Energy per delivered bit');
for k=1:numel(reps)
 f=newfig;scatter(real(reps(k).eq),imag(reps(k).eq),8,'filled');axis equal;grid on;xlabel('In phase');ylabel('Quadrature');title(sprintf('Decoded symbols at PL = %d dB',reps(k).loss));
 keep(f,sprintf('Constellation PL %d',reps(k).loss));
end
f=newfig;imagesc(0:13,0:287,abs(reps(1).grid));axis xy;xlabel('OFDM symbol');ylabel('Subcarrier');colorbar;title('Actual PUSCH transmit grid');keep(f,'PUSCH resource grid');
f=newfig;plot((0:numel(reps(1).tx)-1)/reps(1).fs*1e3,abs(reps(1).tx));xlabel('Time (ms)');ylabel('Normalized magnitude');title('Transmitted OFDM envelope');grid on;keep(f,'Transmit envelope');
f=newfig;plot(0:287,abs(reps(1).hest(:,7)));hold on;plot(0:287,abs(reps(end).hest(:,7)));xlabel('Subcarrier');ylabel('Estimated channel magnitude');legend('PL 90 dB','PL 135 dB');grid on;title('DM-RS estimate at two losses');keep(f,'Channel estimate error');
f=newfig;bar(cfg.RBs,[results.TBS(1) results.TBS(end)]);xlabel('Allocated resource blocks');ylabel('Transport block bits');title('Allocation changes payload size');keep(f,'Payload size versus allocation');
writetable(cell2table(figures,VariableNames={'File','Title'}),fullfile(out,'figures.csv'));
test_uni06;assert(height(trials)==768);assert(all(results.TxPowerdBm<=23));assert(all(results.Lower95<=results.BLER & results.Upper95>=results.BLER));
assert(any(results.BLER==0)&&any(results.BLER>0.8));fprintf('PASS actual waveform sweep, clamp, intervals and failure regime.\n');
 function chart(t,field,yl,ttl)
  f=newfig;hold on;for rb=cfg.RBs,s=t(t.RB==rb,:);if strcmp(field,'BLER'),errorbar(s.LossdB,s.BLER,s.BLER-s.Lower95,s.Upper95-s.BLER,'-o',LineWidth=2);else,plot(s.LossdB,s.(field),'-o',LineWidth=2);end;end
  xlabel('Path loss (dB)');ylabel(yl);legend('6 RB','24 RB',Location='best');grid on;title(ttl);keep(f,ttl);
 end
 function f=newfig,f=figure(Position=[100 100 1440 900]);end
 function keep(f,ttl)
  file=['Uni-06 - ' ttl ' v1.png'];exportgraphics(f,fullfile(figdir,file),Resolution=150);close(f);figures(end+1,:)={file,ttl};
 end
end
function [lo,hi]=wilson(k,n)
z=1.95996398454005;p=k/n;d=1+z^2/n;c=(p+z^2/(2*n))/d;h=z*sqrt(p*(1-p)/n+z^2/(4*n^2))/d;lo=max(0,c-h);hi=min(1,c+h);
end
