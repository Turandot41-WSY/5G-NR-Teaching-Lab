function uni04_expansion
% Additional actual Toolbox calculations and trials; pilot files are retained.
base=fileparts(mfilename('fullpath')); diary(fullfile(base,'results','expansion.log'));
clean=onCleanup(@()diary('off')); %#ok<NASGU>
t0=tic; s=load(fullfile(base,'results','run.mat')); seed=2026090704;
[carrier,prach,w,info]=uni04_prach; [seq,si]=nrPRACH(carrier,prach);
N=prach.LRA; n=(0:N-1)'; u=si.RootSequence;
x=exp(-1i*pi*u*n.*(n+1)/N); shifted=x(mod(n+si.CyclicShift,N)+1);
% nrPRACH returns the unnormalized DFT of the shifted Zadoff Chu sequence.
formula=fft(shifted); sequenceError=max(abs(seq(1:N)-formula));
fprintf('Root %d shift %d maximum formula error %.4g\n',u,si.CyclicShift,sequenceError);
assert(sequenceError<1e-10);
delayValues=(-60:5:60)'; rows=cell(numel(delayValues),1);
for k=1:numel(delayValues)
    rng(seed+k,'twister'); r=uni04_pusch(carrier,delayValues(k),0,25);
    rows{k}=table(delayValues(k),seed+k,r.correctedCRC,r.correctedEVMPercent,r.correctedBitErrors, ...
        'VariableNames',{'residualSamples','seed','crc','evmPercent','bitErrors'});
end
delaySweep=vertcat(rows{:}); rows=cell(180,1); serial=0;
for snr=[-5 0 5 10 15 20]
    for trial=1:30
        serial=serial+1; rng(seed+1000+serial,'twister');
        r=uni04_pusch(carrier,161,160,snr);
        rows{serial}=table(snr,trial,seed+1000+serial,r.correctedCRC,r.correctedEVMPercent, ...
            r.correctedBitErrors,'VariableNames',{'snrREdB','trial','seed','crc','evmPercent','bitErrors'});
    end
