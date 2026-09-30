function catalog=uni01_plots(runDir,figureDirectory)
% Scientific figures from saved numerical evidence; no synthetic result curves.
d=load(fullfile(runDir,'run.mat')); t=d.t; r=d.rx; c=d.c; q=d.trials; s=d.summary;
if nargin<2, figureDirectory='figures'; end
dest=fullfile(runDir,figureDirectory); if ~isfolder(dest), mkdir(dest); end
p=struct('red',[233 29 42]/255,'yellow',[252 194 15]/255, ...
    'purple',[106 38 164]/255,'sky',[154 182 200]/255, ...
    'lime',[192 212 167]/255,'salmon',[215 122 122]/255, ...
    'blue',[0 0 238]/255,'sage',[179 189 149]/255);
catalog=struct('file',{},'caption',{},'evidence',{});
styles={'-','--',':','-.'};

newfig('The transmitted SS/PBCH resource grid');
imagesc(0:3,0:239,t.labels); axis xy; colormap([1 1 1;p.yellow;p.purple;p.sky;p.lime]); clim([0 4]);
cb=colorbar; cb.Ticks=0:4; cb.TickLabels={'Unused','PSS','SSS','DM-RS','PBCH'};
xlabel('Symbol within SSB'); ylabel('Subcarrier within SSB'); xticks(0:3);
finish('01 SSB Resource Map','The actual 240-by-4 transmit grid distinguishes synchronization, reference and payload resources.','t.labels');

newfig('Three candidate PSS sequences'); hold on;
for k=0:2, stairs(0:126,nrPSS(k)+3*k,'LineWidth',1.6,'Color',colors(k+1)); end
yticks([0 3 6]); yticklabels({'N2 = 0','N2 = 1','N2 = 2'}); ylim([-1.7 7.7]); xlim([0 126]);
xlabel('Sequence element n'); ylabel('Sequence value with display offset');
finish('02 PSS Candidates','The three generated PSS candidates differ by sequence shift; vertical offsets separate the traces.','nrPSS(0:2)');

newfig('PSS correlations distinguish the identity component'); hold on;
for k=0:2
    [cc,lags]=xcorr(nrPSS(0),nrPSS(k));
    plot(lags,abs(cc)/127,'LineWidth',1.8,'Color',colors(k+1),'LineStyle',styles{k+1});
end
xlabel('Sequence lag'); ylabel('Correlation magnitude / 127'); legend({'N2 = 0','N2 = 1','N2 = 2'},'Location','northwest');
finish('03 PSS Correlations','Correlations computed from the three Toolbox sequences show the matched peak and competing candidates.','xcorr of nrPSS sequences');

newfig('The transmitted SSS identifies the cell group');
stairs(0:126,nrSSS(c.cellID),'Color',p.purple,'LineWidth',1.8); ylim([-1.5 1.5]); xlim([0 126]);
xlabel('Sequence element n'); ylabel('SSS value');
finish('04 SSS Sequence','The 127 SSS values are generated for PCI 321 before resource mapping.','nrSSS(321)');

newfig('The transmitted waveform contains one active SSB');
plot((0:numel(t.waveform)-1)/t.sampleRate*1e6,abs(t.waveform),'Color',p.blue,'LineWidth',1.2);
xlabel('Time from capture start (microseconds)'); ylabel('Complex sample magnitude');
finish('05 Transmit Envelope','Only one four-symbol SSB is active in the 24-RB capture grid; other symbols contain zero transmit samples.','t.waveform');

newfig('Noise, delay and frequency offset enter before acquisition');
delete(gca); tl=tiledlayout(2,1,'TileSpacing','compact','Padding','compact'); %#ok<NASGU>
nexttile; n=numel(d.wave); tt=(0:n-1)/t.sampleRate*1e6;
plot(tt,movmean(abs(d.wave),16),'Color',p.blue,'LineWidth',1.6); hold on;
xline(r.timingOffset/t.sampleRate*1e6,'--','Color',p.red,'LineWidth',2);
xlabel('Time from capture start (microseconds)'); ylabel('Smoothed magnitude'); grid on;
legend({'Received capture, 16-sample average','PSS reference origin'},'Location','northeast');
title('Where the SSB energy sits in the noisy capture');
nexttile; idx=r.timingOffset+(0:63);
plot(idx,real(d.wave(idx+1)),'-o','Color',p.blue,'LineWidth',1.6,'MarkerSize',5); hold on;
plot(idx,imag(d.wave(idx+1)),'--s','Color',p.red,'LineWidth',1.6,'MarkerSize',5);
xlabel('Received sample index (zero based)'); ylabel('Sample value'); grid on;
legend({'In-phase','Quadrature'},'Location','northeast'); title('64 samples at the reference origin');
finish('06 Received IQ','The upper panel smooths the received magnitude at 8 dB so the SSB burst stands out from the noise, with the PSS reference origin marked; the lower panel zooms into 64 raw in-phase and quadrature samples at that origin, which carry 137 samples of delay and 23.7 kHz frequency offset.','wave and rx.timingOffset');

