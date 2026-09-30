# Uni-06 execution cells

These editable cells accompany the canonical power control note and supply the webpage and downloadable notebook. The student helper extracts one actual PUSCH transmission from the existing experiment. Each decoder outcome is one transport block; use the note's repeated trials for error probability estimates.

## setup: Configure the uplink experiment
<!-- anchor: convert-a-grant-into-transmit-power -->

Choose allocated RBs, effective path loss, compensation factor and the UE power cap. The carrier remains 24 RB at 30 kHz. The default allocation uses six RBs and a QPSK transport block at target code rate 0.48.

```matlab
courseRoot = pwd;
while ~isfile(fullfile(courseRoot,'publish_site.py'))
    parent = fileparts(courseRoot);
    assert(~strcmp(parent,courseRoot),'Uni06:Root','Open the notebook inside the course package.');
    courseRoot = parent;
end
addpath(fullfile(courseRoot,'matlab'));
addpath(fullfile(courseRoot,'matlab','uni06'));
addpath(fullfile(courseRoot,'matlab','uni06','jupyter'));
assert(~isempty(which('nrPUSCH')) && ~isempty(which('nrULSCHDecoder')), ...
    'Uni06:Toolbox','Install and license 5G Toolbox and Communications Toolbox.');
u06 = struct;
u06.c=struct('seed',6007,'mu',1,'p0dBm',-90,'pmaxdBm',23,'noiseFiguredB',5, ...
    'RB',6,'lossdB',115,'alpha',1,'rate',0.48);
disp(version); disp(ver('5g')); disp(ver('comm'));
disp(u06.c);
```

## power: Inspect the requested and capped powers
<!-- anchor: apply-the-power-clamp -->

Evaluate the existing power function over editable loss values. The command contains the bandwidth term, fractional path loss compensation and the configured reference power. The cap limits the radiated total power in dBm.

```matlab
assert(exist('u06','var')==1 && isfield(u06,'c'),'Uni06:Order','Run setup first.');
u06.lossSweep=90:5:135;
[u06.powerSweep,u06.commandSweep]=uni06_power(u06.lossSweep,u06.c.alpha,u06.c.RB, ...
    u06.c.mu,u06.c.p0dBm,u06.c.pmaxdBm,0,0);
figure('Theme','light','Color','w','Position',[100 100 850 460]);
plot(u06.lossSweep,u06.commandSweep,'--',u06.lossSweep,u06.powerSweep,'-o','LineWidth',2);
grid on; xlabel('Effective path loss (dB)'); ylabel('Power (dBm)');
legend('Requested power','Capped transmit power','Location','best');
title('PUSCH power command and UE power cap');
set(gca,'FontName','Helvetica','FontSize',14);
assert(all(u06.powerSweep<=u06.c.pmaxdBm),'Uni06:Cap','Power cap was exceeded.');
```

## noise: Convert the link budget into active RE SNR
<!-- anchor: turn-effective-loss-into-decoder-noise -->

Integrated noise uses allocated bandwidth in hertz and noise figure in dB. Received SNR is transmit dBm minus path loss dB minus noise dBm. The waveform has normalized attenuation; its noise variance will be 1/(Nfft × 10^(SNR/10)).

```matlab
assert(exist('u06','var')==1 && isfield(u06,'powerSweep'),'Uni06:Order','Run the power cell first.');
u06.bandwidthHz=u06.c.RB*12*30e3;
u06.noiseDbm=-174+10*log10(u06.bandwidthHz)+u06.c.noiseFiguredB;
u06.snrSweep=u06.powerSweep-u06.lossSweep-u06.noiseDbm;
disp(table(u06.bandwidthHz,u06.noiseDbm,'VariableNames',{'AllocatedBandwidth_Hz','IntegratedNoise_dBm'}));
figure('Theme','light','Color','w','Position',[100 100 850 460]);
plot(u06.lossSweep,u06.snrSweep,'-o','LineWidth',2,'Color',[0 .27 .64]);
grid on; xlabel('Effective path loss (dB)'); ylabel('Active RE SNR (dB)');
title('Receive SNR from the power and noise budget');
set(gca,'FontName','Helvetica','FontSize',14);
```

## transmit: Generate and decode one actual PUSCH block
<!-- anchor: generate-and-decode-real-uplink-arrays -->

The helper performs UL-SCH LDPC coding, QPSK, DM-RS mapping, OFDM, noise injection, channel estimation, MMSE equalization and LDPC decoding. The displayed grid comes from this execution. Change parameters in setup and rerun the dependent cells to obtain another experiment.

