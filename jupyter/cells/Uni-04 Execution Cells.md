# Uni-04 execution cells

These cells connect the existing PRACH, timing advance and PUSCH helpers. Edit the parameters and run in order to retain the measured arrays in the downloadable notebook.

## setup: Environment and arrival parameters
<!-- anchor: from-protocol-parameters-to-arrays -->

The waveform uses a 25 RB carrier at 15 kHz and format 0 PRACH at 1.25 kHz. PRACH SNR refers to active time sample power; PUSCH SNR refers to a modulated resource element. The injected delay represents arrival error relative to the gNB uplink reference.

```matlab
u04=struct; u04.root=pwd;
while ~isfile(fullfile(u04.root,'publish_site.py'))
    u04.parent=fileparts(u04.root);
    assert(~strcmp(u04.parent,u04.root),'Uni04:Root','Open the notebook inside the course package.');
    u04.root=u04.parent;
end
addpath(fullfile(u04.root,'matlab','uni04'));
assert(~isempty(which('nrPRACHDetect')) && ~isempty(which('nrULSCHDecoder')), ...
    'Uni04:Toolbox','Install and license 5G Toolbox before running this lab.');
u04.config=struct('delaySamples',161,'prachSnrDb',-5,'cfoHz',0, ...
    'threshold',0.02,'puschSnrREdB',15,'seed',2026090401, ...
    'mu',0,'NTAoffset',0,'compareResidualSamples',[0 20 60 120]);
assert(u04.config.delaySamples>=0 && u04.config.delaySamples<1024 && ...
    fix(u04.config.delaySamples)==u04.config.delaySamples,'Uni04:Config','Use an integer delay from 0 through 1023 samples.');
assert(u04.config.mu==0 && u04.config.NTAoffset==0,'Uni04:Config','These waveforms use mu=0 and explicit NTAoffset=0.');
disp(version); disp(ver('5g')); disp(u04.config);
```

## generate: Generate one active PRACH occasion
<!-- anchor: generate-the-preamble-and-inspect-its-structure -->

Generate the Toolbox preamble and OFDM waveform. The plot displays the actual transmitted samples, including the cyclic prefix and guard structure. The measured sample rate supplies the conversion from arrival samples to timing advance.

```matlab
assert(exist('u04','var')==1 && isfield(u04,'config'),'Uni04:Order','Run setup first.');
[u04.carrier,u04.prach,u04.tx,u04.info]=uni04_prach;
u04.Fs=u04.info.SampleRate;
u04.activePower=mean(abs(u04.tx(abs(u04.tx)>1e-14)).^2);
figure('Theme','light','Color','w');
plot((0:numel(u04.tx)-1)/u04.Fs*1e3,abs(u04.tx)); grid on;
xlabel('Time (ms)'); ylabel('Magnitude'); title('Generated PRACH waveform');
fprintf('Sample rate %.3f MHz; PRACH CP %d samples; preamble %d\n', ...
    u04.Fs/1e6,u04.info.CyclicPrefixLengths(1),u04.prach.PreambleIndex);
```

## detect: Estimate the preamble arrival
<!-- anchor: map-resources-and-construct-the-waveform -->

Inject the selected delay, frequency offset and noise before searching the 64 preambles. Correct identity and accurate arrival time are separate checks. The sample error below uses the injected delay only to evaluate the detector.

```matlab
assert(exist('u04','var')==1 && isfield(u04,'tx'),'Uni04:Order','Generate PRACH first.');
rng(u04.config.seed,'twister');
u04.rx=[zeros(u04.config.delaySamples,1);u04.tx;zeros(256,1)];
u04.sample=(0:numel(u04.rx)-1)';
u04.rx=u04.rx.*exp(1i*2*pi*u04.config.cfoHz*u04.sample/u04.Fs);
u04.nv=u04.activePower/10^(u04.config.prachSnrDb/10);
u04.rx=u04.rx+sqrt(u04.nv/2)*(randn(size(u04.rx))+1i*randn(size(u04.rx)));
[u04.index,u04.measuredSamples,u04.detection]=nrPRACHDetect(u04.carrier,u04.prach,u04.rx, ...
    'DetectionThreshold',u04.config.threshold);
assert(~isempty(u04.index),'Uni04:Detection','No preamble detected; inspect SNR, CFO and threshold.');
disp(table(u04.index,u04.measuredSamples,u04.measuredSamples-u04.config.delaySamples, ...
    'VariableNames',{'DetectedPreamble','EstimatedArrivalSamples','TimingErrorSamples'}));
figure('Theme','light','Color','w');
plot(u04.sample/u04.Fs*1e3,real(u04.rx)); grid on;
xlabel('Time (ms)'); ylabel('In-phase amplitude'); title('PRACH capture supplied to the detector');
assert(u04.index==u04.prach.PreambleIndex,'Uni04:Identity','The detected preamble identity differs from the transmitted preamble.');
```

## advance: Convert the estimate to absolute timing advance
<!-- anchor: convert-measured-arrival-into-a-command -->

The helper rounds the estimated arrival to an absolute RAR timing advance index. At this PUSCH numerology, one step is four samples. The physical residual subtracts the commanded advance from the injected delay; the estimator residual subtracts it from the detected delay. Frequency offset can make these residuals differ.