newfig('The received spectrum before frequency correction');
n=numel(d.wave); f=(-floor(n/2):ceil(n/2)-1)/n*t.sampleRate/1e6;
plot(f,movmean(10*log10(abs(fftshift(fft(d.wave))).^2/n+eps),40),'Color',p.blue,'LineWidth',1.8); hold on;
band=120*c.subcarrierSpacing*1e3/1e6; xline([-band band],'--k','LineWidth',1.8);
xlabel('Baseband frequency (MHz)'); ylabel('Smoothed periodogram (relative dB)'); grid on;
legend({'40-bin moving average','SSB band edges (240 subcarriers)'},'Location','south');
finish('07 Received Spectrum','The periodogram of the finite noisy capture, smoothed over 40 bins so the raised SSB band is visible above the noise floor; the dashed lines mark the 240-subcarrier SSB band, and the whole shape sits 23.7 kHz off centre, too little to see at this scale. The vertical scale is relative power, uncalibrated.','fft(wave)');

newfig('Coarse frequency search compares 27 hypotheses');
imagesc(0:2,r.frequencyCandidates/1000,r.pssScores/max(r.pssScores,[],'all')); axis xy;
colormap([linspace(1,p.blue(1),128)' linspace(1,p.blue(2),128)' linspace(1,p.blue(3),128)']); colorbar;
xticks(0:2); xlabel('PSS identity component N2'); ylabel('Candidate frequency offset (kHz)');
finish('08 Coarse Search','Each heatmap cell is the largest timing correlation for one PSS and one frequency hypothesis.','rx.pssScores');

newfig('PSS correlation fixes a sample reference');
plot(0:numel(r.timingCorrelation)-1,r.timingCorrelation,'Color',p.purple,'LineWidth',1.5);
xlim([max(0,r.timingOffset-350) r.timingOffset+700]);
xline(r.timingOffset,'--','Color',p.red,'LineWidth',2);
xlabel('Reference origin in received samples'); ylabel('Correlation magnitude');
finish('09 Timing Peak','The dashed line marks the PSS reference origin; add the reference first-symbol length to obtain the SSB start.','rx.timingCorrelation and timingOffset');

newfig('SSS search completes the physical cell identity');
stem(0:335,r.sssScores/max(r.sssScores),'Marker','none','Color',p.purple,'LineWidth',1);
xlabel('SSS identity component N1'); ylabel('Normalized correlation power'); xlim([0 335]);
finish('10 SSS Search','The strongest SSS candidate is N1=107, which combines with N2=0 to give PCI 321.','rx.sssScores');

newfig('Eight PBCH DM-RS hypotheses select the SSB index');
bar(0:7,10*log10(r.dmrsScores),'FaceColor',p.sky,'EdgeColor','k'); xticks(0:7);
xlabel('Candidate SSB index'); ylabel('Channel-to-noise score (dB)');
finish('11 DMRS Hypotheses','Channel estimates from eight DM-RS references are compared using the estimated channel power divided by noise variance.','rx.dmrsScores');

newfig('The receiver extracts four symbols from noisy samples');
imagesc(0:3,0:239,abs(r.grid)); axis xy;
colormap([linspace(1,p.blue(1),128)' linspace(1,p.blue(2),128)' linspace(1,p.blue(3),128)']); colorbar; xticks(0:3);
xlabel('Symbol within SSB'); ylabel('Subcarrier within SSB');
finish('12 Received SSB','The extracted SSB amplitude grid includes noise on occupied and unoccupied resources.','abs(rx.grid)');

newfig('DM-RS estimates the channel magnitude'); hold on;
for k=1:4, plot(0:239,abs(r.channelEstimate(:,k)),'Color',colors(k),'LineWidth',1.7,'LineStyle',styles{k}); end
xlabel('Subcarrier within SSB'); ylabel('Estimated channel magnitude'); legend({'Symbol 0','Symbol 1','Symbol 2','Symbol 3'},'Location','southwest');
finish('13 Channel Magnitude','Four channel estimates come from the received DM-RS; deviations from unity reflect noise and remaining receiver error in this AWGN experiment.','abs(rx.channelEstimate)');

newfig('The channel estimate also carries phase'); hold on;
for k=1:4, plot(0:239,unwrap(angle(r.channelEstimate(:,k))),'Color',colors(k),'LineWidth',1.7,'LineStyle',styles{k}); end
xlabel('Subcarrier within SSB'); ylabel('Estimated phase (rad)'); legend({'Symbol 0','Symbol 1','Symbol 2','Symbol 3'},'Location','best');
finish('14 Channel Phase','The channel phase is estimated separately across the four SSB symbols.','unwrap(angle(rx.channelEstimate))');

newfig('PBCH symbols before equalization');
scatter(real(r.pbchReceived),imag(r.pbchReceived),28,p.salmon,'filled'); axis equal; grid on;
xlim([-2 2]); ylim([-2 2]);
xlabel('In-phase'); ylabel('Quadrature');
finish('15 Received PBCH','The 432 PBCH symbols before equalization are complex samples extracted from the recovered SSB.','rx.pbchReceived');

newfig('PBCH symbols after practical MMSE equalization');
scatter(real(r.pbchEqualized),imag(r.pbchEqualized),28,p.blue,'filled'); axis equal; grid on;
xlim([-2 2]); ylim([-2 2]);
xlabel('In-phase'); ylabel('Quadrature');
finish('16 Equalized PBCH','Equalization uses the estimated DM-RS channel and noise variance, with no true channel supplied to the receiver.','rx.pbchEqualized');

newfig('The decoder receives reliability as well as bit sign');
histogram(r.softBits,40,'FaceColor',p.sky,'EdgeColor','white'); xline(0,'--','Color',p.red,'LineWidth',2);
xlabel('Weighted log-likelihood ratio'); ylabel('Bit count');
finish('17 Soft Bits','The 864 soft values retain confidence for BCH decoding; a hard decision would discard their magnitudes.','rx.softBits');

newfig('All 24 formatted MIB message bits are recovered');
imagesc(1:24,1:2,[double(t.mibBits)';double(r.mibBits)']);
colormap([1 1 1;p.purple]); clim([0 1]); yticks([1 2]); yticklabels({'Transmitted','Recovered'});
xticks([1 4 8 12 16 20 24]); xlabel('BCCH-BCH message bit (one based)');
finish('18 MIB Bit Recovery','The recovered formatted BCCH-BCH message matches all 24 transmitted bits, including its choice and spare bits.','t.mibBits compared with rx.mibBits');

newfig('Acquisition success across received SNR');
errorbar(s.snrDb,s.successFraction,s.successFraction-s.wilsonLower,s.wilsonUpper-s.successFraction, ...
    '-o','Color',p.blue,'MarkerFaceColor',p.lime,'LineWidth',2,'CapSize',10);
ylim([-.05 1.05]); xlim([-20 12]); xlabel('Active-RE SNR (dB)'); ylabel('Complete recovery fraction');
finish('19 Acquisition Success','Each point contains 40 trials; bars show two-sided Wilson 95% intervals for complete PCI, MIB and frame-number recovery.','summary.csv');

newfig('Residual frequency error among successful recoveries');
plot(s.snrDb,s.frequencyRmseHzConditional,'-s','Color',p.purple,'MarkerFaceColor',p.sky,'LineWidth',2);
xlim([-8 12]);
xlabel('Active-RE SNR (dB)'); ylabel('Conditional frequency RMSE (Hz)');
finish('20 Frequency Error','Frequency RMSE includes only successful recoveries, with counts 35 at -6 dB and 40 at each higher point; missing points have no success.','summary.csv frequencyRmseHzConditional');

newfig('Timing error among successful recoveries');
good=q(q.success,:); [grp,~,ix]=unique([good.snrDb good.timingErrorSamples],'rows'); cnt=accumarray(ix,1);
scatter(grp(:,1),grp(:,2),8*cnt+40,p.blue,'filled'); text(grp(:,1)+0.9,grp(:,2),string(cnt),'FontSize',18,'Color','k');
xlim([-8 12]);
yticks(-2:2); ylim([-2 2]); xlabel('Active-RE SNR (dB)'); ylabel('SSB-start error (samples)');
finish('21 Timing Error','Marker size and the number beside it give the count of successful trials at each SNR and integer timing error.','trials.csv successful rows');

newfig('Frequency correction changes the decoding outcome');
fc=unique(d.stress.cfoHz); vals=zeros(numel(fc),2);
for j=1:numel(fc)
    for k=1:2
        z=d.stress(d.stress.cfoHz==fc(j) & d.stress.correctionEnabled==(k==1),:);
        vals(j,k)=mean(z.success);
    end
end
b=bar(fc/1000,vals,'grouped'); b(1).FaceColor=p.lime; b(2).FaceColor=p.salmon;
ylim([0 1.15]); xlabel('Injected frequency offset (kHz)'); ylabel('Complete recovery fraction');
xticks(fc/1000); legend({'Correction enabled','Correction disabled'},'Location','northeast');
finish('22 CFO Stress','Each stress bar summarizes ten trials at 8 dB; 120 kHz is outside the configured coarse search interval.','stress.csv');

newfig('Forty noise-only captures do not prove zero false acceptance');
v=mean(d.noiseAccept); bounds=d.report.noiseOnlyWilson95;
errorbar(1,v,v-bounds(1),bounds(2)-v,'o','Color',p.red,'MarkerFaceColor',p.salmon,'LineWidth',2,'CapSize',18);
xlim([.5 1.5]); ylim([-.005 .12]); yticks(0:.02:.12); xticks(1); xticklabels({'Noise only: 40 captures'}); ylabel('BCH CRC acceptance fraction');
finish('23 Noise Only','There were zero CRC acceptances in 40 noise captures; the Wilson 95% interval still extends to 8.76%.','noiseAccept and summary.json');

newfig('Cell identification precedes complete message recovery'); hold on;
plot(s.snrDb,s.pciCorrect./s.trials,'-s','Color',p.purple,'MarkerFaceColor',p.sky,'LineWidth',2);
plot(s.snrDb,s.successFraction,'--o','Color',p.blue,'MarkerFaceColor',p.lime,'LineWidth',2);
xlabel('Active-RE SNR (dB)'); ylabel('Fraction of 40 trials'); ylim([-.05 1.12]);
xlim([-20 12]);
legend({'Correct PCI','Complete recovery'},'Location','northwest');
finish('24 Stage Bottleneck','At -10 dB, some trials identify the cell while none recover the complete MIB, separating synchronization from payload success.','summary.csv pciCorrect and successes');

newfig('Estimated frequency follows the injected frequency');
z=q(q.snrDb==6 & q.success,:); scatter(z.cfoHz/1000,(z.cfoHz+z.frequencyErrorHz)/1000,60,p.blue,'filled'); hold on;
plot([-45 45],[-45 45],'--','Color',p.red,'LineWidth',1.5); axis equal;
xlim([-50 50]); ylim([-50 50]);
xlabel('Injected frequency offset (kHz)'); ylabel('Estimated frequency offset (kHz)');
finish('25 CFO Estimates','Forty successful trials at 6 dB compare the receiver estimate with the injected offset; the dashed diagonal is equality.','trials.csv SNR 6 dB');

newfig('Recovered MIB fields keep their semantic meaning');
tx=[c.systemFrameNumber c.mibSubcarrierSpacingCommon c.dmrsTypeAPosition c.pdcchConfigSib1];
rx=[r.systemFrameNumber r.subcarrierSpacingCommon r.dmrsTypeAPosition r.pdcchConfigSib1];
axis off;
labels={'System frame number','Common SCS (kHz)','DM-RS Type-A symbol','pdcch-ConfigSIB1'};
text(.02,.96,'Field','FontWeight','bold'); text(.58,.96,'Sent','FontWeight','bold'); text(.82,.96,'Recovered','FontWeight','bold');
for j=1:4
    y=.82-(j-1)*.20;
    text(.02,y,labels{j}); text(.58,y,num2str(tx(j)),'Color',p.purple);
    text(.82,y,num2str(rx(j)),'Color',p.blue);
end
finish('26 Recovered Fields','The decoded fields are parsed from the recovered message and compared with their configured values, including the reconstructed ten-bit SFN.','rx semantic fields versus config');

fid=fopen(fullfile(dest,'catalog.json'),'w'); assert(fid>=0); cleanup=onCleanup(@()fclose(fid));
fprintf(fid,'%s\n',jsonencode(catalog,'PrettyPrint',true));

function col=colors(k)
    cs=[p.blue;p.red;p.purple;[.20 .35 .15]]; col=cs(k,:);
end
function newfig(titleText)
    pubfig.new('wide');
    axes('Position',[.16 .18 .72 .70]);
    setappdata(gcf,'uniTitle',titleText); grid on; box off;
end
function finish(stem,caption,evidence)
    ax=gca; ax.XColor='k'; ax.YColor='k'; ax.XLabel.Color='k'; ax.YLabel.Color='k';
    if isempty(get(get(gca,'Title'),'String')), title(getappdata(gcf,'uniTitle'),'FontWeight','bold','Interpreter','none','Color','k'); end
    set(findall(gcf,'Type','colorbar'),'Color','k');
    set(findall(gcf,'Type','legend'),'TextColor','k','Color','w');
    file=['Uni-01 - ' stem ' v1.png']; path=fullfile(dest,file);
    pubfig.export(gcf,path);
    catalog(end+1)=struct('file',file,'caption',caption,'evidence',evidence);
    close(gcf);
end
end
