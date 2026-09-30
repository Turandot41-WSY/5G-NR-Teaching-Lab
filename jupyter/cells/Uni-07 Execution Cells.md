# Uni-07 execution cells

These editable cells accompany the canonical CSI and adaptive MIMO note. They provide the webpage and downloadable notebook with actual CSI-RS measurements and five PDSCH transmissions. The helpers extract the existing experiment's processing for one channel realization.

## setup: Configure a CSI observation and feedback age
<!-- anchor: define-the-channel-and-measurement-age -->

Choose the noise reference SNR, channel correlation and age in slots. Rank threshold 5 and modulation threshold 12 dB are local engineering choices. This lab uses two transmit ports, two receive antennas and 30 kHz subcarrier spacing.

```matlab
courseRoot = pwd;
while ~isfile(fullfile(courseRoot,'publish_site.py'))
    parent = fileparts(courseRoot);
    assert(~strcmp(parent,courseRoot),'Uni07:Root','Open the notebook inside the course package.');
    courseRoot = parent;
end
addpath(fullfile(courseRoot,'matlab'));
addpath(fullfile(courseRoot,'matlab','uni07'));
addpath(fullfile(courseRoot,'matlab','uni07','jupyter'));
assert(~isempty(which('nrCSIRS')) && ~isempty(which('nrDLSCHDecoder')), ...
    'Uni07:Toolbox','Install and license 5G Toolbox and Communications Toolbox.');
u07 = struct;
u07.c=struct('seed',7007,'snrDb',15,'rho',0.9,'delaySlots',4,'rate',0.48, ...
    'RB',6,'rankThreshold',5,'modulationThresholdDb',12);
disp(version); disp(ver('5g')); disp(ver('comm')); disp(u07.c);
fprintf('Channel age factor rho^delay = %.4f\n',u07.c.rho^u07.c.delaySlots);
```

## measure: Transmit CSI-RS and estimate both channels
<!-- anchor: estimate-csi-from-transmitted-samples -->

Generate CSI-RS with Toolbox, transmit it through the old and current 2 × 2 channels, and estimate their coefficients from noisy received OFDM samples. The plot shows the actual generated reference grid. SNR sets sample noise variance 1/(Nfft × 10^(SNR/10)); channel matrix gain then changes received quality.

```matlab
assert(exist('u07','var')==1 && isfield(u07,'c'),'Uni07:Order','Run setup first.');
u07.m=uni07_student_measure(u07.c);
figure('Theme','light','Color','w','Position',[100 100 850 460]);
imagesc(0:13,0:12*u07.c.RB-1,abs(u07.m.grid(:,:,1))); axis xy; colorbar;
xlabel('OFDM symbol'); ylabel('Subcarrier'); title('Actual CSI-RS grid for transmit port one');
set(gca,'FontName','Helvetica','FontSize',14);
fprintf('Channel NMSE %.5f; Nfft %d; sample noise variance %.4g\n', ...
    u07.m.nmse,u07.m.Nfft,u07.m.sampleNoiseVariance);
disp(u07.m.Hm);
```

## codebook: Score the four rank one precoders
<!-- anchor: construct-the-actual-two-port-codebook -->

The existing two port codebook provides four allowed weights. The receiver selects the largest measured effective channel gain. PMI is printed with zero as its first index; MATLAB uses one as the first array index.

```matlab
assert(exist('u07','var')==1 && isfield(u07,'m'),'Uni07:Order','Measure CSI first.');
u07.currentScores=sum(abs(u07.m.Hm*u07.m.W).^2,1);
u07.oldScores=sum(abs(u07.m.Hold*u07.m.W).^2,1);
figure('Theme','light','Color','w','Position',[100 100 850 460]);
bar(0:3,[u07.currentScores;u07.oldScores]');
xlabel('PMI index'); ylabel('Measured effective channel power gain');
legend('Current CSI','Old CSI','Location','best'); title('Precoder selection from CSI estimates');
set(gca,'FontName','Helvetica','FontSize',14);
fprintf('Current PMI %d; delayed PMI %d\n',u07.m.pmi-1,u07.m.oldpmi-1);
assert(all(abs(sum(abs(u07.m.W).^2,1)-1)<1e-10),'Uni07:Power','Codebook columns need unit power.');
```

## transmit: Execute all five precoding modes
<!-- anchor: define-the-five-implemented-modes -->

Each mode sends and decodes one actual LDPC transport block through the same current channel. Ideal SVD uses true channel coefficients only to select the precoder; its receiver still estimates the effective channel from DM-RS. Delayed PMI uses the old index with current measured quality for modulation. Adaptive rank uses the stated engineering threshold. Seeds are reset per mode for reproducibility; payload lengths can differ.

