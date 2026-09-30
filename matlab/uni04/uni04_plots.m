function uni04_plots(base,cfg,d,u,q,r,normal,stress)
% All figures contain MATLAB simulation outputs or measured timing positions.
out=fullfile(base,'..','..','notes','99 Attachments','5G','Uni Labs','Uni-04');
if ~isfolder(out), mkdir(out); end
red='#e91d2a'; purple='#6a26a4'; sky='#9ab6c8'; yellow='#fcc20f';
set(groot,'defaultAxesFontSize',20,'defaultTextFontSize',20, ...
    'defaultAxesXColor','k','defaultAxesYColor','k','defaultAxesColor','w', ...
    'defaultAxesLineWidth',1.2,'defaultFigureColor','w','defaultLegendFontSize',20);
f=newfig([1450 740]); tiledlayout(1,2,TileSpacing='compact',Padding='compact');
nexttile; plot(0:220,normal.diagnosticCorrelation(1:221),'-o','Color',purple, ...
    'LineWidth',1.8,'MarkerIndices',1:8:221,'MarkerSize',6);
hold on; xline(cfg.delaySamples,'--k','LineWidth',1.7);
xlabel('Circular correlation lag (samples)'); ylabel('Normalized correlation power');
title({'CFO 0 Hz',sprintf('preamble %d, delay %.0f samples',normal.detectedIndex,normal.detectedOffset)});
xlim([0 220]); ylim([0 1.08]); grid on;
nexttile; plot(0:220,stress.diagnosticCorrelation(1:221),'--s','Color',red, ...
    'LineWidth',1.8,'MarkerIndices',1:8:221,'MarkerSize',6);
hold on; xline(cfg.delaySamples,'--k','LineWidth',1.7);
xlabel('Circular correlation lag (samples)'); ylabel('Normalized correlation power');
title({'CFO 1250 Hz',sprintf('preamble %d, delay %.0f samples',stress.detectedIndex,stress.detectedOffset)});
xlim([0 220]); ylim([0 1.08]); grid on;
savefigpair(f,'PRACH Correlation and Frequency Offset');

f=newfig([1550 760]); tiledlayout(1,2,TileSpacing='compact',Padding='compact');
s=d(d.family=="SNR",:); nexttile;
errorbar(s.xValue,s.probability,s.probability-s.lower95,s.upper95-s.probability, ...
    '-o','Color',purple,'LineWidth',2,'MarkerSize',9,'CapSize',10);
xlabel('Active sample SNR (dB)'); ylabel('Correct preamble and timing probability');
title(sprintf('CFO 0 Hz   %d trials per point',cfg.trialsPerPoint)); ylim([-0.04 1.04]); grid on;
s=d(d.family=="CFO",:); nexttile;
errorbar(s.xValue,s.probability,s.probability-s.lower95,s.upper95-s.probability, ...
    '-o','Color',purple,'LineWidth',2,'MarkerSize',9,'CapSize',10); hold on;
errorbar(s.xValue,s.anyDetectionProbability,s.anyDetectionProbability-s.anyLower95, ...
    s.anyUpper95-s.anyDetectionProbability,'--s','Color',red,'LineWidth',2,'MarkerSize',8,'CapSize',10);
xlabel('Frequency offset (Hz)'); ylabel('Detection probability');
title(sprintf('Active sample SNR %g dB',cfg.cfoStressSNRdB)); ylim([-0.04 1.04]); grid on;
legend('Correct index and timing','Any detected index','Location','southwest');
savefigpair(f,'PRACH Detection Probability with Confidence Intervals');

f=newfig([1500 740]); tiledlayout(1,2,TileSpacing='compact',Padding='compact');
s=d(d.family=="Noise",:);
for panel=1:2
    nexttile;
    if panel==1, selected=1:height(s); else, selected=find(s.threshold>=0.02); end
    b=s(selected,:); x=1:height(b);
    bar(x,b.probability,'FaceColor',sky,'EdgeColor','k'); hold on;
    errorbar(x,b.probability,b.probability-b.lower95,b.upper95-b.probability, ...
        '.k','LineWidth',1.8,'CapSize',12);
    xticks(x); xticklabels(compose('%.3f',b.threshold));
    xlabel('Detection threshold'); ylabel('False alarm probability'); grid on;
    counts=strjoin(compose('%d',b.count),', ');
    if panel==1, ylim([0 1.06]); title({'Noise only, all thresholds',sprintf('false alarms %s of %d',counts,b.trials(1))});
    else, ylim([0 0.012]); title({'Noise only, detailed scale',sprintf('false alarms %s of %d',counts,b.trials(1))}); end
    % Counts are carried in the tick labels above, so nothing overlaps.
end
savefigpair(f,'Noise Only False Alarms and Finite Sample Limits');

