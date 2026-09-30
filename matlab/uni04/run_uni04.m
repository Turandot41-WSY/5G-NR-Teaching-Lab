function run_uni04
% Reproducible PRACH -> absolute TA -> first scheduled PUSCH experiment.
base=fileparts(mfilename('fullpath')); out=fullfile(base,'results');
if ~isfolder(out), mkdir(out); end
diary(fullfile(out,'run.log')); cleanup=onCleanup(@()diary('off')); %#ok<NASGU>
clockStart=tic; started=datetime('now','TimeZone','UTC');
cfg=jsondecode(fileread(fullfile(base,'config.json')));
fprintf('UNI-04 started %s\nMATLAB %s\n',char(started),version);
disp(ver); test_uni04;
[carrier,prach,tx,prachInfo]=uni04_prach;
Fs=prachInfo.SampleRate;
assert(Fs==cfg.sampleRateHz);
assert(carrier.NSizeGrid==cfg.carrierRB && carrier.SubcarrierSpacing==cfg.carrierSCSkHz);
assert(prach.ConfigurationIndex==cfg.prachConfigurationIndex && prach.PreambleIndex==cfg.preambleIndex);
assert(prach.SubcarrierSpacing==cfg.prachSCSkHz && prach.ZeroCorrelationZone==cfg.zeroCorrelationZone);
assert(cfg.mu==0 && cfg.NTAoffset==0,'The waveform experiment uses mu=0 and explicit NTAoffset=0.');
assert(isequal(cfg.puschPRBSet(:),(0:5)') && cfg.puschTargetCodeRate==0.48);
activePower=mean(abs(tx(abs(tx)>1e-14)).^2);
fprintf('PRACH Fs %.0f Hz, CP %d samples, active power %.9g\n',Fs,prachInfo.CyclicPrefixLengths(1),activePower);
pr=[]; ds=[]; condition=0; serial=0;
for s=cfg.prachSNRdB(:).'
    condition=condition+1;
    [rows,serial]=trials('SNR',condition,cfg.trialsPerPoint,s,0,cfg.detectionThreshold,false,serial);
    pr=[pr;rows]; ds=[ds;summarize(rows,s)]; %#ok<AGROW>
end
for f=cfg.cfoHz(:).'
    condition=condition+1;
    [rows,serial]=trials('CFO',condition,cfg.trialsPerPoint,cfg.cfoStressSNRdB,f,cfg.detectionThreshold,false,serial);
    pr=[pr;rows]; ds=[ds;summarize(rows,f)]; %#ok<AGROW>
end
for threshold=cfg.noiseThresholds(:).'
    condition=condition+1;
    [rows,serial]=trials('Noise',condition,cfg.noiseTrialsPerThreshold,cfg.cfoStressSNRdB,0,threshold,true,serial);
    pr=[pr;rows]; ds=[ds;summarize(rows,threshold)]; %#ok<AGROW>
end
condition=condition+1;
[chain,serial]=trials('Chain',condition,cfg.puschTrials,cfg.chainPRACHSNRdB,cfg.chainCFOHz,cfg.detectionThreshold,false,serial);
pr=[pr;chain]; ds=[ds;summarize(chain,cfg.chainPRACHSNRdB)];
u=[];
for n=1:cfg.puschTrials
    seed=cfg.seed+100000+n; rng(seed,'twister');
    valid=chain(n).detected && chain(n).detectedIndex==cfg.preambleIndex;
    if valid, a=uni04_ta(chain(n).offsetSamples,Fs,cfg.mu,cfg.NTAoffset);
    else, a=uni04_ta(0,Fs,cfg.mu,cfg.NTAoffset); end
    r=uni04_pusch(carrier,cfg.delaySamples,a.advanceSamples,cfg.puschSNRREdB);
    row=struct('trial',n,'seed',seed,'detected',valid,'measuredDelaySamples',chain(n).offsetSamples, ...
        'TAcommand',a.command,'advanceSamples',a.advanceSamples,'residualSamples',r.correctedResidual, ...
        'uncorrectedCRC',r.uncorrectedCRC,'correctedCRC',r.correctedCRC, ...
        'uncorrectedBitErrors',r.uncorrectedBitErrors,'correctedBitErrors',r.correctedBitErrors, ...
        'uncorrectedEVMPercent',r.uncorrectedEVMPercent,'correctedEVMPercent',r.correctedEVMPercent, ...
        'fftStartSample0',r.fftStartSamples(1),'tbs',r.tbs,'snrREdB',r.snrREdB);
    if ~valid, row.correctedCRC=NaN; row.correctedBitErrors=NaN; row.correctedEVMPercent=NaN; end
    u=[u;row]; %#ok<AGROW>
    if n==1, representative=r; representativeTA=a; end
end
% Deterministic timing sweep exposes four-sample quantization at mu=0.
q=[];
for delay=152:169
    [ix,offset]=nrPRACHDetect(carrier,prach,[zeros(delay,1);tx],DetectionThreshold=cfg.detectionThreshold);
    assert(ix==prach.PreambleIndex);
    a=uni04_ta(offset,Fs,cfg.mu,cfg.NTAoffset);
    q=[q;[delay offset a.command a.advanceSamples delay-a.advanceSamples]]; %#ok<AGROW>
end
quantization=array2table(q,'VariableNames',{'trueSamples','measuredSamples','TAcommand','advanceSamples','residualSamples'});
normal=[zeros(cfg.delaySamples,1);tx];
[normalIndex,normalOffset,normalDetection]=nrPRACHDetect(carrier,prach,normal,DetectionThreshold=cfg.detectionThreshold);
rotated=normal.*exp(1i*2*pi*1250*(0:numel(normal)-1)'/Fs);
[stressIndex,stressOffset,stressDetection]=nrPRACHDetect(carrier,prach,rotated,DetectionThreshold=cfg.detectionThreshold);
% Diagnostic correlation for the transmitted root. Practical decisions above
% still come exclusively from nrPRACHDetect searching all 64 preambles.
cp=prachInfo.CyclicPrefixLengths(1); nf=prachInfo.Nfft;
reference=tx(cp+(1:nf));
normalDetection.diagnosticCorrelation=abs(ifft(fft(normal(cp+(1:nf))).*conj(fft(reference)))).^2 ...
    /(sum(abs(normal(cp+(1:nf))).^2)*sum(abs(reference).^2));
stressDetection.diagnosticCorrelation=abs(ifft(fft(rotated(cp+(1:nf))).*conj(fft(reference)))).^2 ...
    /(sum(abs(rotated(cp+(1:nf))).^2)*sum(abs(reference).^2));
normalDetection.detectedOffset=normalOffset; normalDetection.detectedIndex=normalIndex;
stressDetection.detectedOffset=stressOffset; stressDetection.detectedIndex=stressIndex;
stressTA=uni04_ta(stressOffset,Fs,cfg.mu,cfg.NTAoffset);
rng(cfg.seed+200001,'twister');
stressPUSCH=uni04_pusch(carrier,cfg.delaySamples,stressTA.advanceSamples,cfg.puschSNRREdB);
prachTrials=struct2table(pr); detectionSummary=struct2table(ds); puschTrials=struct2table(u);
writetable(prachTrials,fullfile(out,'prach_trials.csv'));
writetable(detectionSummary,fullfile(out,'detection_summary.csv'));
writetable(puschTrials,fullfile(out,'pusch_trials.csv'));
writetable(quantization,fullfile(out,'ta_quantization.csv'));
windowTable=table((0:13)',representative.cyclicPrefixLengths(:),representative.fftStartSamples(:), ...
    representative.fftStartSamples(:)+representative.Nfft-1, ...
    'VariableNames',{'symbolIndex','CPLengthSamples','FFTStartSample0','FFTEndSample0'});
writetable(windowTable,fullfile(out,'fft_windows.csv'));
summary=struct('startedUTC',char(started),'matlabVersion',version,'toolboxes',ver, ...
    'seed',cfg.seed,'sampleRateHz',Fs,'PRACHFormat',prach.Format,'PRACHLRA',prach.LRA, ...
    'PRACHCPsamples',prachInfo.CyclicPrefixLengths(1),'PUSCHNfft',representative.Nfft, ...
    'PUSCHCPsamples',representative.cyclicPrefixLengths,'TBSbits',representative.tbs, ...
    'TcSeconds',1/(480e3*4096),'TsSeconds',1/30.72e6,'TAStepSeconds',representativeTA.stepSeconds, ...
    'configuredNTAoffset',cfg.NTAoffset,'roundTripDelaySeconds',cfg.delaySamples/Fs, ...
    'assumedOneWayDelaySeconds',cfg.delaySamples/(2*Fs),'assumedRangeMeters',299792458*cfg.delaySamples/(2*Fs), ...
    'totalPRACHTrials',height(prachTrials),'puschTrials',height(puschTrials), ...
    'PRACHdetectedForChain',sum(puschTrials.detected),'correctedCRCfailures',sum(puschTrials.correctedCRC==1), ...
    'uncorrectedCRCfailures',sum(puschTrials.uncorrectedCRC==1), ...
    'chainSuccesses',sum(puschTrials.detected & puschTrials.correctedCRC==0), ...
    'CFO1250NoiselessDetectedIndex',stressIndex,'CFO1250NoiselessOffsetSamples',stressOffset);
summary.CFO1250TAcommand=stressTA.command;
summary.CFO1250PUSCHResidualSamples=stressPUSCH.correctedResidual;
summary.CFO1250PUSCHCRC=stressPUSCH.correctedCRC;
summary.CFOStressTraceCount=1;
summary.CFOStressPUSCHSeed=cfg.seed+200001;
[summary.correctedBLERlower95,summary.correctedBLERupper95]=uni04_wilson(summary.correctedCRCfailures,sum(puschTrials.detected));
[summary.chainSuccessLower95,summary.chainSuccessUpper95]=uni04_wilson(summary.chainSuccesses,cfg.puschTrials);
summary.medianCorrectedEVMPercent=median(puschTrials.correctedEVMPercent,'omitnan');
summary.medianUncorrectedEVMPercent=median(puschTrials.uncorrectedEVMPercent);
summary.residualSampleRange=[min(puschTrials.residualSamples) max(puschTrials.residualSamples)];
uni04_plots(base,cfg,detectionSummary,puschTrials,quantization,representative,normalDetection,stressDetection);
summary.runtimeSeconds=toc(clockStart);
summary.finishedUTC=char(datetime('now','TimeZone','UTC'));
fid=fopen(fullfile(out,'summary.json'),'w'); fprintf(fid,'%s\n',jsonencode(summary,PrettyPrint=true)); fclose(fid);
save(fullfile(out,'run.mat'),'cfg','summary','prachTrials','detectionSummary','puschTrials', ...
    'quantization','representative','representativeTA','tx','prachInfo','normalDetection','stressDetection', ...
    'stressTA','stressPUSCH','windowTable');
disp(detectionSummary); disp(summary);
test_outputs;
fprintf('UNI-04 COMPLETE in %.3f seconds\n',summary.runtimeSeconds);

    function [rows,lastSerial]=trials(family,cond,N,snr,cfo,threshold,noiseOnly,lastSerial)
        rows=[];
        for k=1:N
            lastSerial=lastSerial+1; seed=cfg.seed+lastSerial; rng(seed,'twister');
            signal=[zeros(cfg.delaySamples,1);tx];
            if noiseOnly, signal(:)=0; end
            signal=signal.*exp(1i*2*pi*cfo*(0:numel(signal)-1)'/Fs);
            variance=activePower/10^(snr/10);
            rx=signal+sqrt(variance/2)*complex(randn(size(signal)),randn(size(signal)));
            [idx,off]=nrPRACHDetect(carrier,prach,rx,DetectionThreshold=threshold);
            found=~isempty(idx);
            if ~found, idx=NaN; off=NaN; end
            if noiseOnly, event=found;
            else, event=found && idx==cfg.preambleIndex && abs(off-cfg.delaySamples)<=cfg.timingToleranceSamples; end
            row=struct('family',string(family),'condition',cond,'trial',k,'seed',seed, ...
                'snrSampledB',snr,'cfoHz',cfo,'threshold',threshold,'noiseOnly',noiseOnly, ...
                'trueDelaySamples',cfg.delaySamples,'detected',found,'detectedIndex',idx,'offsetSamples',off,'event',event);
            rows=[rows;row]; %#ok<AGROW>
        end
        fprintf('%s: SNR %.1f dB, CFO %.0f Hz, threshold %.3f, events %d/%d\n',family,snr,cfo,threshold,sum([rows.event]),N);
    end
end

function s=summarize(rows,x)
N=numel(rows); count=sum([rows.event]); anyCount=sum([rows.detected]);
[lo,hi]=uni04_wilson(count,N); [anyLo,anyHi]=uni04_wilson(anyCount,N);
s=struct('family',rows(1).family,'xValue',x,'snrSampledB',rows(1).snrSampledB, ...
    'cfoHz',rows(1).cfoHz,'threshold',rows(1).threshold,'trials',N,'count',count, ...
    'probability',count/N,'lower95',lo,'upper95',hi,'anyDetectionCount',anyCount, ...
    'anyDetectionProbability',anyCount/N,'anyLower95',anyLo,'anyUpper95',anyHi);
end
