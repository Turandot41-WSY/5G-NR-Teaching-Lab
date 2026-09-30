# Uni-02 execution cells

These editable cells call the existing reference signal experiment. Run them in order; the page and downloaded notebook use the same code.

## setup: Environment and channel parameters
<!-- anchor: protocol-settings-and-the-experiment-boundary -->

The experiment starts with an aligned resource grid. The channel has two deterministic paths and a common phase rate across symbols; it omits intercarrier interference. Edit the SNR, phase rate, pilot density and seed before running the following cells.

```matlab
u02 = struct;
u02.root = pwd;
while ~isfile(fullfile(u02.root,'publish_site.py'))
    u02.parent = fileparts(u02.root);
    assert(~strcmp(u02.parent,u02.root),'Uni02:Root','Open the notebook inside the course package.');
    u02.root = u02.parent;
end
addpath(fullfile(u02.root,'matlab','uni02'));
assert(~isempty(which('nrChannelEstimate')) && ~isempty(which('nrPDSCHDecode')), ...
    'Uni02:Toolbox','Install and license 5G Toolbox before running this lab.');
u02.config = struct('snrDb',16,'phaseRateHz',100,'additionalPositions',2, ...
    'seed',52002,'compareSnrDb',[-4 4 16]);
assert(ismember(u02.config.additionalPositions,0:3),'Uni02:Config','Additional DM-RS positions must be 0 through 3.');
disp(version); disp(ver('5g')); disp(u02.config);
```

## resources: Generate the reference and data grid
<!-- anchor: sequence-generation-and-resource-accounting -->

The helper executes the channel and receiver once and retains their intermediate arrays. This cell displays the generated resource map and counts the data and DM-RS elements. Optional PT-RS positions returned by the helper are not transmitted in this experiment.

```matlab
assert(exist('u02','var')==1 && isfield(u02,'config'),'Uni02:Order','Run setup first.');
u02.link = uni02_link(u02.config.snrDb,u02.config.phaseRateHz, ...
    u02.config.additionalPositions,u02.config.seed,false);
figure('Theme','light','Color','w');
imagesc(0:13,0:size(u02.link.mask,1)-1,u02.link.mask); axis xy;
colormap([1 1 1; 0 .27 .64; .46 .73 0]);
colorbar('Ticks',0:2,'TickLabels',{'Unused','PDSCH','DM-RS'});
xlabel('OFDM symbol'); ylabel('Subcarrier'); title('Generated PDSCH and DM-RS resources');
fprintf('Data %d RE; DM-RS %d RE; uncoded input %d bits\n', ...
    u02.link.nData,u02.link.nDMRS,numel(u02.link.bits));
```

## estimate: Inspect the channel estimate
<!-- anchor: pilot-division-and-interpolation -->

Compare the channel used by the simulator with the estimate reconstructed from received pilots. The normalized mean squared error uses the complete grid and the simulator's channel only for evaluation.

```matlab
assert(exist('u02','var')==1 && isfield(u02,'link'),'Uni02:Order','Generate the grid first.');
figure('Theme','light','Color','w'); tiledlayout(1,2);
nexttile; imagesc(0:13,0:287,abs(u02.link.H)); axis xy; colorbar;
xlabel('OFDM symbol'); ylabel('Subcarrier'); title('Simulated channel magnitude');
nexttile; imagesc(0:13,0:287,abs(u02.link.Hhat)); axis xy; colorbar;
xlabel('OFDM symbol'); ylabel('Subcarrier'); title('Estimated channel magnitude');
fprintf('Channel NMSE %.5g; injected noise %.5g; estimated noise %.5g\n', ...
    u02.link.nmse,u02.link.noiseVariance,u02.link.noiseEstimate);
```

## equalize: Compare recovered symbols and bits
<!-- anchor: equalization-and-bit-evidence -->

The receiver equalizes PDSCH using the estimated channel. The second constellation uses the simulator's exact channel and noise variance as an ideal comparison. BER counts uncoded hard decisions; this helper does not decode a transport CRC.

```matlab
assert(exist('u02','var')==1 && isfield(u02,'link'),'Uni02:Order','Generate the grid first.');
figure('Theme','light','Color','w'); tiledlayout(1,2);
nexttile; plot(real(u02.link.eq),imag(u02.link.eq),'.'); axis equal; grid on;
xlabel('In-phase'); ylabel('Quadrature'); title('Estimated channel equalization');
nexttile; plot(real(u02.link.perfect),imag(u02.link.perfect),'.'); axis equal; grid on;
xlabel('In-phase'); ylabel('Quadrature'); title('Exact channel comparison');
disp(table(u02.link.ber,u02.link.perfectBer,u02.link.evm, ...
    'VariableNames',{'UncodedBER','ExactChannelBER','RmsEVM'}));
assert(numel(u02.link.bits)==numel(u02.link.bhat),'Uni02:Dimensions','Decoded bit dimensions disagree.');
```

## compare: Change the reference identity and noise
<!-- anchor: reference-mismatch-and-temporal-interpolation -->

Each SNR uses one realization for the correct and incorrect reference identities. Matching seeds preserve the transmitted grid and noise within each pair. These bit error fractions demonstrate receiver sensitivity; estimating BLER requires coded blocks, CRC outcomes and repeated trials.

```matlab
assert(exist('u02','var')==1 && isfield(u02,'link'),'Uni02:Order','Generate the grid first.');
u02.berComparison=zeros(numel(u02.config.compareSnrDb),2);
for k=1:numel(u02.config.compareSnrDb)
    u02.correct=uni02_link(u02.config.compareSnrDb(k),u02.config.phaseRateHz, ...
        u02.config.additionalPositions,u02.config.seed,false);
    u02.wrong=uni02_link(u02.config.compareSnrDb(k),u02.config.phaseRateHz, ...
        u02.config.additionalPositions,u02.config.seed,true);
    u02.berComparison(k,:)=[u02.correct.ber u02.wrong.ber];
end
figure('Theme','light','Color','w');
plot(u02.config.compareSnrDb,u02.berComparison,'-o','LineWidth',1.5); grid on;
xlabel('SNR per resource element (dB)'); ylabel('Uncoded bit error fraction');
legend('Correct DM-RS identity','Incorrect DM-RS identity');
title('One realization per SNR and reference identity');
disp(array2table([u02.config.compareSnrDb(:) u02.berComparison], ...
    'VariableNames',{'SNR_dB','CorrectIdentityBER','WrongIdentityBER'}));
```

## save: Save the current experiment
<!-- anchor: run-evidence-and-calculation-traceability -->

Save the current configuration, arrays and software inventory in a new student directory. Download the notebook to retain the edited cells and displayed figures.

```matlab
assert(exist('u02','var')==1 && isfield(u02,'berComparison'),'Uni02:Order','Run the comparison before saving.');
u02.studentRoot=fullfile(u02.root,'matlab','uni02','jupyter','student-results');
if ~isfolder(u02.studentRoot), mkdir(u02.studentRoot); end
u02.runDir=tempname(u02.studentRoot); mkdir(u02.runDir);
u02.software=ver;
save(fullfile(u02.runDir,'run.mat'),'u02');
u02.fid=fopen(fullfile(u02.runDir,'config.json'),'w');
assert(u02.fid>=0,'Uni02:Save','Could not create the configuration file.');
fwrite(u02.fid,jsonencode(struct('config',u02.config,'software',u02.software)),'char'); fclose(u02.fid);
fprintf('Student results saved to %s\n',u02.runDir);
```