```matlab
assert(exist('u06','var')==1 && isfield(u06,'snrSweep'),'Uni06:Order','Run the noise cell first.');
u06.r=uni06_student_trial(u06.c);
figure('Theme','light','Color','w','Position',[100 100 850 460]);
imagesc(0:13,0:287,abs(u06.r.grid)); axis xy; colorbar;
xlabel('OFDM symbol'); ylabel('Subcarrier'); title('Actual PUSCH and DM-RS grid');
set(gca,'FontName','Helvetica','FontSize',14);
fprintf('Power %.2f dBm; SNR %.2f dB; Nfft %d; sample noise variance %.4g\n', ...
    u06.r.powerDbm,u06.r.snrDb,u06.r.Nfft,u06.r.sampleNoiseVariance);
fprintf('TBS %d bits; CRC pass %d; bit errors %d\n',u06.r.tbs,~u06.r.crc,u06.r.bitErrors);
```

## compare: Decode one block at each selected loss
<!-- anchor: count-decoded-blocks-and-delivered-bits -->

Use the same seed and allocation at three losses. Each value is a single block outcome, so a successful point does not establish zero error probability. The full note reports 24 trials per condition with confidence intervals.

```matlab
assert(exist('u06','var')==1 && isfield(u06,'r'),'Uni06:Order','Run the PUSCH cell first.');
u06.compareLoss=[90 120 135]; u06.comparison=cell(size(u06.compareLoss));
u06.compareRows=zeros(numel(u06.compareLoss),6);
for k=1:numel(u06.compareLoss)
    c=u06.c; c.lossdB=u06.compareLoss(k);
    r=uni06_student_trial(c); u06.comparison{k}=r;
    u06.compareRows(k,:)=[c.lossdB r.powerDbm r.snrDb ~r.crc r.bitErrors r.evmPercent];
end
disp(array2table(u06.compareRows,'VariableNames', ...
    {'Loss_dB','TransmitPower_dBm','SNR_dB','CRCPass','BitErrors','EVM_percent'}));
figure('Theme','light','Color','w','Position',[100 100 850 460]);
stem(u06.compareRows(:,1),u06.compareRows(:,4),'filled','LineWidth',2,'Color',[.46 .73 0]);
ylim([-.1 1.1]); yticks([0 1]); yticklabels({'CRC failure','CRC pass'});
xlabel('Effective path loss (dB)'); title('One PUSCH block per loss; no BLER estimate');
set(gca,'FontName','Helvetica','FontSize',14);
```

## inspect: Examine the equalized symbols
<!-- anchor: inspect-what-the-decoder-sees -->

The constellation uses the selected setup condition. RMS EVM measures the equalized symbols against their transmitted values. Those values are used after reception for evaluation.

```matlab
assert(exist('u06','var')==1 && isfield(u06,'comparison'),'Uni06:Order','Run the comparison cell first.');
figure('Theme','light','Color','w','Position',[100 100 640 480]);
plot(real(u06.r.eq),imag(u06.r.eq),'.','Color',[0 .27 .64]);
axis equal; grid on; xlabel('In-phase'); ylabel('Quadrature');
title(sprintf('Equalized PUSCH at %.1f dB path loss',u06.c.lossdB));
set(gca,'FontName','Helvetica','FontSize',14);
fprintf('RMS EVM %.2f%%; CRC pass %d; decoded bit errors %d/%d\n', ...
    u06.r.evmPercent,~u06.r.crc,u06.r.bitErrors,u06.r.tbs);
assert(numel(u06.r.decoded)==u06.r.tbs,'Uni06:Length','Decoded block length differs from TBS.');
assert(abs(u06.r.snrDb-(u06.r.powerDbm-u06.c.lossdB-u06.r.noiseDbm))<1e-10);
```

## save: Save this student's power and coverage experiment
<!-- anchor: reproduce-the-result-and-test-its-limits -->

Save the current arrays, comparison blocks, parameters and software versions. Download the notebook to retain the edited cells and their displayed outputs.

```matlab
assert(exist('u06','var')==1 && isfield(u06,'comparison'),'Uni06:Order','Run the comparison before saving.');
studentRoot=fullfile(courseRoot,'matlab','uni06','jupyter','student-results');
if ~isfolder(studentRoot), mkdir(studentRoot); end
u06.runDir=tempname(studentRoot); mkdir(u06.runDir);
software=ver;
save(fullfile(u06.runDir,'run.mat'),'u06','software');
fid=fopen(fullfile(u06.runDir,'config.json'),'w');
assert(fid>=0,'Uni06:Save','Could not create the configuration file.');
fwrite(fid,jsonencode(struct('config',u06.c,'compareLoss',u06.compareLoss,'software',software)),'char'); fclose(fid);
fprintf('Saved one setup block and %d comparison blocks to %s\n',numel(u06.comparison),u06.runDir);
fprintf('Setup CRC pass %d; bit errors %d; power %.2f <= %.2f dBm. No BLER estimate.\n', ...
    ~u06.r.crc,u06.r.bitErrors,u06.r.powerDbm,u06.c.pmaxdBm);
```
