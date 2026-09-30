function uni_lab_provenance(base)
% Current source snapshot and SHA256, timestamped separately from historic runs.
id=['source-' char(datetime('now','Format','yyyyMMdd-HHmmss'))];
out=fullfile(base,'results',id);mkdir(out);
files=[dir(fullfile(base,'*.m'));dir(fullfile(base,'*.py'));dir(fullfile(base,'*.json'));dir(fullfile(base,'README.md'))];
rows=cell(numel(files),3);
for k=1:numel(files)
    path=fullfile(files(k).folder,files(k).name);copyfile(path,fullfile(out,files(k).name));
    [status,str]=system(sprintf('shasum -a256 "%s"',path));assert(status==0);
    rows(k,:)={files(k).name,char(extractBefore(string(str),' ')),id};
end
writetable(cell2table(rows,'VariableNames',{'file','sha256','snapshot'}),fullfile(out,'manifest.csv'));
fprintf('Current source snapshot: %s\n',out);
end
