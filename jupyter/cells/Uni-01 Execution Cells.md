# Uni-01 execution cells

These cells accompany the canonical Uni-01 note. The local course adapter places each cell after its named section heading; the downloadable notebook uses these same cells. Edit this file in Obsidian to change the teaching code. Existing receiver functions remain in the parent laboratory directory.

## setup: Environment and experiment parameters
<!-- anchor: from-protocol-parameters-to-receiver-arrays -->

Start here. The receiver will be tested at 8 dB with an injected frequency offset of 23.7 kHz and a delay of 137 samples. These are experiment choices. The transmitted PCI and SFN are used to evaluate recovery, and are not passed to the receiver.

```matlab
courseRoot = pwd;
while ~isfile(fullfile(courseRoot,'publish_site.py'))
    parent = fileparts(courseRoot);
    assert(~strcmp(parent,courseRoot),'Uni01:Root','Open the notebook inside the course package.');
    courseRoot = parent;
end
addpath(fullfile(courseRoot,'matlab'));
addpath(fullfile(courseRoot,'matlab','uni01'));
assert(~isempty(which('nrPSS')),'Uni01:Toolbox','Install and license 5G Toolbox before running this lab.');
u01 = struct;
u01.c = uni01_config;
u01.snrDb = 8;
u01.cfoHz = 23700;
u01.delaySamples = 137;
disp(version)
disp(ver('5g'))
fprintf('SNR %.1f dB; CFO %.0f Hz; delay %d samples; seed %d\n',u01.snrDb,u01.cfoHz,u01.delaySamples,u01.c.seed);
```

## transmit: Generate the SS/PBCH block
<!-- anchor: build-the-broadcast-grid-and-the-received-capture -->

Generate a fresh transmission using the existing Toolbox implementation. The labels distinguish PSS, SSS, DM-RS and PBCH in the four SSB symbols. This output is computed from the current configuration.

```matlab
assert(exist('u01','var')==1 && isfield(u01,'c'),'Uni01:Order','Run the environment cell first.');
u01.t = uni01_tx(u01.c);
figure('Theme','light','Color','w','Position',[100 100 850 460]);
imagesc(0:3,0:239,u01.t.labels); axis xy;
colormap([1 1 1; .65 .72 .75; .85 .16 .11; 0 .27 .64; .46 .73 0]);
cb=colorbar; cb.Ticks=0:4; cb.TickLabels={'Unused','PSS','SSS','DM-RS','PBCH'};
xlabel('OFDM symbol within SSB'); ylabel('Subcarrier');
title('Generated SSB resource mapping'); set(gca,'FontName','Helvetica','FontSize',14);
fprintf('SSB %d x %d; sample rate %.3f MHz\n',size(u01.t.ssb),u01.t.sampleRate/1e6);
```

## channel: Create the received I/Q capture
<!-- anchor: build-the-broadcast-grid-and-the-received-capture -->

Apply the selected noise, frequency offset and sample delay. The noise variance follows the active resource element SNR definition used in the note. The plot shows the actual received complex samples.

```matlab
assert(exist('u01','var')==1 && isfield(u01,'t'),'Uni01:Order','Generate the transmission first.');
[u01.wave,u01.observation] = uni01_observe(u01.t,u01.snrDb,u01.cfoHz,u01.delaySamples,u01.c.seed);
figure('Theme','light','Color','w','Position',[100 100 850 460]);
timeMs=(0:numel(u01.wave)-1)'/u01.t.sampleRate*1e3;
plot(timeMs,real(u01.wave),'Color',[0 .27 .64]); hold on;
plot(timeMs,imag(u01.wave),'Color',[.85 .16 .11]); hold off;
xlabel('Time (ms)'); ylabel('Complex baseband amplitude'); legend('I','Q');
title('Received capture with noise, frequency offset and delay');
set(gca,'FontName','Helvetica','FontSize',14);
```

## receive: Run the receiver and inspect its PSS search
<!-- anchor: search-pss-and-coarse-frequency-together -->

This cell executes the complete existing receiver once. It displays the recorded PSS search scores; the following reading stages explain the frequency correction, SSS and channel processing performed inside that function. Only the declared receiver configuration is passed with the samples.

