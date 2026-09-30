function out=run_uni01(mode)
% Reproduce the acquisition pilot. Each run has its own evidence directory.
if nargin==0, mode='pilot'; end
assert(ismember(mode,{'pilot','smoke'}));
root=fileparts(mfilename('fullpath')); old=pwd; cleaner=onCleanup(@()cd(old)); cd(root);
runId=['run-' char(datetime('now','Format','yyyyMMdd-HHmmss'))];
out=fullfile(root,'results',runId); assert(~isfolder(out)); mkdir(out);
mkdir(fullfile(out,'source')); sources=dir(fullfile(root,'*.m'));
sourceHashes=struct;
for si=1:numel(sources)
    copyfile(fullfile(root,sources(si).name),fullfile(out,'source',sources(si).name));
    sourceHashes.(matlab.lang.makeValidName(sources(si).name))=hashfile(fullfile(root,sources(si).name));
end
writejson(fullfile(out,'source-hashes.json'),sourceHashes);
diary(fullfile(out,'matlab.log')); logCleaner=onCleanup(@()diary('off'));
fprintf('Uni-01 %s, mode=%s\n',runId,mode); started=tic;
tr=runtests('test_uni01.m'); assertSuccess(tr);
c=uni01_config; t=uni01_tx(c);
versions=ver; writejson(fullfile(out,'config.json'),c);
writejson(fullfile(out,'software.json'),versions);
[wave,observation]=uni01_observe(t,8,23700,137,c.seed);
rx=uni01_rx(wave,c.receiver);
assert(uni01_accept(rx,t));
snrs=[-18 -14 -10 -6 -2 2 6 10]; N=40;
if strcmp(mode,'smoke'), snrs=[-10 8]; N=2; end
rows=cell(numel(snrs)*N,14); ii=0;
for si=1:numel(snrs)
    for j=1:N
        seed=c.seed+1000+j; rng(seed,'twister');
        cfo=90000*(rand-0.5); delay=randi([0 511]);
        [w,o]=uni01_observe(t,snrs(si),cfo,delay,seed+100000);
        [z,err]=receive(w,c.receiver);
        ii=ii+1;
        rows(ii,:)=trialrow(snrs(si),j,o,z,t,err);
    end
    fprintf('SNR %+g dB: %d trials complete\n',snrs(si),N);
end
names={'snrDb','trial','seed','cfoHz','delaySamples','crcAccepted','pciCorrect', ...
    'mibCorrect','success','frequencyErrorHz','timingErrorSamples','rxCellID','rxSsbIndex','error'};
trials=cell2table(rows,'VariableNames',names);
writetable(trials,fullfile(out,'trials.csv'));
summ=cell(numel(snrs),9);
for si=1:numel(snrs)
    q=trials(trials.snrDb==snrs(si),:); k=sum(q.success); [lo,hi]=uni01_interval(k,height(q));
    good=q(q.success,:);
    summ(si,:)={snrs(si),height(q),k,k/height(q),lo,hi,sum(q.pciCorrect), ...
        sqrt(mean(good.frequencyErrorHz.^2)),sqrt(mean(good.timingErrorSamples.^2))};
end
summary=cell2table(summ,'VariableNames',{'snrDb','trials','successes','successFraction', ...
    'wilsonLower','wilsonUpper','pciCorrect','frequencyRmseHzConditional','timingRmseSamplesConditional'});
writetable(summary,fullfile(out,'summary.csv')); disp(summary);
% Stress scenarios are separate experiments, not extra SNR-curve samples.
stressCfo=[0 23700 60000 120000]; Ns=10;
if strcmp(mode,'smoke'), Ns=1; end
sr=cell(numel(stressCfo)*2*Ns,6); jj=0;
for correct=[true false]
    a=c.receiver; a.correctFrequency=correct;
    for f=stressCfo
        for j=1:Ns
            [w,~]=uni01_observe(t,8,f,137,c.seed+200000+j);
            [z,err]=receive(w,a); ok=uni01_accept(z,t);
            jj=jj+1; sr(jj,:)={f,correct,j,c.seed+200000+j,ok,err};
        end
    end
end
stress=cell2table(sr,'VariableNames',{'cfoHz','correctionEnabled','trial','seed','success','error'});
writetable(stress,fullfile(out,'stress.csv'));
% Noise-only run: CRC acceptance is an application observation, not a 3GPP
% conformance false-alarm probability. No detector threshold is fitted here.
noiseN=40; if strcmp(mode,'smoke'), noiseN=2; end
noiseAccept=false(noiseN,1); noiseErrors=cell(noiseN,1);
for j=1:noiseN
    rng(c.seed+300000+j,'twister'); nw=(randn(size(wave))+1i*randn(size(wave)))/sqrt(2*t.nfft);
    [z,noiseErrors{j}]=receive(nw,c.receiver);
    noiseAccept(j)=~isempty(z) && ~z.crcError;
end
[nl,nh]=uni01_interval(sum(noiseAccept),noiseN);
report=struct('runId',runId,'mode',mode,'software',versions,'runtimeVersion',version,'sourceHashes',sourceHashes,'config',c, ...
    'snrDefinition','Unit-energy active RE / FFT-domain AWGN variance', ...
    'trialsPerSnr',N,'summary',table2struct(summary),'example', ...
    struct('snrDb',8,'cfoHz',23700,'delaySamples',137,'rxPci',rx.cellID, ...
    'rxSfn',rx.systemFrameNumber,'crcPass',~rx.crcError,'estimatedCfoHz',rx.frequencyOffset, ...
    'estimatedSsbStart',rx.ssbStartSample,'expectedSsbStart',observation.expectedSsbStartSample), ...
    'noiseOnlyTrials',noiseN,'noiseOnlyCrcAccepts',sum(noiseAccept), ...
    'noiseOnlyWilson95',[nl nh],'elapsedSeconds',toc(started));
writejson(fullfile(out,'summary.json'),report);
save(fullfile(out,'run.mat'),'c','t','wave','observation','rx','trials','summary','stress','noiseAccept','noiseErrors','report','tr');
if exist('uni01_plots','file')==2, uni01_plots(out); end
fprintf('Evidence saved: %s\nElapsed %.1f s\n',out,toc(started));
end
function h=hashfile(path)
fid=fopen(path,'rb'); assert(fid>=0); cleaner=onCleanup(@()fclose(fid));
bytes=fread(fid,Inf,'*uint8'); md=java.security.MessageDigest.getInstance('SHA-256');
md.update(bytes); h=lower(reshape(dec2hex(typecast(md.digest(),'uint8'),2)',1,[]));
end

function [r,err]=receive(w,a)
r=[];err='';
try, r=uni01_rx(w,a); catch e, err=[e.identifier ': ' e.message]; end
end
function row=trialrow(snr,j,o,r,t,err)
if isempty(r)
    row={snr,j,o.seed,o.frequencyOffsetHz,o.delaySamples,false,false,false,false,NaN,NaN,NaN,NaN,err};
else
    pci=r.cellID==t.config.cellID; mib=isequal(r.mibBits,t.mibBits);
    ok=uni01_accept(r,t);
    row={snr,j,o.seed,o.frequencyOffsetHz,o.delaySamples,~r.crcError,pci,mib,ok, ...
        r.frequencyOffset-o.frequencyOffsetHz,r.ssbStartSample-o.expectedSsbStartSample,r.cellID,r.ssbIndex,err};
end
end
function writejson(path,value)
fid=fopen(path,'w'); assert(fid>=0); cleaner=onCleanup(@()fclose(fid));
fprintf(fid,'%s\n',jsonencode(value,'PrettyPrint',true));
end
