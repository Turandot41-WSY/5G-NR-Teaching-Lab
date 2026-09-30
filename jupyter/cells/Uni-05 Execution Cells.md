# Uni-05 execution cells

These cells run the existing CRC, LDPC, redundancy version and soft combining experiment. The webpage and notebook use this same editable source.

## setup: Environment and coding parameters
<!-- anchor: protocol-ownership-and-the-executable-boundary -->

The experiment encodes one transport block and sends QPSK symbols through additive noise. Edit the block size, rate matching length, SNR and redundancy versions. The helper retains diagnostic attempts after the first successful CRC; resource accounting stops at that first success.

```matlab
u05=struct; u05.root=pwd;
while ~isfile(fullfile(u05.root,'publish_site.py'))
    u05.parent=fileparts(u05.root);
    assert(~strcmp(u05.parent,u05.root),'Uni05:Root','Open the notebook inside the course package.');
    u05.root=u05.parent;
end
addpath(fullfile(u05.root,'matlab','uni05'));
assert(~isempty(which('nrLDPCDecode')) && ~isempty(which('nrRateRecoverLDPC')), ...
    'Uni05:Toolbox','Install and license 5G Toolbox before running this lab.');
u05.config=struct('snrDb',-2,'rvs',[0 2 3 1],'seed',52001, ...
    'A',1024,'R',0.5,'G',2048,'maxIter',12,'checkSnrDb',12);
assert(all(ismember(u05.config.rvs,0:3)) && numel(u05.config.rvs)>=2, ...
    'Uni05:Config','Use at least two redundancy versions, each from 0 through 3.');
assert(u05.config.G>0 && mod(u05.config.G,2)==0,'Uni05:Config','QPSK requires a positive even rate matching length.');
disp(version); disp(ver('5g')); disp(u05.config);
```

## encode: Generate the protected LDPC codeword
<!-- anchor: construct-the-protected-ldpc-codeword -->

Run the coding helper once and inspect the retained transport block, CRC, code block segmentation and encoded bits. The same encoded block supplies each redundancy version. Filler entries in the segmented blocks are represented by negative values.

```matlab
assert(exist('u05','var')==1 && isfield(u05,'config'),'Uni05:Order','Run setup first.');
u05.ir=uni05_link(u05.config.snrDb,u05.config.rvs,u05.config.seed, ...
    u05.config.A,u05.config.R,u05.config.G,u05.config.maxIter,true);
disp(u05.ir.info);
fprintf('Transport %d bits; with CRC %d bits; code blocks %d; filler entries %d\n', ...
    numel(u05.ir.tb),numel(u05.ir.withCRC),size(u05.ir.cbs,2),sum(u05.ir.cbs(:)<0));
figure('Theme','light','Color','w');
stairs(0:min(255,numel(u05.ir.encoded)-1),double(u05.ir.encoded(1:min(256,end))));
xlabel('Encoded bit index'); ylabel('Bit value'); title('First LDPC encoded entries'); grid on;
```

## recover: Inspect rate recovery for each redundancy version
<!-- anchor: rate-matching-and-overlap -->

Rate recovery maps each transmission's soft information back to the common LDPC buffer. The plot counts finite, nonzero recovered entries per transmission; known filler positions can have infinite reliability and are excluded from this count.

```matlab
assert(exist('u05','var')==1 && isfield(u05,'ir'),'Uni05:Order','Run the coding helper first.');
u05.recoveredCount=zeros(size(u05.config.rvs));
for k=1:numel(u05.config.rvs)
    u05.rr=u05.ir.recovered{k};
    u05.recoveredCount(k)=sum(isfinite(u05.rr(:)) & u05.rr(:)~=0);
end
figure('Theme','light','Color','w'); bar(u05.recoveredCount);
xticks(1:numel(u05.config.rvs)); xticklabels(string(u05.config.rvs));
xlabel('Redundancy version in transmission order'); ylabel('Finite nonzero buffer entries');
title('Soft information mapped by actual rate recovery');
disp(table((1:numel(u05.config.rvs))',u05.config.rvs(:),u05.recoveredCount(:), ...
    'VariableNames',{'Attempt','RV','ObservedBufferEntries'}));
```

## combine: Inspect the accumulated soft information
<!-- anchor: modulation-noise-and-soft-alignment -->

The helper adds each rate recovered array to the same soft buffer. Compare the first transmission with the accumulated buffer at the last diagnostic attempt. The equality check verifies addition of the recovered arrays at finite entries.

