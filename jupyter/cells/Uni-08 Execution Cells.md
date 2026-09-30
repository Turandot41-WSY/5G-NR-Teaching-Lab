# Uni-08 execution cells

These cells run the existing access subset once and then inspect its retained arrays. The worker contains the access prefix of the original experiment, before its 120 conditional transport pairs. RAR and Msg4 use actual PDCCH; their control resources and the PUCCH resource are given explicitly. Later grants are supplied directly. The RRC/SRB1 implementation carries a selected message and header subset with opaque NAS bytes; the final transport blocks are not DRB or IP traffic.

## setup: Configure the access capture and dependencies
<!-- anchor: protocol-parameters-and-the-access-calendar -->

Set the broadcast capture impairments here. The following packet and control fixtures retain their original 20 dB settings. The experiment requires the Uni-03 MathWorks example helpers and a Python interpreter containing pycrate; the default below uses the existing laboratory environment. The original transmitter fixes its own seed at 63003.

```matlab
courseRoot=pwd;
while ~isfile(fullfile(courseRoot,'publish_site.py'))
    parent=fileparts(courseRoot);
    assert(~strcmp(parent,courseRoot),'Uni08:Root','Open the notebook inside the course package.');
    courseRoot=parent;
end
addpath(fullfile(courseRoot,'matlab'));
addpath(fullfile(courseRoot,'matlab','uni08','jupyter'));
addpath(fullfile(courseRoot,'matlab','uni08'),fullfile(courseRoot,'matlab','uni03'),fullfile(courseRoot,'matlab','uni04'));
assert(~isempty(which('nrPRACH')),'Uni08:Toolbox','Install and license 5G Toolbox.');
uni03_setup;
u08=struct;
u08.cfg=struct('snrDB',20,'cfoHz',3400,'delaySamples',19, ...
    'python',course_python);
assert(isfile(u08.cfg.python),'Uni08:Python','Set u08.cfg.python to Python with pycrate installed.');
disp(version); disp(ver('5g')); disp(u08.cfg);
```

## access: Execute the ordered waveform and message chain
<!-- anchor: recover-the-common-cell-configuration -->

This cell executes SSB/MIB and SIB1 reception, PRACH detection, RAR, Msg3, Msg4, PUCCH ACK, RRCSetupComplete and the first DL/UL transport blocks. It also evaluates all seven procedural cases. Each stage runs inside the worker once; the later cells inspect those actual arrays. Codec intermediates are written into a new student run directory.

```matlab
assert(exist('u08','var')==1 && isfield(u08,'cfg'),'Uni08:Order','Run setup first.');
studentRoot=fullfile(courseRoot,'matlab','uni08','jupyter','student-results');
if ~isfolder(studentRoot), mkdir(studentRoot); end
u08.runDir=tempname(studentRoot); mkdir(u08.runDir);
u08.access=uni08_access_experiment(u08.cfg,u08.runDir);
disp(table(u08.access.m.cellID,u08.access.m.systemFrameNumber,u08.access.prachTimeMS,u08.access.raRNTI, ...
    'VariableNames',{'PCI','RecoveredSFN','PRACHTimeMs','RARIdentity'}));
figure('Theme','light','Color','w','Position',[100 100 850 460]);
imagesc(abs(u08.access.grid)); axis xy; colorbar;
xlabel('Recovered OFDM symbol'); ylabel('Capture subcarrier'); title('Received broadcast grid after synchronization');
set(gca,'FontName','Helvetica','FontSize',14);
```

## timing: Inspect PRACH timing and the decoded RAR
<!-- anchor: interpret-the-recovered-rar -->

The recovered SFN 426 determines the next PRACH at 79 ms. The measured arrival is converted to TA command 80, advancing 320 samples and leaving one sample of residual delay. Read the decoded RAR fields beside the actual delayed PRACH capture.

```matlab
assert(exist('u08','var')==1 && isfield(u08,'access'),'Uni08:Order','Execute the access chain first.');
disp(u08.access.ta); disp(u08.access.rar);
assert(u08.access.prachTimeMS==79 && u08.access.raRNTI==127,'Uni08:Calendar','Inspect the recovered SFN and PRACH calendar.');
figure('Theme','light','Color','w','Position',[100 100 850 460]);
plot((0:numel(u08.access.prx)-1)/u08.access.pinfo.SampleRate*1e3,abs(u08.access.prx),'Color',[0 .27 .64]);
xlabel('Time within PRACH capture (ms)'); ylabel('Received magnitude'); title('PRACH with the injected arrival delay');
set(gca,'FontName','Helvetica','FontSize',14);
```

