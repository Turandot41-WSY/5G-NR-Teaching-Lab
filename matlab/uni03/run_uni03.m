function report=run_uni03
% Reproducible MATLAB R2026a waveform and conditional reception evidence.
root=fileparts(mfilename('fullpath'));uni03_setup;
runId=['run-' char(datetime('now','Format','yyyyMMdd-HHmmss'))];
out=fullfile(root,'results',runId);mkdir(out);mkdir(fullfile(out,'source'));
diary(fullfile(out,'matlab.log'));cleanup=onCleanup(@()diary('off'));
fprintf('Uni03 %s\n',runId);disp(version);disp(ver('5g'));test_uni03;
rng(63003,'twister'); t=uni03_tx;
% Baseline: actual time waveform with unknown sample delay and CFO.
delay=19;cfo=3400;snrDb=20;
w=[zeros(delay,1);t.waveform;zeros(256,1)];n=(0:numel(w)-1)';
w=w.*exp(1i*2*pi*cfo*n/t.sampleRate);
sigma=sqrt(1/(2*t.ofdmInfo.Nfft*10^(snrDb/10)));
w=w+sigma*(randn(size(w))+1i*randn(size(w)));
a=t.config.receiver;a.sampleRate=t.sampleRate;
m=uni01_rx(w,a);assert(~m.crcError);
frameStart=m.ssbStartSample-sum(t.ofdmInfo.SymbolLengths(1:2));
z=m.correctedWaveform(frameStart+1:end);
grid=nrOFDMDemodulate(z,28,30,0,'SampleRate',t.sampleRate);
baseline=uni03_receive(m,grid,struct);
assert(~baseline.dciCRC && ~baseline.transportCRC && isequal(baseline.transportBits,t.transportBits));
writeJSON(fullfile(out,'recovered-bits.json'),baseline.transportBits);
py=course_python;codec=fullfile(root,'sib1_codec.py');
cmd=sprintf('"%s" "%s" decode "%s" --input "%s"',py,codec, ...
 fullfile(out,'decoded-sib1.json'),fullfile(out,'recovered-bits.json'));
[status,msg]=system(cmd);disp(msg);assert(status==0);
decoded=jsondecode(fileread(fullfile(out,'decoded-sib1.json')));
fixture=jsondecode(fileread(fullfile(root,'sib1-fixture.json')));
assert(strcmp(decoded.canonicalHex,fixture.hex));
% Conditional sweep isolates control/data reception after synchronization.
snrs=[-8 -4 0 4 8 16];trials=[];summ=[];saved=cell(numel(snrs),1);
for ii=1:numel(snrs)
 sn=snrs(ii); successes=0;
 for k=1:20
  noise=(randn(size(t.grid))+1i*randn(size(t.grid)))/sqrt(2*10^(sn/10));
  rr=uni03_receive(t.mib,t.grid+noise,struct);
  ber=NaN;if ~rr.dciCRC,ber=sum(rr.transportBits~=t.transportBits)/numel(t.transportBits);end
  success=~rr.dciCRC && ~rr.transportCRC && ber==0;
  trials(end+1,:)=[sn k ~rr.dciCRC ~rr.transportCRC ber success size(rr.candidateTrace,1)];
  successes=successes+success;
  if k==1,saved{ii}=rr;end
 end
 [lo,hi]=uni01_interval(successes,20);
 summ(end+1,:)=[sn 20 successes successes/20 lo hi];
end
trials=array2table(trials,'VariableNames',{'snrDb','trial','dciAccepted','transportAccepted','bitErrorFraction','success','candidateAttempts'});
summary=array2table(summ,'VariableNames',{'snrDb','trials','successes','successFraction','wilsonLower','wilsonUpper'});
writetable(trials,fullfile(out,'trials.csv'));writetable(summary,fullfile(out,'summary.csv'));
cases={'baseline','wrong SI-RNTI','wrong CORESET offset','wrong slot','wrong MCS','odd frame'};
opts={struct,struct('siRNTI',65534),struct('offsetRB',-1),struct('slots',0),struct('mcs',0),struct};
failures=[];failureResults=cell(6,1);
for j=1:6
 mm=m;if j==6,mm.systemFrameNumber=427;end
 rr=uni03_receive(mm,grid,opts{j});failureResults{j}=rr;
 failures(j,:)=[double(~rr.dciCRC) double(~rr.transportCRC) size(rr.candidateTrace,1)];
end
assert(all(failures(2:end,2)==0));
failureTable=table(string(cases'),failures(:,1),failures(:,2),failures(:,3), ...
 'VariableNames',{'caseName','dciAccepted','transportAccepted','candidateAttempts'});
writetable(failureTable,fullfile(out,'failures.csv'));
candidates=array2table(baseline.candidateTrace,'VariableNames',{'slot','aggregation','candidate','crcSyndrome','equalizedPower'});
writetable(candidates,fullfile(out,'candidates.csv'));
config=struct('seed',63003,'cellID',321,'captureRB',28,'configuredCarrierRB',51, ...
 'scsKHz',30,'snrDb',20,'delaySamples',delay,'cfoHz',cfo,'conditionalTrialsPerSNR',20, ...
 'snrSweepDb',snrs,'conditionalSync','known grid and recovered noiseless MIB','sib1Bits',400);
writeJSON(fullfile(out,'config.json'),config);writeJSON(fullfile(out,'software.json'),ver);
hashes=struct;files=[dir(fullfile(root,'*.m'));dir(fullfile(root,'*.py'));dir(fullfile(root,'sib1-fixture.json'))];
for k=1:numel(files)
 f=fullfile(root,files(k).name);copyfile(f,fullfile(out,'source',files(k).name));
 [~,s]=system(sprintf('shasum -a 256 "%s"',f));hashes.(matlab.lang.makeValidName(files(k).name))=extractBefore(string(s),' ');
end
writeJSON(fullfile(out,'source-hashes.json'),hashes);
report=struct('runId',runId,'summary',table2struct(summary),'sourceHashes',hashes, ...
 'baselineDCICRC',baseline.dciCRC,'baselineTransportCRC',baseline.transportCRC, ...
 'transportBitErrors',sum(baseline.transportBits~=t.transportBits), ...
 'sib1UPERBytes',50,'transportBlockLength',baseline.transportBlockLength, ...
 'estimatedCFOHz',m.frequencyOffset,'frameStartSample',frameStart, ...
 'randomAccess',decoded.randomAccess,'output',out);
save(fullfile(out,'run.mat'),'t','m','w','grid','baseline','decoded','trials','summary','failureResults','failureTable','saved','report','config','-v7.3');
writeJSON(fullfile(out,'summary.json'),report);
uni03_plots(out);
disp(summary);disp(failureTable);disp(report);
end

function writeJSON(path,value)
f=fopen(path,'w');clean=onCleanup(@()fclose(f));fwrite(f,jsonencode(value,'PrettyPrint',true));
end