```matlab
assert(exist('u05','var')==1 && isfield(u05,'ir'),'Uni05:Order','Run the coding helper first.');
u05.expected=zeros(size(u05.ir.recovered{1}));
for k=1:numel(u05.config.rvs)
    u05.expected=u05.expected+u05.ir.recovered{k};
end
u05.finite=isfinite(u05.expected) & isfinite(u05.ir.combined{end});
assert(all(abs(u05.expected(u05.finite)-u05.ir.combined{end}(u05.finite))<1e-10), ...
    'Uni05:Combining','The retained soft buffer differs from the sum of recovered transmissions.');
u05.plotIndex=find(isfinite(u05.ir.combined{1}(:)) & isfinite(u05.ir.combined{end}(:)),256,'first');
figure('Theme','light','Color','w');
plot(u05.plotIndex,u05.ir.combined{1}(u05.plotIndex)); hold on;
plot(u05.plotIndex,u05.ir.combined{end}(u05.plotIndex)); hold off; grid on;
xlabel('LDPC soft buffer index'); ylabel('Log likelihood ratio');
legend('First attempt','Final accumulated buffer'); title('Actual soft combining across redundancy versions');
```

## compare: Compare incremental redundancy, Chase and fresh buffers
<!-- anchor: compare-reliability-and-transmission-cost -->

Use the same payload and noise seeds for three methods. Incremental redundancy uses the selected RV sequence; Chase repeats its first RV; the fresh buffer method discards previous soft information. Each method decodes one transport block, so its CRC history is a diagnostic trace rather than a BLER estimate.

```matlab
assert(exist('u05','var')==1 && isfield(u05,'ir'),'Uni05:Order','Run the coding helper first.');
u05.chase=uni05_link(u05.config.snrDb,repmat(u05.config.rvs(1),size(u05.config.rvs)), ...
    u05.config.seed,u05.config.A,u05.config.R,u05.config.G,u05.config.maxIter,true);
u05.fresh=uni05_link(u05.config.snrDb,u05.config.rvs,u05.config.seed, ...
    u05.config.A,u05.config.R,u05.config.G,u05.config.maxIter,false);
u05.accepted=[~u05.ir.fail;~u05.chase.fail;~u05.fresh.fail]';
disp(array2table([(1:numel(u05.config.rvs))' double(u05.accepted)], ...
    'VariableNames',{'Attempt','IncrementalRedundancyPass','ChasePass','FreshBufferPass'}));
figure('Theme','light','Color','w');
stairs(1:numel(u05.config.rvs),double(u05.accepted),'LineWidth',1.5); ylim([-.1 1.1]); grid on;
xlabel('Diagnostic attempt'); ylabel('Transport CRC and code blocks passed');
legend('Incremental redundancy','Chase','Fresh buffer'); title('One block per combining method');
fprintf('Charged attempts: IR %d; Chase %d; fresh %d\n',u05.ir.used,u05.chase.used,u05.fresh.used);
```

## check: Verify recovery at the selected check SNR
<!-- anchor: exact-run-and-acceptance-checks -->

Run the same coding configuration at the check SNR and compare the recovered payload with all transmitted bits. This check verifies the executable coding chain for the chosen configuration. Lowering the check SNR or increasing the effective rate can make it fail.

```matlab
assert(exist('u05','var')==1 && isfield(u05,'fresh'),'Uni05:Order','Run the method comparison first.');
u05.check=uni05_link(u05.config.checkSnrDb,u05.config.rvs,u05.config.seed, ...
    u05.config.A,u05.config.R,u05.config.G,u05.config.maxIter,true);
disp(table(u05.config.checkSnrDb,~u05.check.fail(1),u05.check.bitErrors(1),u05.check.iterations(1), ...
    'VariableNames',{'SNR_dB','FirstAttemptPass','BitErrors','LDPCIterations'}));
assert(~u05.check.fail(1) && u05.check.bitErrors(1)==0, ...
    'Uni05:Recovery','The first check attempt did not recover the payload; inspect SNR and rate.');
```

## save: Save the coding buffers and decisions
<!-- anchor: implementation-flow-and-integration-boundary -->

Save the generated bits, recovered soft buffers, CRC decisions and current parameters in a new student directory. The software inventory is stored with the experiment.

```matlab
assert(exist('u05','var')==1 && isfield(u05,'check'),'Uni05:Order','Run the recovery check before saving.');
u05.studentRoot=fullfile(u05.root,'matlab','uni05','jupyter','student-results');
if ~isfolder(u05.studentRoot), mkdir(u05.studentRoot); end
u05.runDir=tempname(u05.studentRoot); mkdir(u05.runDir);
u05.software=ver; save(fullfile(u05.runDir,'run.mat'),'u05');
u05.fid=fopen(fullfile(u05.runDir,'config.json'),'w');
assert(u05.fid>=0,'Uni05:Save','Could not create the configuration file.');
fwrite(u05.fid,jsonencode(struct('config',u05.config,'software',u05.software)),'char'); fclose(u05.fid);
fprintf('Student results saved to %s\n',u05.runDir);
```
