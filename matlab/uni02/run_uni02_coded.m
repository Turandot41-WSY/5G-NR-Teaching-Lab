function run_uni02_coded
root=fileparts(mfilename('fullpath')); addpath(root); out=fullfile(root,'results',['coded-' datestr(now,'yyyymmdd-HHMMSS')]); mkdir(out);
diary(fullfile(out,'matlab.log')); disp(version); test_uni02;
baseline=uni02_coded(false); mismatch=uni02_coded(true);
save(fullfile(out,'coded.mat'),'baseline','mismatch');
summary=table([0;1],[baseline.A;mismatch.A],[baseline.G;mismatch.G],[baseline.crcFailure;mismatch.crcFailure],[baseline.bitErrors;mismatch.bitErrors], 'VariableNames',{'WrongIdentity','TransportBits','CodedBits','CRCFailure','BitErrors'});
writetable(summary,fullfile(out,'summary.csv')); disp(summary);
src=dir(fullfile(root,'*.m')); mkdir(fullfile(out,'source')); hashes=struct;
for k=1:numel(src), path=fullfile(root,src(k).name); copyfile(path,fullfile(out,'source',src(k).name)); [~,h]=system(['shasum -a 256 "' path '"']); hashes.(matlab.lang.makeValidName(src(k).name))=strtrim(h); end
fid=fopen(fullfile(out,'source-hashes.json'),'w'); fprintf(fid,'%s',jsonencode(hashes,PrettyPrint=true)); fclose(fid);
fprintf('RESULT_DIRECTORY=%s\n',out); diary off;
end
