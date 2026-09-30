function uni07_replot
% Re-render the Uni-07 teaching figures in the light theme from the saved run.mat.
% No experiment runs here; the CSI-RS grid is rebuilt from the saved configuration and every
% curve is read from results, trials and reps written by run_uni07.
root=fileparts(mfilename('fullpath'));out=fullfile(root,'results');
figdir=fullfile(root,'..','..','notes','99 Attachments','5G','Uni Labs','Uni-07');
d=load(fullfile(out,'run.mat'),'carrier','csirs','W','modes','trials','results','reps');
carrier=d.carrier;csirs=d.csirs;W=d.W;modes=d.modes;trials=d.trials;results=d.results;reps=d.reps;
ci=nrCSIRSIndices(carrier,csirs);cs=nrCSIRS(carrier,csirs);cg=nrResourceGrid(carrier,2);cg(ci)=cs;
figures={};
fields={'BLER','GoodputMbps','Gain','NMSE','MeanRank','MeanQm','EVMPercent'};labels={'Transport block error fraction','Delivered payload (Mbit/s)','Effective channel power gain','Channel NMSE','Mean spatial rank','Mean modulation order (bits/symbol)','RMS EVM (%)'};
for j=1:numel(fields),f=newfig;hold on;for mode=1:numel(modes),t=results(results.Mode==mode,:);plot(t.SNRdB,t.(fields{j}),'-o',LineWidth=2);end;xlabel('Noise reference SNR (dB)');ylabel(labels{j});legend(modes,Location='best');grid on;title(labels{j});keep(f,fields{j});end
f=newfig;hold on;for mode=[3 4 5],t=results(results.Mode==mode,:);errorbar(t.SNRdB,t.BLER,t.BLER-t.Lower95,t.Upper95-t.BLER,'-o',LineWidth=2);end;legend(modes([3 4 5]));xlabel('SNR (dB)');ylabel('BLER and Wilson 95% interval');grid on;keep(f,'BLER intervals');
f=newfig;hold on;for mode=[1 3 4 5],t=results(results.Mode==mode,:);errorbar(t.SNRdB,t.GoodputMbps,t.GoodputHalfCI95,'-o',LineWidth=2);end;legend(modes([1 3 4 5]));xlabel('SNR (dB)');ylabel('Payload Mbit/s and t interval');grid on;keep(f,'Throughput intervals');
for snr=[0 10 20]
 t=trials(trials.SNRdB==snr & trials.Mode==3,:);f=newfig;histogram(t.PMI,-.5:1:3.5);xlabel('Reported PMI index');ylabel('Trials');title(sprintf('PMI selections at %g dB',snr));keep(f,sprintf('PMI SNR %g',snr));
 f=newfig;imagesc(0:3,0:3,accumarray([t.DelayedPMI+1 t.PMI+1],1,[4 4]));axis xy;axis square;xticks(0:3);yticks(0:3);colorbar;xlabel('Current PMI');ylabel('Delayed PMI');title(sprintf('PMI agreement at %g dB',snr));keep(f,sprintf('PMI agreement SNR %g',snr));
 f=newfig;hold on;for mode=[1 3 4],t=trials(trials.SNRdB==snr & trials.Mode==mode,:);plot(sort(t.Gain),(1:height(t))/height(t),LineWidth=2);end;legend(modes([1 3 4]));xlabel('Effective channel power gain');ylabel('Empirical cumulative fraction');grid on;title(sprintf('Gain distribution at %g dB',snr));keep(f,sprintf('Gain CDF SNR %g',snr));
end
r=reps{8};
f=newfig;imagesc(abs(cg(:,:,1)));axis xy;xlabel('OFDM symbol index + 1');ylabel('Subcarrier index + 1');colorbar;title('CSI-RS port one resource map');keep(f,'CSI resource grid');
f=newfig;imagesc(abs(r.Hgrid(:,:,1,1)));axis xy;xlabel('OFDM symbol index + 1');ylabel('Subcarrier index + 1');colorbar;title('Estimated channel receive one port one');keep(f,'CSI estimated channel grid');
f=newfig;bar([abs(r.H(:)) abs(r.Hm(:)) abs(r.Hold(:))]);xlabel('Channel matrix element');ylabel('Magnitude');legend('Current truth','Current estimate','Old estimate');title('Two by two channel estimate');keep(f,'Channel matrix comparison');
f=newfig;plot(real(W),imag(W),'o',MarkerSize=12,LineWidth=2);axis equal;grid on;xlabel('Real weight');ylabel('Imaginary weight');title('Two port rank one codebook weights');keep(f,'Codebook weights');
for k=1:3,r=reps{(k-1)*5+3};f=newfig;scatter(real(r.eq(:)),imag(r.eq(:)),8,'filled');axis equal;grid on;xlabel('In phase');ylabel('Quadrature');title(sprintf('Current PMI at %g dB, rank %d',r.snr,r.rank));keep(f,sprintf('Received constellation SNR %g',r.snr));end
expected=readtable(fullfile(out,'figures.csv'));assert(isequal(sort(expected.File),sort(figures(:,1))),'Figure inventory differs from figures.csv');
fprintf('Re-rendered %d Uni-07 figures in the light theme.\n',size(figures,1));
 function f=newfig
  f=pubfig.new('wide');
 end
 function keep(f,ttl),file=['Uni-07 - ' ttl ' v2.png'];pubfig.export(f,fullfile(figdir,file));close(f);figures(end+1,:)={file,ttl};end
end
