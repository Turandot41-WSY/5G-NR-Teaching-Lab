function run_uni05
root=fileparts(mfilename('fullpath')); addpath(root);
out=fullfile(root,'results',['run-' datestr(now,'yyyymmdd-HHMMSS')]); mkdir(out); diary(fullfile(out,'matlab.log')); disp(version); disp(ver('5g')); test_uni05;
config=struct('snrDb',-4:1:2,'trialsPerPoint',60,'seedBase',520000,'A',1024,'R',0.5,'G',2048,'maxIter',12,'rvs',[0 2 3 1],'channel','Independent complex AWGN per QPSK symbol');
b=uni05_link(12,[0 2 3 1],52001,1024,.5,2048,12);
f=uni05_link(-3,[0 2 3 1],52001,1024,.5,2048,12);
rows=[]; idx=0; methods={'IR','Chase','Reset'};
for m=1:3
 for snr=config.snrDb
  for tr=1:config.trialsPerPoint
   seed=config.seedBase+1000*(snr+5)+tr; rv=[0 2 3 1]; if m==2,rv=[0 0 0 0]; end
   a=uni05_link(snr,rv,seed,1024,.5,2048,12,m~=3);
   for j=1:4, idx=idx+1; rows(idx,:)=[m snr tr seed j rv(j) a.fail(j) a.bitErrors(j) a.iterations(j) a.used a.delivered]; end
  end
 end
 fprintf('Completed %s\n',methods{m});
end
trials=array2table(rows,'VariableNames',{'Method','SNRdB','Trial','Seed','Attempt','RV','CRCFailure','BitErrors','DecoderIterations','UsedAttempts','Delivered'});
summary=[];
for m=1:3
 for snr=config.snrDb
  q=trials(trials.Method==m&trials.SNRdB==snr&trials.Attempt==4,:);
  n=height(q); e=sum(~q.Delivered); [lo,hi]=wilson(e,n); used=sum(q.UsedAttempts); good=sum(q.Delivered);
  q1=trials(trials.Method==m&trials.SNRdB==snr&trials.Attempt==1,:);
  summary(end+1,:)=[m snr n sum(q1.CRCFailure) e lo hi mean(q.UsedAttempts) 1024*good/(2048*used) good used];
 end
end
summary=array2table(summary,'VariableNames',{'Method','SNRdB','Trials','FirstFailures','ResidualFailures','WilsonLow','WilsonHigh','MeanAttempts','GoodputBitsPerCodedBit','Delivered','TotalAttempts'});
% Segmentation and lifting-size audit is deterministic, independent of Monte Carlo.
lengths=[128 512 1024 2048 3824 4000 8000 9000 16000]; sizes=[];
for A=lengths
 for R=[.3 .5 .8]
  info=nrDLSCHInfo(A,R); tb=nrCRCEncode(randi([0 1],A,1),info.CRC); cb=nrCodeBlockSegmentLDPC(tb,info.BGN);
  sizes(end+1,:)=[A R info.L info.BGN info.C info.Zc info.K info.N sum(cb(:)==-1)];
 end
end
sizes=array2table(sizes,'VariableNames',{'A','R','TBCRCLength','BGN','C','Zc','K','N','FillerCount'});
large=uni05_link(12,[0 2],52001,9000,.5,18000,12);
iterScan=[];
for it=[1 2 4 8 12 20]
 a=uni05_link(-1,[0 2 3 1],52002,1024,.5,2048,it); iterScan(end+1,:)=[it a.bitErrors a.fail];
end
save(fullfile(out,'run.mat'),'b','f','large','iterScan','trials','summary','sizes','config','-v7.3');
writetable(trials,fullfile(out,'trials.csv')); writetable(summary,fullfile(out,'summary.csv')); writetable(sizes,fullfile(out,'segmentation.csv'));
software=struct('version',version,'products',ver,'rng','twister');
for entry={'config','software'}, value=eval(entry{1}); fid=fopen(fullfile(out,[entry{1} '.json']),'w'); fprintf(fid,'%s',jsonencode(value,PrettyPrint=true)); fclose(fid); end
mkdir(fullfile(out,'source')); src=dir(fullfile(root,'*.m')); hashes=struct;
for k=1:numel(src), path=fullfile(root,src(k).name); copyfile(path,fullfile(out,'source',src(k).name)); [~,h]=system(['shasum -a 256 "' path '"']); hashes.(matlab.lang.makeValidName(src(k).name))=strtrim(h); end
fid=fopen(fullfile(out,'source-hashes.json'),'w'); fprintf(fid,'%s',jsonencode(hashes,PrettyPrint=true)); fclose(fid);
uni05_plots(out,b,f,large,iterScan,summary,sizes,trials);
disp(summary); fprintf('RESULT_DIRECTORY=%s\n',out); diary off;
end
function [lo,hi]=wilson(e,n)
z=1.95996398454; p=e/n; c=(p+z*z/(2*n))/(1+z*z/n); h=z*sqrt(p*(1-p)/n+z*z/(4*n*n))/(1+z*z/n); lo=c-h; hi=c+h;
end
