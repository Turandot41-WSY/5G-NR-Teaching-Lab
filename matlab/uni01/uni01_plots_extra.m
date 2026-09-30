function catalog=uni01_plots_extra(runDir,figureDirectory)
% Additional scientific figures from the saved numerical evidence of one run.
% Every curve is read from run.mat; nothing is simulated here.
if nargin<1, runDir=fullfile('results','run-20260907-002810'); end
if nargin<2, figureDirectory='figures-extra'; end
dest=fullfile(runDir,figureDirectory); if ~isfolder(dest), mkdir(dest); end
S=load(fullfile(runDir,'run.mat'),'t','wave','observation','rx','trials','summary','stress','c');
t=S.t; wave=S.wave; obs=S.observation; rx=S.rx; trials=S.trials; summary=S.summary; c=S.c;
catalog=struct('stem',{},'caption',{},'evidence',{});
fs=t.sampleRate; scs=c.subcarrierSpacing*1e3;

% 27 Spectrum before and after frequency correction (zoomed to the SSB band, smoothed)
newfig('Received spectrum before and after frequency correction');
[p0,f0]=periodogram(wave,hann(numel(wave)),8192,fs,'centered');
[p1,f1]=periodogram(rx.correctedWaveform,hann(numel(rx.correctedWaveform)),8192,fs,'centered');
sm=@(p) movmean(10*log10(p/max(p)),25);
plot(f0/1e3,sm(p0),'Color',colors(1),'LineWidth',2); hold on;
plot(f1/1e3,sm(p1),'Color',[0.55 0.35 0.10],'LineWidth',2);
band=120*scs/2/1e3; xline([-band band],'--k','LineWidth',1.8);
xline(obs.frequencyOffsetHz/1e3,':','Color',[0.85 0.1 0.1],'LineWidth',2.4);
xlim([-2.2*band 2.2*band]); grid on; xlabel('Frequency (kHz)'); ylabel('Smoothed relative power (dB)');
legend({'Received capture','After estimated correction','SSB band edges (240 subcarriers)','Injected offset'},'Location','south');
title(sprintf('Injected offset %.1f kHz, receiver estimate %.1f kHz',obs.frequencyOffsetHz/1e3,rx.frequencyOffset/1e3));
finish('27 Spectrum Correction','The smoothed periodogram of the same 8 dB capture before and after the receiver applies its own frequency estimate, zoomed to twice the SSB band; the SSB energy moves back inside the 240-subcarrier band.','wave, rx.correctedWaveform, rx.frequencyOffset');

% 28 Coded-bit soft-value agreement before decoding
newfig('Soft values against the transmitted coded bits');
coded=double(t.codedBits(:)); soft=rx.softBits(:);
signAgree=(sign(soft)==(1-2*coded));   % coded bit 0 -> positive LLR convention checked below
if mean(signAgree)<0.5, signAgree=~signAgree; end
idx=1:numel(soft);
stem(idx(signAgree),abs(soft(signAgree)),'Marker','none','Color',colors(1)); hold on;
stem(idx(~signAgree),abs(soft(~signAgree)),'Marker','none','Color',colors(3),'LineWidth',1.4);
grid on; xlabel('Coded bit index (1 to 864)'); ylabel('|soft value|');
legend({sprintf('Sign agrees with transmitted bit (%d)',nnz(signAgree)),sprintf('Sign disagrees (%d)',nnz(~signAgree))},'Location','northeast');
title('Pre-decoder agreement of the 864 soft values');
finish('28 Coded Bit Agreement','Before polar decoding, the sign of each soft value is compared with the transmitted coded bit; the decoder must repair the disagreeing positions using the code structure.','rx.softBits, t.codedBits');

% 29 PBCH error vector per symbol after equalization
newfig('PBCH error vector magnitude per symbol');
ev=abs(rx.pbchEqualized(:)-t.pbchSymbols(:));
evm=sqrt(mean(ev.^2))/sqrt(mean(abs(t.pbchSymbols(:)).^2))*100;
plot(1:numel(ev),ev,'.','Color',colors(2),'MarkerSize',9); hold on;
yline(sqrt(mean(ev.^2)),'--k','LineWidth',1.2);
grid on; xlabel('PBCH symbol index (1 to 432)'); ylabel('|equalized symbol - transmitted symbol|');
legend({'Per-symbol error vector','RMS error vector'},'Location','northeast');
title(sprintf('EVM %.1f %% over 432 symbols at %g dB',evm,obs.snrDb));
finish('29 PBCH Error Vector','Each point is the distance between an equalized PBCH symbol and the symbol that was transmitted; the RMS line gives the error vector magnitude the decoder had to tolerate.','rx.pbchEqualized, t.pbchSymbols');

% 30 Residual errors of every successful trial: frequency error per SNR, timing error counts per SNR
newfig('Residual errors of the successful trials');
ok=trials.success & ~isnan(trials.frequencyErrorHz);
snrs=unique(trials.snrDb(ok));
tiledlayout(1,2,'TileSpacing','compact','Padding','compact');
nexttile; hold on;
for k=1:numel(snrs)
    m=ok & trials.snrDb==snrs(k); x=snrs(k)+1.2*(rand(nnz(m),1)-0.5);
    scatter(x,trials.frequencyErrorHz(m)/1e3,30,colors(k),'filled','MarkerFaceAlpha',0.7);
    plot(snrs(k)+[-1.5 1.5],[1 1]*sqrt(mean(trials.frequencyErrorHz(m).^2))/1e3,'k-','LineWidth',2.2);
