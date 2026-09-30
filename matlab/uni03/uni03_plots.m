function uni03_plots(out)
s=load(fullfile(out,'run.mat'));t=s.t;b=s.baseline;m=s.m;
figdir=fullfile(out,'figures');if ~isfolder(figdir),mkdir(figdir);end
catalog=struct('file',{},'source',{});num=0;
new;imagesc(0:27,0:335,abs(t.grid));axis xy;colorbar;xlabel('OFDM symbol from frame start');ylabel('Capture subcarrier');title('Transmitted two slot resource grid');finish('Transmit Grid','t.grid');
new;imagesc(0:27,0:335,abs(s.grid(:,1:28)));axis xy;colorbar;xlabel('OFDM symbol from frame start');ylabel('Capture subcarrier');title('Recovered two slot resource grid');finish('Received Grid','grid');
new;plot((0:numel(s.w)-1)/t.sampleRate*1000,movmean(abs(s.w),16),'LineWidth',1.6);xlabel('Time (ms)');ylabel('Smoothed magnitude');title('Received waveform: two bursts in noise');finish('Received Waveform','w');
new;N=2^nextpow2(numel(s.w));f=(-N/2:N/2-1)*t.sampleRate/N/1e6;plot(f,movmean(20*log10(abs(fftshift(fft(s.w,N)))+1e-8),64),'LineWidth',1.8);xlabel('Frequency relative capture centre (MHz)');ylabel('Smoothed FFT magnitude (dB)');title('Received spectrum');finish('Received Spectrum','w');
new;plot(f,movmean(20*log10(abs(fftshift(fft(m.correctedWaveform,N)))+1e-8),64),'LineWidth',1.8);xlabel('Frequency relative capture centre (MHz)');ylabel('Smoothed FFT magnitude (dB)');title('Spectrum after frequency correction');finish('Corrected Spectrum','m.correctedWaveform');
new;stem(1:24,double(t.mib.mibBits),'filled');hold on;plot(1:24,double(m.mibBits),'rx','MarkerSize',12);ylim([-.2 1.2]);xlabel('BCH transport bit');ylabel('Bit value');legend('Generated MIB','Recovered MIB');title('MIB bit agreement');finish('MIB Agreement','t.mib.mibBits and m.mibBits');
new;bar([m.coarseOffset m.fineOffset m.frequencyOffset s.config.cfoHz]);xticklabels({'Coarse','Fine','Total estimate','Injected'});ylabel('Frequency (Hz)');title('Frequency offset components');finish('Offset Components','m frequency fields');
new;imagesc(0:13,0:287,abs(t.grid(49:336,15:28)));axis xy;colorbar;xlabel('Symbol in slot 1');ylabel('Subcarrier relative CORESET0');title('Transmitted monitoring slot');finish('Transmit Monitoring Slot','t.grid(49:336,15:28)');
new;imagesc(0:13,0:287,abs(s.grid(49:336,15:28)));axis xy;colorbar;xlabel('Symbol in slot 1');ylabel('Subcarrier relative CORESET0');title('Received monitoring slot');finish('Receive Monitoring Slot','grid(49:336,15:28)');
new;map=zeros(288,14);map(t.pdcchIndices)=1;map(t.pdschIndices)=2;map(t.pdschDMRSIndices)=3;imagesc(0:13,0:287,map);axis xy;xlabel('Symbol in slot 1');ylabel('Subcarrier relative CORESET0');cb=colorbar;cb.Ticks=0:3;cb.TickLabels={'unused','PDCCH','PDSCH','DM-RS'};title('Numerical channel resource assignments');finish('Channel Assignments','t pdcchIndices pdschIndices pdschDMRSIndices');
new;v=b.candidateTrace;stem(1:size(v,1),v(:,4)==0,'filled');ylim([-.1 1.1]);xlabel('Attempt in monitoring order');ylabel('CRC accepted');title('Blind candidate acceptance');finish('Candidate Acceptance','baseline.candidateTrace');
new;semilogy(1:size(v,1),max(v(:,4),.5),'o-');xlabel('Attempt in monitoring order');ylabel('CRC syndrome (zero displayed at 0.5)');title('Candidate CRC syndromes');finish('Candidate Syndromes','baseline.candidateTrace');
new;plot(real(b.pdcchEqualized),imag(b.pdcchEqualized),'.');axis equal;grid on;xlabel('In phase');ylabel('Quadrature');title('Equalized accepted PDCCH');finish('PDCCH Constellation','baseline.pdcchEqualized');
new;delete(gca);tiledlayout(2,1,'TileSpacing','compact','Padding','compact');nexttile;stem(0:119,b.pdcchLLR(1:120),'filled','MarkerSize',4);xlabel('Rate matched control bit (first 120)');ylabel('LLR');title('PDCCH soft decisions: sign and confidence');nexttile;histogram(b.pdcchLLR,40);xlabel('Log likelihood ratio');ylabel('Count');title(sprintf('All %d control soft bits',numel(b.pdcchLLR)));finish('PDCCH LLR','baseline.pdcchLLR');
new;stairs(double(t.dciBits),'LineWidth',2);hold on;plot(double(b.dciBits),'rx');ylim([-.2 1.2]);xlabel('DCI information bit');ylabel('Bit value');legend('Transmitted','Decoded');title('Recovered DCI bits');finish('DCI Agreement','t.dciBits and baseline.dciBits');
new;plot(real(b.pdschReceived),imag(b.pdschReceived),'.');axis equal;grid on;xlabel('In phase');ylabel('Quadrature');title('Received PDSCH symbols');finish('PDSCH Before Equalization','baseline.pdschReceived');
new;plot(real(b.pdschEqualized),imag(b.pdschEqualized),'.');axis equal;grid on;xlabel('In phase');ylabel('Quadrature');title('Equalized PDSCH symbols');finish('PDSCH After Equalization','baseline.pdschEqualized');
new;imagesc(0:13,0:287,abs(b.channelEstimate));axis xy;colorbar;xlabel('OFDM symbol');ylabel('CORESET relative subcarrier');title('PDSCH channel magnitude estimate');finish('Channel Magnitude','baseline.channelEstimate');
new;imagesc(0:13,0:287,angle(b.channelEstimate));axis xy;colorbar;xlabel('OFDM symbol');ylabel('CORESET relative subcarrier');title('PDSCH channel phase estimate (rad)');finish('Channel Phase','baseline.channelEstimate');
new;delete(gca);tiledlayout(2,1,'TileSpacing','compact','Padding','compact');nexttile;stem(0:119,b.pdschLLR(1:120),'filled','MarkerSize',4);xlabel('Rate matched data bit (first 120)');ylabel('LLR');title('PDSCH soft decisions: sign and confidence');nexttile;histogram(b.pdschLLR,40);xlabel('Log likelihood ratio');ylabel('Count');title(sprintf('All %d data soft bits',numel(b.pdschLLR)));finish('PDSCH LLR','baseline.pdschLLR');
new;imagesc(1:400,1:2,[double(t.transportBits(1:400))';double(b.transportBits(1:400))']);colormap(gca,[1 1 1;0 0.35 0.65]);clim([0 1]);yticks([1 2]);yticklabels({'Transmitted','Decoded'});xlabel('UPER bit index (dark = 1)');title(sprintf('400 SIB1 bits, %d mismatches',nnz(t.transportBits(1:400)~=b.transportBits(1:400))));finish('SIB1 Bits','t.transportBits and baseline.transportBits first400');
new;q=s.summary;errorbar(q.snrDb,q.successFraction,q.successFraction-q.wilsonLower,q.wilsonUpper-q.successFraction,'o-','LineWidth',2);ylim([-.05 1.05]);xlabel('SNR per occupied resource element (dB)');ylabel('Successful transport fraction');title('Conditional reception: 20 trials per SNR; Wilson 95%');grid on;finish('Reception Probability','summary.csv');
new;tr=s.trials;xx=unique(tr.snrDb);yy=zeros(numel(xx),2);for k=1:numel(xx),sel=tr.snrDb==xx(k);yy(k,:)=[mean(tr.dciAccepted(sel)) mean(tr.transportAccepted(sel))];end;plot(xx,yy,'o-','LineWidth',2);ylim([-.05 1.05]);xlabel('SNR per resource element (dB)');ylabel('Acceptance fraction');legend('PDCCH CRC','DL-SCH CRC');title('Which decoder limits reception');grid on;finish('Decoder Bottleneck','trials.csv');
new;bar(categorical(s.failureTable.caseName),[s.failureTable.dciAccepted s.failureTable.transportAccepted]);ylabel('Accepted (1) or rejected (0)');ylim([0 1.25]);legend('DCI CRC','Transport CRC');xtickangle(30);title('Controlled configuration failures');finish('Failure Comparison','failures.csv');
f=fopen(fullfile(figdir,'catalog.json'),'w');fwrite(f,jsonencode(catalog,'PrettyPrint',true));fclose(f);
 function new
  pubfig.new('wide'); axes;
 end
 function finish(label,source)
  num=num+1;name=sprintf('Uni-03 - %02d %s v1.png',num+6,label);
  set(findall(gcf,'Type','axes'),'Color','w','XColor','k','YColor','k','ZColor','k');
  set(findall(gcf,'Type','text'),'Color','k');
  set(findall(gcf,'Type','colorbar'),'Color','k');
  set(findall(gcf,'Type','legend'),'Color','w','TextColor','k','EdgeColor','k');
  pubfig.export(gcf,fullfile(figdir,name));close(gcf);
  catalog(end+1)=struct('file',name,'source',source);
 end
end