## messages: Inspect control, identity and completion evidence
<!-- anchor: deliver-rrcsetupcomplete -->

The six transport receivers retain CRC, payload and equalized symbols. The UPER verifier has checked the recovered request, setup and complete messages. RAR/Msg4 controls use one known candidate with explicitly supplied resources; the ACK is transmitted in slot 175.

```matlab
assert(exist('u08','var')==1 && isfield(u08,'access'),'Uni08:Order','Execute the access chain first.');
disp(u08.access.events);
disp(fileread(fullfile(u08.runDir,'rrc-decoded.json')));
assert(u08.access.controls.ack.slot==175 && u08.access.controls.ack.rxACK==1,'Uni08:ACK','Check Msg4 feedback.');
assert(isequal(u08.access.slots,[161 165 170 176 180 185]),'Uni08:Slots','Check the access schedule.');
figure('Theme','light','Color','w','Position',[100 100 850 460]);
bar(u08.access.events.evmPercent,'FaceColor',[.46 .73 0]);
xticks(1:6); xticklabels({'RAR','Msg3','Msg4','Complete','First DL','First UL'});
ylabel('Measured EVM (%)'); title('Practical DM-RS channel estimation across six data bursts');
set(gca,'FontName','Helvetica','FontSize',14);
```

## transfer: Verify the first bidirectional transport blocks
<!-- anchor: check-the-first-bidirectional-transport-blocks -->

Both final packets carry 256 generated payload bits after completion. Their successful decoding verifies this configured radio transport subset. The constellation points come from the two separate burst receivers.

```matlab
assert(exist('u08','var')==1 && isfield(u08,'access'),'Uni08:Order','Execute the access chain first.');
u08.accepted=u08.access.states.connected && u08.access.states.firstDL && u08.access.states.firstUL;
assert(u08.accepted && all(cellfun(@(r)r.crc==0 && r.bitErrors==0,u08.access.packets)),'Uni08:Recovery','Inspect the failed transport stage.');
disp(u08.access.states.trace');
figure('Theme','light','Color','w','Position',[100 100 850 460]);
tiledlayout(1,2);
for k=5:6
    nexttile; plot(real(u08.access.packets{k}.equalized),imag(u08.access.packets{k}.equalized),'.','Color',[0 .27 .64]);
    axis equal; grid on; xlabel('In-phase'); ylabel('Quadrature'); title(u08.access.names(k));
    set(gca,'FontName','Helvetica','FontSize',14);
end
```

## failures: Inspect seven guarded state outcomes
<!-- anchor: inject-procedural-failures -->

The original state function reuses the actual recovered packets while injecting missing responses, identity errors or CRC failures into its transition guards. These are deterministic procedural checks. Their observation times are timer and schedule outcomes, not measured latency distributions.

```matlab
assert(exist('u08','var')==1 && isfield(u08,'access'),'Uni08:Order','Execute the access chain first.');
disp(u08.access.failures);
assert(height(u08.access.failures)==7 && all(u08.access.failures.passed),'Uni08:States','A procedural guard check failed.');
figure('Theme','light','Color','w','Position',[100 100 850 460]);
barh(u08.access.failures.observationTimeMs,'FaceColor',[.85 .16 .11]);
yticks(1:7); yticklabels(u08.access.failures.scenario);
xlabel('Observation time from recovered frame origin (ms)'); title('Success and six injected procedural failures');
set(gca,'FontName','Helvetica','FontSize',12);
```

## save: Save the access experiment and software versions
<!-- anchor: reproduce-the-run -->

Store the arrays and software information beside this run's decoded messages. Download the notebook to retain edited cells and visible outputs. The note's 120 conditional transport pairs remain a separate experiment from this access walkthrough.

```matlab
assert(exist('u08','var')==1 && isfield(u08,'accepted') && u08.accepted,'Uni08:Order','Verify the first bidirectional blocks before saving.');
software=ver;
save(fullfile(u08.runDir,'run.mat'),'u08','software','-v7.3');
writetable(u08.access.events,fullfile(u08.runDir,'events.csv'));
writetable(u08.access.failures,fullfile(u08.runDir,'failures.csv'));
fprintf('Student results saved to %s\n',u08.runDir);
```
