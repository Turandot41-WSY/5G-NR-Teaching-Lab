function run_uni02
root=fileparts(mfilename('fullpath')); addpath(root);
runID=['run-' datestr(now,'yyyymmdd-HHMMSS')]; out=fullfile(root,'results',runID); mkdir(out);
diary(fullfile(out,'matlab.log')); disp(version); disp(ver('5g')); test_uni02;
config=struct('snrDb',0:5:30,'dopplerHz',[0 300 1000],'additional',[0 2],'trialsPerPoint',30,'seedBase',420000,'model','Ideal OFDM diagonal two-path channel');
b=uni02_link(25,0,2,42001,false); f=uni02_link(25,0,2,42001,true);
slow=uni02_link(25,1000,0,42001,false); fast=uni02_link(25,1000,2,42001,false);
rows=[]; ix=0;
for d=config.dopplerHz
 for ap=config.additional
  for snr=config.snrDb
   for tr=1:config.trialsPerPoint
    seed=config.seedBase+tr+1000*(snr+1)+100000*(d/1000);
    a=uni02_link(snr,d,ap,seed,false); ix=ix+1;
    rows(ix,:)=[snr d ap tr seed a.ber a.perfectBer a.evm a.nmse a.noiseEstimate a.ber>0.05];
   end
  end
 end
end
trials=array2table(rows,'VariableNames',{'SNRdB','DopplerHz','Additional','Trial','Seed','BER','OracleBER','EVM','NMSE','NoiseEstimate','BlockFailure'});
summary=[];
for d=config.dopplerHz
 for ap=config.additional
  for snr=config.snrDb
   q=trials(trials.SNRdB==snr & trials.DopplerHz==d & trials.Additional==ap,:);
   n=height(q); e=sum(q.BlockFailure); [lo,hi]=wilson(e,n);
   summary(end+1,:)=[snr d ap n e mean(q.BER) mean(q.OracleBER) mean(q.EVM) mean(q.NMSE) lo hi];
  end
 end
end
summary=array2table(summary,'VariableNames',{'SNRdB','DopplerHz','Additional','Trials','Failures','BER','OracleBER','EVM','NMSE','WilsonLow','WilsonHigh'});
save(fullfile(out,'run.mat'),'b','f','slow','fast','trials','summary','config','-v7.3');
writetable(trials,fullfile(out,'trials.csv')); writetable(summary,fullfile(out,'summary.csv'));
fid=fopen(fullfile(out,'config.json'),'w'); fprintf(fid,'%s',jsonencode(config,PrettyPrint=true)); fclose(fid);
software=struct('version',version,'products',ver,'rng','twister'); fid=fopen(fullfile(out,'software.json'),'w'); fprintf(fid,'%s',jsonencode(software,PrettyPrint=true)); fclose(fid);
mkdir(fullfile(out,'source')); src=dir(fullfile(root,'*.m')); hashes=struct;
for k=1:numel(src), path=fullfile(root,src(k).name); copyfile(path,fullfile(out,'source',src(k).name)); [~,h]=system(['shasum -a 256 "' path '"']); hashes.(matlab.lang.makeValidName(src(k).name))=strtrim(h); end
fid=fopen(fullfile(out,'source-hashes.json'),'w'); fprintf(fid,'%s',jsonencode(hashes,PrettyPrint=true)); fclose(fid);
uni02_plots(out,b,f,slow,fast,summary,trials);
disp(summary); fprintf('RESULT_DIRECTORY=%s\n',out); diary off;
end
function [lo,hi]=wilson(e,n)
z=1.95996398454; p=e/n; c=(p+z*z/(2*n))/(1+z*z/n); h=z*sqrt(p*(1-p)/n+z*z/(4*n*n))/(1+z*z/n); lo=c-h; hi=c+h;
end
