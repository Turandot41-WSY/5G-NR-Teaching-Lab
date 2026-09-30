# Uni-03 execution cells

These cells generate and receive the existing broadcast waveform. The page and downloadable notebook share this editable source.

## setup: Environment and capture parameters
<!-- anchor: convert-recovered-mib-fields-into-a-monitoring-region -->

The laboratory requires 5G Toolbox and the MathWorks cell search example helpers configured by `uni03_setup`. The current helper path targets the installed R2026a example. Edit the capture impairments below. Optional ASN.1 parsing requires the laboratory's Python environment with pycrate; MATLAB transport decoding runs with that option disabled.

```matlab
u03=struct; u03.root=pwd;
while ~isfile(fullfile(u03.root,'publish_site.py'))
    u03.parent=fileparts(u03.root);
    assert(~strcmp(u03.parent,u03.root),'Uni03:Root','Open the notebook inside the course package.');
    u03.root=u03.parent;
end
addpath(fullfile(u03.root,'matlab'));
u03.lab=fullfile(u03.root,'matlab','uni03'); addpath(u03.lab);
assert(~isempty(which('nrDLSCHDecoder')),'Uni03:Toolbox','Install and license 5G Toolbox before running this lab.');
uni03_setup;
u03.config=struct('snrDb',20,'cfoHz',3400,'delaySamples',19,'noiseSeed',63003, ...
    'wrongSIRNTI',65534,'parseASN1',false);
u03.config.python=course_python;
assert(u03.config.delaySamples>=0 && fix(u03.config.delaySamples)==u03.config.delaySamples, ...
    'Uni03:Config','The capture delay must be a nonnegative integer.');
disp(version); disp(ver('5g')); disp(u03.config);
```

## transmit: Generate the broadcast waveform
<!-- anchor: recover-the-inputs-before-applying-a-table -->

The transmitter generates an SSB plus PDCCH and PDSCH in a partial 28 RB observation. Its 400 SIB1 UPER bits occupy a 528 bit transport block. The helper fixes the broadcast configuration and transmitter seed; the receiver later reconstructs its monitoring region from a newly recovered MIB.

```matlab
assert(exist('u03','var')==1 && isfield(u03,'config'),'Uni03:Order','Run setup first.');
u03.tx=uni03_tx;
figure('Theme','light','Color','w');
imagesc(0:size(u03.tx.grid,2)-1,0:size(u03.tx.grid,1)-1,abs(u03.tx.grid)); axis xy; colorbar;
xlabel('OFDM symbol from frame start'); ylabel('Capture subcarrier'); title('Generated broadcast grid');
fprintf('Sample rate %.3f MHz; transport block %d bits; SIB1 %d bits\n', ...
    u03.tx.sampleRate/1e6,numel(u03.tx.transportBits),u03.tx.sib1BitLength);
```

## acquire: Recover timing, frequency and MIB
<!-- anchor: separate-frequency-placement-from-monitoring-time -->

Apply noise, delay and frequency offset to the transmitted time samples. Cell search estimates the impairments and recovers the MIB. The frame origin uses the known SSB placement relative to the frame; the injected delay does not select the receiver's FFT window.

```matlab
assert(exist('u03','var')==1 && isfield(u03,'tx'),'Uni03:Order','Generate the waveform first.');
rng(u03.config.noiseSeed,'twister');
u03.wave=[zeros(u03.config.delaySamples,1);u03.tx.waveform;zeros(256,1)];
u03.sample=(0:numel(u03.wave)-1)';
u03.wave=u03.wave.*exp(1i*2*pi*u03.config.cfoHz*u03.sample/u03.tx.sampleRate);
u03.sigma=sqrt(1/(2*u03.tx.ofdmInfo.Nfft*10^(u03.config.snrDb/10)));
u03.wave=u03.wave+u03.sigma*(randn(size(u03.wave))+1i*randn(size(u03.wave)));
u03.receiver=u03.tx.config.receiver; u03.receiver.sampleRate=u03.tx.sampleRate;
u03.mib=uni01_rx(u03.wave,u03.receiver);
assert(~u03.mib.crcError,'Uni03:MIB','MIB recovery failed; inspect the capture impairments.');
u03.frameStart=u03.mib.ssbStartSample-sum(u03.tx.ofdmInfo.SymbolLengths(1:2));
assert(u03.frameStart>=0,'Uni03:Timing','Estimated frame start is outside this capture.');
u03.grid=nrOFDMDemodulate(u03.mib.correctedWaveform(u03.frameStart+1:end), ...
    28,30,0,'SampleRate',u03.tx.sampleRate);
u03.monitor=uni03_table(u03.mib); disp(u03.monitor);
fprintf('Recovered PCI %d; SFN %d; CFO %.2f Hz; frame start %d\n', ...
    u03.mib.cellID,u03.mib.systemFrameNumber,u03.mib.frequencyOffset,u03.frameStart);
figure('Theme','light','Color','w');
imagesc(0:size(u03.grid,2)-1,0:335,abs(u03.grid)); axis xy; colorbar;
xlabel('OFDM symbol from estimated frame start'); ylabel('Capture subcarrier'); title('Received broadcast grid after synchronization');
```

## control: Search PDCCH candidates
<!-- anchor: search-control-candidates-and-decode-the-grant -->

The receiver searches candidate locations without the transmitted candidate index. It then executes the granted PDSCH reception inside the same helper. The trace lists every attempted CRC syndrome, with zero indicating accepted control under SI-RNTI 65535.

