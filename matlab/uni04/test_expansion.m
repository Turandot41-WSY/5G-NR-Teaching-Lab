function test_expansion
base=fileparts(mfilename('fullpath'));
assert(isfile(fullfile(base,'results','expansion.mat')),'UNI04:MissingExpansion','Run uni04_expansion first.');
s=load(fullfile(base,'results','expansion.mat'));
assert(height(s.delaySweep)==25 && height(s.snrTrials)==180);
assert(all(s.snrTrials.trial>=1 & s.snrTrials.trial<=30));
assert(s.sequenceError<1e-10,'Zadoff Chu formula and Toolbox sequence disagree.');
assert(numel(s.figures)==16);
for k=1:numel(s.figures)
    f=fullfile(base,'..','..','notes','99 Attachments','5G','Uni Labs','Uni-04',s.figures{k});
    assert(isfile(f)); info=imfinfo(f); assert(info.Width>=1200 && info.Height>=650);
end
fprintf('PASS: exact sequence, 25 delay points, 180 fresh UL-SCH trials, 16 expansion plots.\n');
end
