function uni06_replot
% Re-render the Uni-06 teaching figures in the light theme from the saved run.mat.
% No experiment runs here; every curve is read from results, trials and reps written by run_uni06.
root=fileparts(mfilename('fullpath'));out=fullfile(root,'results');
figdir=fullfile(root,'..','..','notes','99 Attachments','5G','Uni Labs','Uni-06');
d=load(fullfile(out,'run.mat'),'cfg','results','reps');cfg=d.cfg;results=d.results;reps=d.reps;
figures={};
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
kk=0:cfg.nTrials; ww=zeros(size(kk)); for i=1:numel(kk), [lo,hi]=wilson(kk(i),cfg.nTrials); ww(i)=hi-lo; end
f=newfig;plot(kk,ww,'-o','LineWidth',2);hold on;obs=unique(q.Errors);scatter(obs,arrayfun(@(k) ww(kk==k),obs),90,'filled');
xlabel(sprintf('Failed blocks out of %d',cfg.nTrials));ylabel('95% Wilson interval width');legend('Any count','Counts observed in this run',Location='south');grid on;title('Finite sample uncertainty');keep(f,'Finite sample uncertainty');
q.Energy=10.^((q.TxPowerdBm-30)/10)./(q.GoodputMbps*1e6)*1e9;q.Energy(~isfinite(q.Energy))=NaN;
chart(q,'Energy','RF transmit energy (nJ / delivered bit)','Energy per delivered bit');
for k=1:numel(reps)
 f=newfig;scatter(real(reps(k).eq),imag(reps(k).eq),8,'filled');axis equal;grid on;xlabel('In phase');ylabel('Quadrature');title(sprintf('Decoded symbols at PL = %d dB',reps(k).loss));
 keep(f,sprintf('Constellation PL %d',reps(k).loss));
end
f=newfig;imagesc(0:13,0:287,abs(reps(1).grid));axis xy;xlabel('OFDM symbol');ylabel('Subcarrier');colorbar;title('Actual PUSCH transmit grid');keep(f,'PUSCH resource grid');
tx=reps(1).tx(:);fs=reps(1).fs;nSym=size(reps(1).grid,2);
try, info=nrOFDMInfo(nrCarrierConfig(SubcarrierSpacing=30,NSizeGrid=size(reps(1).grid,1)/12),SampleRate=fs);lens=double(info.SymbolLengths(1:nSym));
catch, lens=repmat(floor(numel(tx)/nSym),1,nSym); end
edges=[0 cumsum(lens)];edges(end)=min(edges(end),numel(tx));tms=(0:numel(tx)-1)/fs*1e3;
rms=zeros(1,nSym);for k=1:nSym,seg=tx(edges(k)+1:edges(k+1));rms(k)=sqrt(mean(abs(seg).^2));end
f=newfig;t=tiledlayout(f,2,1,'TileSpacing','compact','Padding','compact');
nexttile(t);plot(tms,abs(tx),'Color',[.55 .72 .9],'LineWidth',1);hold on;
stairs(edges(1:end)/fs*1e3,[rms rms(end)],'k','LineWidth',2);
for k=2:nSym,xline(edges(k)/fs*1e3,':','Color',[.4 .4 .4],'LineWidth',1);end
ylim([0 max(abs(tx))*1.15]);xlim([0 tms(end)]);xlabel('Time (ms)');ylabel('Sample magnitude');
legend('Sample magnitude','RMS per OFDM symbol',Location='north');title('Transmitted waveform within one slot');grid on;
nexttile(t);bar(0:nSym-1,20*log10(rms/sqrt(mean(abs(tx).^2))),'FaceColor',[.24 .36 .52]);
xlabel('OFDM symbol');ylabel('Symbol power (dB)');title('Power per symbol relative to the slot mean');grid on;xticks(0:nSym-1);
keep(f,'Transmit envelope');
f=newfig;plot(0:287,abs(reps(1).hest(:,7)));hold on;plot(0:287,abs(reps(end).hest(:,7)));xlabel('Subcarrier');ylabel('Estimated channel magnitude');legend('PL 90 dB','PL 135 dB');grid on;title('DM-RS estimate at two losses');keep(f,'Channel estimate error');
f=newfig;bar(cfg.RBs,[results.TBS(1) results.TBS(end)]);xlabel('Allocated resource blocks');ylabel('Transport block bits');title('Allocation changes payload size');keep(f,'Payload size versus allocation');
expected=readtable(fullfile(out,'figures.csv'));assert(isequal(sort(expected.File),sort(figures(:,1))),'Figure inventory differs from figures.csv');
fprintf('Re-rendered %d Uni-06 figures in the light theme.\n',size(figures,1));
 function chart(t,field,yl,ttl)
  f=newfig;hold on;for rb=cfg.RBs,s=t(t.RB==rb,:);if strcmp(field,'BLER'),errorbar(s.LossdB,s.BLER,s.BLER-s.Lower95,s.Upper95-s.BLER,'-o',LineWidth=2);else,plot(s.LossdB,s.(field),'-o',LineWidth=2);end;end
  xlabel('Path loss (dB)');ylabel(yl);legend('6 RB','24 RB',Location='best');grid on;title(ttl);keep(f,ttl);
 end
 function f=newfig
  f=pubfig.new('wide');
 end
 function keep(f,ttl)
  file=['Uni-06 - ' ttl ' v1.png'];pubfig.export(f,fullfile(figdir,file));close(f);figures(end+1,:)={file,ttl};
 end
 function [lo,hi]=wilson(k,n)
  z=1.95996398454005;p=k/n;d=1+z^2/n;c=(p+z^2/(2*n))/d;h=z*sqrt(p*(1-p)/n+z^2/(4*n^2))/d;lo=max(0,c-h);hi=min(1,c+h);
 end
end