```matlab
assert(exist('u04','var')==1 && isfield(u04,'index') && ~isempty(u04.index),'Uni04:Order','Detect PRACH first.');
u04.ta=uni04_ta(u04.measuredSamples,u04.Fs,u04.config.mu,u04.config.NTAoffset);
u04.physicalResidual=u04.config.delaySamples-u04.ta.advanceSamples;
disp(table(u04.ta.command,u04.ta.advanceSamples,u04.ta.residualSamples,u04.physicalResidual, ...
    'VariableNames',{'TAcommand','AdvanceSamples','EstimatorResidualSamples','PhysicalResidualSamples'}));
figure('Theme','light','Color','w');
bar([u04.ta.residualSamples u04.physicalResidual]);
xticklabels({'From detected arrival','From injected arrival'}); ylabel('Residual (samples)');
title('Estimated and physical timing residual');
```

## uplink: Decode PUSCH with a fixed receiver window
<!-- anchor: hold-the-receiver-window-fixed -->

The helper sends the same transport block through paired arrivals before and after timing advance, using the same noise. The receiver uses its scheduled FFT window and DM-RS estimates. A passing UL-SCH CRC verifies this scheduled data block; the laboratory passes the TA value directly between its waveform experiments.

```matlab
assert(exist('u04','var')==1 && isfield(u04,'ta'),'Uni04:Order','Calculate timing advance first.');
rng(u04.config.seed+100000,'twister');
u04.pusch=uni04_pusch(u04.carrier,u04.config.delaySamples,u04.ta.advanceSamples,u04.config.puschSnrREdB);
assert(u04.pusch.correctedResidual==u04.physicalResidual,'Uni04:Residual','Physical residual accounting disagrees.');
disp(table([u04.pusch.uncorrectedCRC;u04.pusch.correctedCRC], ...
    [u04.pusch.uncorrectedBitErrors;u04.pusch.correctedBitErrors], ...
    [u04.pusch.uncorrectedEVMPercent;u04.pusch.correctedEVMPercent], ...
    'VariableNames',{'CRCError','BitErrors','RmsEVMPercent'},'RowNames',{'BeforeTA','AfterTA'}));
figure('Theme','light','Color','w'); tiledlayout(1,2);
nexttile; plot(real(u04.pusch.uncorrectedSymbols),imag(u04.pusch.uncorrectedSymbols),'.');
axis equal; grid on; xlabel('In-phase'); ylabel('Quadrature'); title('Before timing advance');
nexttile; plot(real(u04.pusch.correctedSymbols),imag(u04.pusch.correctedSymbols),'.');
axis equal; grid on; xlabel('In-phase'); ylabel('Quadrature'); title('After timing advance');
```

## compare: Measure decoding across residual delays
<!-- anchor: sweep-the-residual-rather-than-assuming-a-tolerance -->

Apply the selected residuals to otherwise matching PUSCH realizations. This diagnostic varies the channel arrival with zero applied advance. Each point is one block, so the CRC curve demonstrates timing sensitivity without estimating a block error probability.

```matlab
assert(exist('u04','var')==1 && isfield(u04,'pusch'),'Uni04:Order','Run the PUSCH pair first.');
assert(all(abs(u04.config.compareResidualSamples)<1024) && ...
    all(fix(u04.config.compareResidualSamples)==u04.config.compareResidualSamples), ...
    'Uni04:Config','Residuals must be integer samples within the channel guard.');
u04.scan=zeros(numel(u04.config.compareResidualSamples),3);
for k=1:numel(u04.config.compareResidualSamples)
    rng(u04.config.seed+100000,'twister');
    u04.trial=uni04_pusch(u04.carrier,u04.config.compareResidualSamples(k),0,u04.config.puschSnrREdB);
    u04.scan(k,:)=[u04.trial.correctedCRC u04.trial.correctedBitErrors u04.trial.correctedEVMPercent];
end
disp(array2table([u04.config.compareResidualSamples(:) u04.scan], ...
    'VariableNames',{'ResidualSamples','CRCError','BitErrors','RmsEVMPercent'}));
figure('Theme','light','Color','w');
stem(u04.config.compareResidualSamples,double(u04.scan(:,1)==0),'filled'); ylim([-.1 1.1]);
xlabel('Physical residual (samples)'); ylabel('UL-SCH CRC passed'); title('One PUSCH block per residual delay');
```

## save: Save the timing and data evidence
<!-- anchor: run-and-inspect-the-evidence -->

Save the PRACH capture, timing estimates, physical residuals and PUSCH results with their parameters and software versions in a new student directory.

```matlab
assert(exist('u04','var')==1 && isfield(u04,'scan'),'Uni04:Order','Run the residual comparison before saving.');
u04.studentRoot=fullfile(u04.root,'matlab','uni04','jupyter','student-results');
if ~isfolder(u04.studentRoot), mkdir(u04.studentRoot); end
u04.runDir=tempname(u04.studentRoot); mkdir(u04.runDir);
u04.software=ver; save(fullfile(u04.runDir,'run.mat'),'u04');
u04.fid=fopen(fullfile(u04.runDir,'config.json'),'w');
assert(u04.fid>=0,'Uni04:Save','Could not create the configuration file.');
fwrite(u04.fid,jsonencode(struct('config',u04.config,'software',u04.software)),'char'); fclose(u04.fid);
fprintf('Student results saved to %s\n',u04.runDir);
```
