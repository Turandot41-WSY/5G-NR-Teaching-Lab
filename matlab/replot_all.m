function replot_all(only)
if nargin<1, only=''; end
want=@(n) isempty(only) || any(strcmp(only,n));
% Re-render every MATLAB figure of the nine laboratories from saved data in the publication style.
root=fileparts(mfilename('fullpath')); addpath(root); pubfig.reset;
if want('uni01'), addpath(fullfile(root,'uni01')); run1=fullfile(root,'uni01','results','run-20260907-002810');
if isfolder(fullfile(run1,'figures-pub')), rmdir(fullfile(run1,'figures-pub'),'s'); end
uni01_plots(run1,'figures-pub'); uni01_plots_extra(run1,'figures-pub'); fprintf('== uni01 done\n'); end
if want('uni02'), addpath(fullfile(root,'uni02')); out=fullfile(root,'uni02','results','run-20260907-120305'); s=load(fullfile(out,'run.mat'));
uni02_plots(out,s.b,s.f,s.slow,s.fast,s.summary,s.trials); fprintf('== uni02 done\n'); end
if want('uni03'), addpath(fullfile(root,'uni03')); uni03_plots(fullfile(root,'uni03','results','run-20260907-122809')); fprintf('== uni03 done\n'); end
if want('uni04'), addpath(fullfile(root,'uni04')); s=load(fullfile(root,'uni04','results','run.mat'));
uni04_plots(fullfile(root,'uni04'),s.cfg,s.detectionSummary,s.puschTrials,s.quantization,s.representative,s.normalDetection,s.stressDetection);
cd(fullfile(root,'uni04')); uni04_expansion; cd(root); fprintf('== uni04 done\n'); end
if want('uni05'), addpath(fullfile(root,'uni05')); out=fullfile(root,'uni05','results','run-20260907-120612'); s=load(fullfile(out,'run.mat'));
uni05_plots(out,s.b,s.f,s.large,s.iterScan,s.summary,s.sizes,s.trials); fprintf('== uni05 done\n'); end
if want('uni06'), cd(fullfile(root,'uni06')); uni06_replot; cd(root); end
if want('uni07'), cd(fullfile(root,'uni07')); uni07_replot; cd(root); end
if want('uni09'), cd(fullfile(root,'uni09')); uni09_replot; cd(root); end; fprintf('== uni06/07/09 done\n');
if want('uni08'), addpath(fullfile(root,'uni04')); addpath(fullfile(root,'uni08')); uni08_plots; fprintf('== uni08 done\n'); end
pubfig.report;
end