end
snrTrials=vertcat(rows{:}); writetable(delaySweep,fullfile(base,'results','expansion_delay.csv'));
writetable(snrTrials,fullfile(base,'results','expansion_snr.csv'));
out=fullfile(base,'..','..','notes','99 Attachments','5G','Uni Labs','Uni-04'); figures={};
set(groot,'defaultAxesFontSize',18,'defaultAxesFontName','Helvetica','defaultTextFontSize',18);
blue=[.15 .33 .52]; red=[.73 .20 .20];
f=fig(); plot(n,real(x),'-o','Color',blue,'MarkerSize',4,'MarkerFaceColor',blue); xlim([0 100]); xlabel('Sequence sample'); ylabel('Real amplitude'); title(sprintf('Zadoff Chu root u = %d: first 101 samples',u)); saveplot('Root Sequence Samples');
f=fig(); plot(n,angle(x),'Color',blue); xlim([0 100]); xlabel('Sequence sample'); ylabel('Wrapped phase (rad)'); title('Quadratic phase of the PRACH root'); saveplot('Root Sequence Phase');
f=fig(); plot(n,abs(x),'Color',blue); hold on; plot(n,abs(formula)/sqrt(N),'--','Color',red); ylim([.9 1.1]); xlabel('Sequence or DFT bin'); ylabel('Magnitude'); legend('Root sequence','DFT divided by sqrt(839)'); title('Constant magnitude: time sequence and PRACH symbols'); saveplot('Sequence and DFT Magnitudes');
f=fig(); ac=abs(ifft(abs(fft(x)).^2))/N; stem(0:80,ac(1:81),'.','Color',blue); xlabel('Circular shift (samples)'); ylabel('Normalized correlation magnitude'); title('Root autocorrelation from actual sequence'); saveplot('Sequence Autocorrelation');
f=fig(); pp=prach; roots=zeros(64,1); shifts=roots;
for k=0:63, pp.PreambleIndex=k; [~,ii]=nrPRACH(carrier,pp); roots(k+1)=ii.RootSequence; shifts(k+1)=ii.CyclicShift; end
yyaxis left; stairs(0:63,roots,'LineWidth',1.7); ylabel('Physical root u'); yyaxis right; stem(0:63,shifts,'.'); ylabel('Cyclic shift (samples)'); xlabel('Preamble index'); title('One logical root setting can use several physical roots'); saveplot('Preamble Root and Shift Assignment');
f=fig(); g=nrPRACHGrid(carrier,prach); g(nrPRACHIndices(carrier,prach))=seq;
imagesc(0:size(g,2)-1,0:size(g,1)-1,abs(g)); axis xy; xlabel('PRACH symbol'); ylabel('PRACH frequency bin'); colorbar; title('Generated PRACH resource grid: occupied bins'); text(0,size(g,1)*0.6,sprintf('%d of %d bins occupied',nnz(abs(g)>0),numel(g)),'HorizontalAlignment','center','FontSize',18,'BackgroundColor','w','EdgeColor','k'); saveplot('PRACH Resource Occupancy');
f=fig(); z=fftshift(fft(w,32768)); freq=(-16384:16383)'*info.SampleRate/32768/1e6;
plot(freq,20*log10(max(abs(z),1e-12)/max(abs(z))),'Color',blue); xlim([-2 2]); ylim([-90 5]); xlabel('Baseband frequency (MHz)'); ylabel('Relative amplitude (dB)'); title('Actual PRACH waveform spectrum'); saveplot('PRACH Waveform Spectrum');
f=fig(); tr=s.prachTrials; ix=tr.family=="SNR" & tr.snrSampledB==-25 & tr.detected;
histogram(tr.offsetSamples(ix)-161,'FaceColor',blue); xlabel('Timing error (samples)'); ylabel('Detected trials'); title('Timing estimates conditional on detection at -25 dB sample SNR'); saveplot('Detection Timing Error Distribution');
f=fig(); ix=tr.family=="CFO" & tr.detected; scatter(tr.cfoHz(ix),tr.offsetSamples(ix)-161,20,blue,'filled'); xlabel('Carrier frequency offset (Hz)'); ylabel('Timing error (samples)'); title('Frequency error becomes timing ambiguity'); saveplot('Frequency Offset Timing Scatter');
f=fig(); r=s.representative; starts=r.fftStartSamples; ends=starts+r.Nfft-1;
plot(0:13,starts,'-o','Color',blue); hold on; plot(0:13,ends,'--s','Color',red); xlabel('OFDM symbol'); ylabel('Buffer sample index (zero based)'); legend('FFT start','FFT inclusive end','Location','northwest'); title('Fixed gNB FFT windows for all fourteen symbols'); saveplot('Slot FFT Window Coordinates');
f=fig(); plot(delaySweep.residualSamples,delaySweep.evmPercent,'-o','Color',blue); xline(0,'--k'); xlabel('Residual arrival delay (samples)'); ylabel('Equalized EVM (%)'); title('Timing tolerance of the fixed receiver: one block per point, 25 dB'); saveplot('Residual Timing EVM Sweep');
f=fig(); stem(delaySweep.residualSamples,delaySweep.crc,'filled','Color',red); ylim([-.1 1.2]); xlabel('Residual arrival delay (samples)'); ylabel('CRC failure (0 or 1)'); title('Individual UL-SCH outcomes across arrival offsets'); saveplot('Residual Timing CRC Sweep');
snrs=unique(snrTrials.snrREdB); err=zeros(size(snrs)); lo=err; hi=err;
for k=1:numel(snrs), b=snrTrials(snrTrials.snrREdB==snrs(k),:); err(k)=sum(b.crc)/height(b); [lo(k),hi(k)]=uni04_wilson(sum(b.crc),height(b)); end
f=fig(); errorbar(snrs,err,err-lo,hi-err,'-o','Color',blue,'LineWidth',1.6); ylim([-.05 1.05]); xlabel('PUSCH SNR per resource element (dB)'); ylabel('UL-SCH BLER'); title('Measured TA applied: 30 fresh blocks per SNR, 95% Wilson intervals'); saveplot('Aligned PUSCH SNR and BLER');
f=fig(); scatter(snrTrials.snrREdB,snrTrials.evmPercent,22,blue,'filled'); xlabel('SNR per resource element (dB)'); ylabel('Equalized EVM (%)'); title('Every aligned PUSCH trial: equalizer error'); saveplot('Aligned PUSCH EVM Distribution');
f=fig(); scatter(snrTrials.snrREdB,snrTrials.bitErrors,22,red,'filled'); xlabel('SNR per resource element (dB)'); ylabel('Decoded bit errors per 768 bit block'); title('Decoder outcomes behind the CRC statistics'); saveplot('Aligned PUSCH Bit Error Counts');
f=fig(); h=s.representative.correctedSymbols./s.representative.transmitSymbols;
scatter(real(h),imag(h),7,blue,'filled'); axis equal; xlabel('Real equalized symbol ratio'); ylabel('Imaginary equalized symbol ratio'); title('Residual amplitude and phase after DM-RS estimation and MMSE'); saveplot('Equalized Symbol Ratio');
elapsedSeconds=toc(t0); software=ver;
save(fullfile(base,'results','expansion.mat'),'delaySweep','snrTrials','sequenceError','figures','seed','software','elapsedSeconds','x','formula','roots','shifts');
fprintf('Expansion elapsed %.2f seconds.\n',elapsedSeconds); test_expansion; uni_lab_provenance(base);
    function h=fig()
        h=pubfig.new('wide'); grid on; box on;
    end
    function saveplot(name)
        file=['UNI-04 - ' name ' v1.png']; figures{end+1}=file;
        pubfig.export(f,fullfile(out,file)); close(f);
    end
end