```matlab
assert(exist('u07','var')==1 && isfield(u07,'currentScores'),'Uni07:Order','Score the codebook first.');
u07.r=cell(1,5); u07.rows=zeros(5,8); u07.modeNames=strings(5,1);
for k=1:5
    r=uni07_student_trial(u07.c,u07.m,k); u07.r{k}=r; u07.modeNames(k)=r.mode;
    u07.rows(k,:)=[r.rank r.qm r.predictedDb r.gain r.tbs ~r.crc r.bitErrors r.deliveredBits];
end
u07.results=array2table(u07.rows,'VariableNames', ...
    {'Rank','BitsPerSymbol','PredictedSNR_dB','TrueGain','TBS','CRCPass','BitErrors','DeliveredBits'});
u07.results=addvars(u07.results,u07.modeNames,'Before',1,'NewVariableNames','Mode');
disp(u07.results);
fprintf('Five transport blocks in one channel realization; these outcomes do not estimate BLER.\n');
```

## receive: Inspect the current PMI reception
<!-- anchor: follow-one-actual-array-through-the-receiver -->

Select a mode number from 1 to 5 to inspect its equalized symbols. The decoder uses the channel and noise estimates from that PDSCH transmission. CRC and decoded bit differences are both reported.

```matlab
assert(exist('u07','var')==1 && isfield(u07,'r'),'Uni07:Order','Transmit the five modes first.');
u07.inspectMode=3; r=u07.r{u07.inspectMode};
figure('Theme','light','Color','w','Position',[100 100 640 480]);
plot(real(r.eq(:)),imag(r.eq(:)),'.','Color',[0 .27 .64]);
axis equal; grid on; xlabel('In-phase'); ylabel('Quadrature');
title(sprintf('%s: rank %d, %s',r.mode,r.rank,r.modulation));
set(gca,'FontName','Helvetica','FontSize',14);
fprintf('CRC pass %d; bit errors %d/%d; RMS EVM %.2f%%\n',~r.crc,r.bitErrors,r.tbs,r.evmPercent);
assert(numel(r.decoded)==r.tbs,'Uni07:Length','Decoded length differs from TBS.');
```

## compare: Compare delivered bits and check the decisions
<!-- anchor: decoding-failures-goodput-and-finite-samples -->

Delivered bits count only CRC passes in this execution. With one block per mode and one channel realization, the bars cannot establish a reliability ranking or error probability. The checks also verify that delayed PMI kept current quality and that every precoder uses total power one.

```matlab
assert(exist('u07','var')==1 && isfield(u07,'inspectMode'),'Uni07:Order','Inspect reception first.');
figure('Theme','light','Color','w','Position',[100 100 850 460]);
bar(1:5,u07.results.DeliveredBits,'FaceColor',[.46 .73 0]);
xticks(1:5); xticklabels(u07.modeNames); xtickangle(20);
ylabel('CRC accepted payload (bits)'); title('One block per mode in one channel realization');
set(gca,'FontName','Helvetica','FontSize',14);
u07.delayedQualityDb=10*log10(sum(abs(u07.m.Hm*u07.r{4}.w).^2,'all'))+u07.c.snrDb;
assert(abs(u07.delayedQualityDb-u07.r{4}.predictedDb)<1e-10,'Uni07:Quality','Delayed PMI must use current quality.');
for k=1:5
    assert(abs(sum(abs(u07.r{k}.w).^2,'all')-1)<1e-10);
    assert(u07.r{k}.deliveredBits==u07.r{k}.tbs*(1-double(u07.r{k}.crc)));
end
fprintf('CSI NMSE %.5f; PMI current/old %d/%d; adaptive rank %d\n', ...
    u07.m.nmse,u07.m.pmi-1,u07.m.oldpmi-1,u07.r{5}.rank);
fprintf('Rank and modulation thresholds are engineering choices, not standardized receiver rules.\n');
```

## save: Save this student's CSI and MIMO experiment
<!-- anchor: reproduce-the-experiment-and-trace-its-decisions -->

Save both channel estimates, the codebook scores, transmitted and received arrays, decoded payloads, parameters and software versions. The downloaded notebook retains edited cells and displayed results.

```matlab
assert(exist('u07','var')==1 && isfield(u07,'delayedQualityDb'),'Uni07:Order','Run the comparison before saving.');
studentRoot=fullfile(courseRoot,'matlab','uni07','jupyter','student-results');
if ~isfolder(studentRoot), mkdir(studentRoot); end
u07.runDir=tempname(studentRoot); mkdir(u07.runDir);
software=ver;
save(fullfile(u07.runDir,'run.mat'),'u07','software');
fid=fopen(fullfile(u07.runDir,'config.json'),'w');
assert(fid>=0,'Uni07:Save','Could not create the configuration file.');
fwrite(fid,jsonencode(struct('config',u07.c,'inspectMode',u07.inspectMode,'software',software)),'char'); fclose(fid);
fprintf('Saved five PDSCH blocks and one paired CSI observation to %s\n',u07.runDir);
fprintf('CRC passes %d/5 across different modes; this fraction is not a BLER estimate.\n',sum(u07.results.CRCPass));
```