f=newfig([1500 740]); tiledlayout(1,2,TileSpacing='compact',Padding='compact');
nexttile;
plot(q.trueSamples,q.measuredSamples,'-o','Color',purple,'LineWidth',2,'MarkerSize',8); hold on;
stairs(q.trueSamples,q.advanceSamples,'--','Color',red,'LineWidth',2);
xlabel('Injected arrival delay (samples)'); ylabel('Measured delay or commanded advance (samples)');
title('Noiseless PRACH measurement and TA'); grid on;
legend('Detected timing','TA advance','Location','northwest');
nexttile;
plot(q.trueSamples,q.residualSamples,'-s','Color',purple,'LineWidth',2,'MarkerSize',8); hold on;
yline(2,'--k','LineWidth',1.5); yline(-2,'--k','LineWidth',1.5); yline(0,':k');
xlabel('Injected arrival delay (samples)'); ylabel('Arrival error after TA (samples)');
title('15 kHz UL SCS   TA step 4 samples'); ylim([-3 3]); grid on;
savefigpair(f,'Measured Timing Advance Quantization');

f=newfig([1550 1050]); tiledlayout(3,1,TileSpacing='compact',Padding='compact');
names={'Scheduled transmit waveform','Received without TA','Received after measured TA'};
waves={r.transmitWaveform,r.uncorrectedWaveform,r.correctedWaveform};
colors={'k',red,purple}; delay=[0 r.uncorrectedResidual r.correctedResidual];
powerRef=mean(abs(r.transmitWaveform).^2);
for j=1:3
    nexttile;
    n=0:699; trace=movmean(abs(waves{j}(n+1)).^2,8)/powerRef;
    plot(n/r.sampleRate*1e6,trace,'Color',colors{j},'LineWidth',1.6); hold on;
    xline(r.fftStartSamples(1)/r.sampleRate*1e6,'--k','LineWidth',2);
    xline((r.fftStartSamples(1)+r.Nfft)/r.sampleRate*1e6,'--k','LineWidth',2);
    xline(delay(j)/r.sampleRate*1e6,'-','Color',colors{j},'LineWidth',2);
    xline((delay(j)+r.cyclicPrefixLengths(1))/r.sampleRate*1e6,':','Color',colors{j},'LineWidth',2);
    xlim([0 700/r.sampleRate*1e6]); ylim([0 7]); grid on;
    ylabel('Normalized power');
    title(sprintf('%s   arrival %+g samples',names{j},delay(j)));
    if j==1
        text(24,6.2,'Dashed: the same FFT window');
    end
    if j==3, xlabel('Time from scheduled gNB UL origin (\mus)'); end
end
savefigpair(f,'PUSCH Waveform Positions before and after Timing Advance');

f=newfig([1800 760]); tiledlayout(1,3,TileSpacing='compact',Padding='compact');
nexttile;
plot(real(r.uncorrectedSymbols),imag(r.uncorrectedSymbols),'o','Color',red,'MarkerSize',4); hold on;
plot(real(r.transmitSymbols),imag(r.transmitSymbols),'xk','MarkerSize',10,'LineWidth',1.6);
axis equal; xlim([-3 3]); ylim([-3 3]); grid on;
xlabel('In phase'); ylabel('Quadrature'); title({'Without TA',sprintf('EVM %.1f%%',r.uncorrectedEVMPercent)});
nexttile;
plot(real(r.correctedSymbols),imag(r.correctedSymbols),'o','Color',purple,'MarkerSize',4); hold on;
plot(real(r.transmitSymbols),imag(r.transmitSymbols),'xk','MarkerSize',10,'LineWidth',1.6);
axis equal; xlim([-1.5 1.5]); ylim([-1.5 1.5]); grid on;
xlabel('In phase'); ylabel('Quadrature'); title({'Measured TA',sprintf('EVM %.1f%%',r.correctedEVMPercent)});
nexttile;
errors=[sum(u.uncorrectedCRC==1),sum(u.correctedCRC==1)]; N=height(u);
lo=zeros(1,2); hi=lo;
for j=1:2, [lo(j),hi(j)]=uni04_wilson(errors(j),N); end
bar(1:2,errors/N,'FaceColor',yellow,'EdgeColor','k'); hold on;
errorbar(1:2,errors/N,errors/N-lo,hi-errors/N,'.k','LineWidth',2,'CapSize',12);
xticks(1:2); xticklabels({'No TA','With TA'});
ylabel('UL-SCH block error rate'); ylim([-0.04 1.1]); grid on;
title(sprintf('%d blocks   95%% Wilson intervals',N));
for j=1:2, text(j,0.12+0.65*(errors(j)>0),sprintf('%d / %d',errors(j),N),'HorizontalAlignment','center'); end
savefigpair(f,'PUSCH Constellations and UL SCH CRC Results');

    function f=newfig(sz)
        f=pubfig.new('wide'); %#ok<INUSD>
    end
    function savefigpair(f,purpose)
        % Explicit colors prevent a user's dark MATLAB theme changing exports.
        set(findall(f,'Type','text'),'Color','k');
        set(findall(f,'Type','legend'),'Color','w','TextColor','k','EdgeColor','k');
        set(findall(f,'Type','axes'),'GridColor','k','MinorGridColor','k');
        stemname=fullfile(out,['Uni-04 - ' purpose ' v1']);
        pubfig.export(f,[stemname '.png']);
        close(f);
    end
end