```matlab
assert(exist('u01','var')==1 && isfield(u01,'wave'),'Uni01:Order','Create the received capture first.');
u01.rx = uni01_rx(u01.wave,u01.c.receiver);
figure('Theme','light','Color','w','Position',[100 100 850 460]);
imagesc(0:2,u01.rx.frequencyCandidates/1e3,u01.rx.pssScores); axis xy; colorbar;
xlabel('PSS identity candidate'); ylabel('Coarse frequency candidate (kHz)');
title('Measured PSS search scores'); set(gca,'FontName','Helvetica','FontSize',14);
fprintf('Estimated CFO %.2f Hz; SSB start sample %d\n',u01.rx.frequencyOffset,u01.rx.ssbStartSample);
```

## decode: Verify the recovered broadcast message
<!-- anchor: decode-bch-and-interpret-the-recovered-fields -->

Inspect the equalized symbols and compare the decoded fields with the transmitter after reception. The acceptance check includes more than the CRC: it also verifies PCI, the block index and the broadcast fields.

```matlab
assert(exist('u01','var')==1 && isfield(u01,'rx'),'Uni01:Order','Run the receiver first.');
u01.accepted = uni01_accept(u01.rx,u01.t);
disp(table(u01.rx.cellID,u01.rx.systemFrameNumber,u01.rx.ssbIndex,~u01.rx.crcError,u01.accepted, ...
    'VariableNames',{'PCI','SFN','SSBIndex','CRCPass','FieldsMatch'}));
figure('Theme','light','Color','w','Position',[100 100 640 480]);
plot(real(u01.rx.pbchEqualized),imag(u01.rx.pbchEqualized),'.','Color',[0 .27 .64]);
axis equal; grid on; xlabel('In-phase'); ylabel('Quadrature');
title('Equalized PBCH symbols'); set(gca,'FontName','Helvetica','FontSize',14);
assert(u01.accepted,'Uni01:Recovery','The capture did not recover the expected fields. Inspect the impairment settings and search scores.');
```

## compare: Compare two noise conditions
<!-- anchor: repeated-experiments-and-observed-failures -->

Keep the transmitter and the noise seed fixed and compare two SNR values. Each point is one realization, so this comparison demonstrates receiver behaviour rather than estimating a block error probability. The note's saved curves use repeated trials.

```matlab
assert(exist('u01','var')==1 && isfield(u01,'t'),'Uni01:Order','Generate the transmission first.');
u01.compareSnr = [-18 8];
u01.compareAccepted = false(size(u01.compareSnr));
u01.compareCfo = nan(size(u01.compareSnr));
for k=1:numel(u01.compareSnr)
    [samples,~]=uni01_observe(u01.t,u01.compareSnr(k),u01.cfoHz,u01.delaySamples,u01.c.seed);
    try
        decoded=uni01_rx(samples,u01.c.receiver);
        u01.compareAccepted(k)=uni01_accept(decoded,u01.t);
        u01.compareCfo(k)=decoded.frequencyOffset;
    catch err
        fprintf('SNR %.1f dB: %s\n',u01.compareSnr(k),err.message);
    end
end
disp(table(u01.compareSnr',u01.compareAccepted',u01.compareCfo', ...
    'VariableNames',{'SNR_dB','FieldsMatch','EstimatedCFO_Hz'}));
figure('Theme','light','Color','w','Position',[100 100 850 460]);
stem(u01.compareSnr,double(u01.compareAccepted),'filled','Color',[.46 .73 0],'LineWidth',2);
ylim([-.1 1.1]); yticks([0 1]); yticklabels({'Not recovered','Recovered'});
xlabel('SNR (dB)'); title('One capture per SNR; not a probability estimate');
set(gca,'FontName','Helvetica','FontSize',14);
```

## save: Save this student's experiment
<!-- anchor: engineering-choices-and-reproducibility -->

Save the current arrays and configuration in a new student results directory. Use the page's notebook download to keep edited cells and their displayed outputs as well. Saved teacher evidence is not replaced.

```matlab
assert(exist('u01','var')==1 && isfield(u01,'rx'),'Uni01:Order','Run the receiver before saving.');
studentRoot=fullfile(courseRoot,'matlab','uni01','jupyter','student-results');
if ~isfolder(studentRoot), mkdir(studentRoot); end
u01.runDir=tempname(studentRoot); mkdir(u01.runDir);
software=ver;
save(fullfile(u01.runDir,'run.mat'),'u01','software');
fid=fopen(fullfile(u01.runDir,'config.json'),'w');
assert(fid>=0,'Uni01:Save','Could not create the configuration file.');
fwrite(fid,jsonencode(struct('config',u01.c,'snrDb',u01.snrDb,'cfoHz',u01.cfoHz, ...
    'delaySamples',u01.delaySamples,'software',software)),'char'); fclose(fid);
fprintf('Student results saved to %s\n',u01.runDir);
```