end
grid on; xlabel('SNR (dB)'); ylabel('Frequency error (kHz)'); xticks(snrs);
title('Frequency error (bars: RMS)');
nexttile;
te=trials.timingErrorSamples(ok); vals=unique(te); counts=zeros(numel(snrs),numel(vals));
for k=1:numel(snrs), for j=1:numel(vals), counts(k,j)=nnz(ok & trials.snrDb==snrs(k) & trials.timingErrorSamples==vals(j)); end, end
b=bar(snrs,counts,'stacked'); for j=1:numel(vals), b(j).FaceColor=colors(j); end
grid on; xlabel('SNR (dB)'); ylabel('Successful trials'); xticks(snrs);
legend(arrayfun(@(v) sprintf('%+d samples',v),vals,'UniformOutput',false),'Location','northwest');
title('Timing error');
finish('30 Error Scatter','Every successful trial appears once: the left panel spreads the residual frequency error over its SNR with the RMS as a black bar, and the right panel counts how many trials ended with each integer timing error; timing is already exact at the lowest SNR while the frequency error keeps shrinking.','trials.frequencyErrorHz, trials.timingErrorSamples');

% 31 Outcome classes per SNR
newfig('Outcome classes per SNR point');
snrAll=unique(trials.snrDb); classes=zeros(numel(snrAll),4);
isShortAll=cellfun(@(e) contains(e,'CaptureShort'),trials.error);
for k=1:numel(snrAll)
    m=trials.snrDb==snrAll(k);
    classes(k,1)=nnz(m & trials.success);
    classes(k,2)=nnz(m & ~trials.success & trials.crcAccepted & ~isShortAll);
    classes(k,3)=nnz(m & ~trials.success & ~trials.crcAccepted & ~isShortAll);
    classes(k,4)=nnz(m & isShortAll);
end
b=bar(snrAll,classes,'stacked'); for k=1:4, b(k).FaceColor=colors(k); end
grid on; xlabel('SNR (dB)'); ylabel('Trials (40 per point)'); ylim([0 84]); yticks(0:10:40);
legend({'Complete success','CRC accepted, fields wrong','CRC rejected','Capture too short for the found timing'},'Location','north','NumColumns',1);
title('How the 320 trials ended');
finish('31 Outcome Classes','Each SNR column stacks the four ways a trial ended; the capture-length failures dominate at low SNR because a false timing peak places the block beyond the recorded samples.','trials.success, trials.crcAccepted, trials.error');

% 32 Coarse frequency candidates and the fine estimate
newfig('Coarse frequency candidates for the winning PSS');
[~,win]=max(max(rx.pssScores,[],1));
fc=rx.frequencyCandidates(:)/1e3; sc=rx.pssScores(:,win);
plot(fc,sc,'-o','Color',colors(1),'LineWidth',1.4,'MarkerFaceColor',colors(1)); hold on;
xline(rx.coarseOffset/1e3,'--','Color',colors(2),'LineWidth',1.4);
xline(rx.frequencyOffset/1e3,'-','Color',colors(3),'LineWidth',1.4);
xline(obs.frequencyOffsetHz/1e3,':k','LineWidth',1.4);
grid on; xlabel('Frequency hypothesis (kHz)'); ylabel('Largest timing correlation');
legend({sprintf('PSS N_{ID}^{(2)} = %d',win-1),'Coarse choice','Coarse plus fine estimate','Injected offset'},'Location','south');
title(sprintf('Coarse grid step %.1f kHz, fine correction %.2f kHz',mean(diff(fc)),rx.fineOffset/1e3));
finish('32 Coarse and Fine Offset','The receiver first picks the best of nine coarse hypotheses and then refines it from the PSS phase; the fine step closes most of the gap to the injected offset.','rx.pssScores, rx.frequencyCandidates, rx.coarseOffset, rx.fineOffset');

writecatalog(dest,catalog);

    function col=colors(k)
        pal=[0.60 0.71 0.78; 0.70 0.74 0.58; 0.90 0.57 0.36; 0.55 0.60 0.88; 0.84 0.48 0.48; 0.65 0.72 0.75];
        col=pal(mod(k-1,size(pal,1))+1,:);
    end
    function newfig(titleText)
        pubfig.new('wide');
        if nargin>0, setappdata(gcf,'uniTitle',titleText); end
    end
    function finish(stem,caption,evidence)
        path=fullfile(dest,['Uni-01 - ' stem ' v1.png']);
        pubfig.export(gcf,path);
        close(gcf);
        catalog(end+1)=struct('stem',stem,'caption',caption,'evidence',evidence);
    end
    function writecatalog(folder,cat)
        fid=fopen(fullfile(folder,'catalog.json'),'w'); fprintf(fid,'%s',jsonencode(cat,'PrettyPrint',true)); fclose(fid);
    end
end