```matlab
assert(exist('u03','var')==1 && isfield(u03,'grid'),'Uni03:Order','Recover the MIB and grid first.');
u03.rx=uni03_receive(u03.mib,u03.grid,struct);
assert(~isempty(u03.rx.candidateTrace),'Uni03:Candidates','No candidates were available in this capture.');
disp(array2table(u03.rx.candidateTrace,'VariableNames', ...
    {'Slot','AggregationLevel','Candidate','CRCSyndrome','EqualizedPower'}));
figure('Theme','light','Color','w');
stem(1:size(u03.rx.candidateTrace,1),double(u03.rx.candidateTrace(:,4)==0),'filled');
ylim([-.1 1.1]); xlabel('Candidate attempt'); ylabel('Control CRC accepted'); title('Measured PDCCH candidate decisions');
assert(~u03.rx.dciCRC,'Uni03:DCI','No control candidate passed its CRC.');
disp(u03.rx.dci);
```

## payload: Verify the recovered transport bits
<!-- anchor: recover-the-data-allocation-transport-bits-and-sib1-fields -->

Inspect the equalized PDSCH symbols and compare all decoded transport bits with the transmitter after reception. CRC acceptance and bit agreement establish this physical transport result. SIB1 field parsing is an optional step in the final save cell and uses these recovered bits.

```matlab
assert(exist('u03','var')==1 && isfield(u03,'rx') && ~u03.rx.dciCRC,'Uni03:Order','Recover the control grant first.');
u03.bitErrors=sum(u03.rx.transportBits~=u03.tx.transportBits);
disp(table(~u03.rx.transportCRC,u03.bitErrors,numel(u03.rx.transportBits), ...
    'VariableNames',{'TransportCRCPass','BitErrors','TransportBits'}));
figure('Theme','light','Color','w');
plot(real(u03.rx.pdschEqualized),imag(u03.rx.pdschEqualized),'.'); axis equal; grid on;
xlabel('In-phase'); ylabel('Quadrature'); title('Equalized PDSCH carrying SIB1');
assert(~u03.rx.transportCRC && u03.bitErrors==0,'Uni03:Payload','Transport bits were not recovered correctly.');
```

## compare: Test an incorrect control identity
<!-- anchor: break-one-receiver-assumption-at-a-time -->

Hold the recovered MIB and grid fixed and change only the receiver's SI-RNTI hypothesis. The comparison isolates control acceptance after synchronization and uses one capture.

```matlab
assert(exist('u03','var')==1 && isfield(u03,'rx'),'Uni03:Order','Run the receiver first.');
u03.wrong=uni03_receive(u03.mib,u03.grid,struct('siRNTI',u03.config.wrongSIRNTI));
u03.acceptance=[~u03.rx.dciCRC ~u03.rx.transportCRC; ~u03.wrong.dciCRC ~u03.wrong.transportCRC];
disp(array2table(u03.acceptance,'VariableNames',{'DCICRCPass','TransportCRCPass'}, ...
    'RowNames',{'Baseline','ChangedSIRNTI'}));
figure('Theme','light','Color','w'); bar(double(u03.acceptance)); ylim([0 1.1]);
xticklabels({'Baseline','Changed SI-RNTI'}); ylabel('CRC accepted');
legend('DCI','Transport block'); title('One capture with two control identity hypotheses');
```

## save: Save results and optionally parse SIB1
<!-- anchor: hand-the-decoded-configuration-to-random-access -->

Save the current experiment in a new student directory. With `parseASN1` enabled, the existing pycrate codec reads the recovered transport bits and checks the resulting canonical bytes against the fixture. A disabled parser reports only the MATLAB transport result.

```matlab
assert(exist('u03','var')==1 && isfield(u03,'bitErrors'),'Uni03:Order','Verify the transport bits before saving.');
u03.studentRoot=fullfile(u03.lab,'jupyter','student-results');
if ~isfolder(u03.studentRoot), mkdir(u03.studentRoot); end
u03.runDir=tempname(u03.studentRoot); mkdir(u03.runDir);
u03.asn1Parsed=false;
if u03.config.parseASN1
    assert(isfile(u03.config.python),'Uni03:Python','Set config.python to the laboratory Python environment with pycrate.');
    u03.fid=fopen(fullfile(u03.runDir,'recovered-bits.json'),'w');
    assert(u03.fid>=0,'Uni03:Save','Could not save recovered bits.');
    fwrite(u03.fid,jsonencode(u03.rx.transportBits),'char'); fclose(u03.fid);
    u03.command=sprintf('"%s" "%s" decode "%s" --input "%s"',u03.config.python, ...
        fullfile(u03.lab,'sib1_codec.py'),fullfile(u03.runDir,'decoded-sib1.json'), ...
        fullfile(u03.runDir,'recovered-bits.json'));
    [u03.status,u03.message]=system(u03.command); disp(u03.message);
    assert(u03.status==0,'Uni03:ASN1','SIB1 parsing failed; inspect the Python dependency.');
    u03.decoded=jsondecode(fileread(fullfile(u03.runDir,'decoded-sib1.json')));
    u03.fixture=jsondecode(fileread(fullfile(u03.lab,'sib1-fixture.json')));
    assert(strcmp(u03.decoded.canonicalHex,u03.fixture.hex),'Uni03:ASN1','Decoded SIB1 bytes differ from the fixture.');
    u03.asn1Parsed=true; disp(u03.decoded.randomAccess);
else
    fprintf('ASN.1 parsing disabled; MATLAB transport bits and CRC were checked.\n');
end
u03.software=ver; save(fullfile(u03.runDir,'run.mat'),'u03');
u03.fid=fopen(fullfile(u03.runDir,'config.json'),'w');
assert(u03.fid>=0,'Uni03:Save','Could not create the configuration file.');
fwrite(u03.fid,jsonencode(struct('config',u03.config,'software',u03.software)),'char'); fclose(u03.fid);
fprintf('Student results saved to %s\n',u03.runDir);
```
