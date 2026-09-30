function test_outputs
base=fileparts(mfilename('fullpath')); out=fullfile(base,'results');
assert(isfile(fullfile(out,'summary.json')),'UNI04:MissingResults','Simulation outputs do not exist.');
s=jsondecode(fileread(fullfile(out,'summary.json')));
assert(isfield(s,'CFO1250PUSCHCRC'),'UNI04:MissingStressChain','CFO timing error has not been passed to PUSCH.');
assert(s.CFO1250PUSCHCRC==1,'Measured wrong timing should fail the fixed PUSCH window.');
p=readtable(fullfile(out,'prach_trials.csv'));
d=readtable(fullfile(out,'detection_summary.csv'));
u=readtable(fullfile(out,'pusch_trials.csv'));
assert(height(p)==s.totalPRACHTrials);
assert(all(d.lower95>=0 & d.upper95<=1 & d.lower95<=d.probability & d.upper95>=d.probability));
assert(height(u)==s.puschTrials);
assert(all(u.correctedCRC(u.detected)==0),'At configured high SNR every tested detected trial should decode.');
assert(all(u.uncorrectedCRC==1),'Uncorrected delay must fail the fixed FFT window in these trials.');
assert(all(abs(u.residualSamples(u.detected))<=2.51));
assert(all(abs(u.fftStartSample0-20)<1e-10),'FFT window must stay fixed.');
figdir=fullfile(base,'..','..','notes','99 Attachments','5G','Uni Labs','Uni-04');
stems={'Measured Timing Advance Quantization','Noise Only False Alarms and Finite Sample Limits', ...
 'PRACH Correlation and Frequency Offset','PRACH Detection Probability with Confidence Intervals', ...
 'PUSCH Constellations and UL SCH CRC Results','PUSCH Waveform Positions before and after Timing Advance'};
for k=1:numel(stems)
    file=fullfile(figdir,['Uni-04 - ' stems{k} ' v1.png']);
    assert(isfile(file)); im=imfinfo(file);
    assert(im.Width>=1400 && im.Height>=700);
    assert(isfile(strrep(file,'.png','.pdf')));
end
fprintf('PASS: %d PRACH trials, %d PUSCH trials, confidence bounds, fixed FFT windows and six paired figures.\n',height(p),height(u));
end
