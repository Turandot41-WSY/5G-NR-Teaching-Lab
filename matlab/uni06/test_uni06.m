function test_uni06
assert(exist('uni06_power','file')==2,'UNI06:MissingPower','PUSCH clamp must be implemented.');
[p,raw]=uni06_power(100,1,6,1,-90,23,0,0);
assert(abs(raw-20.79181246)<1e-7 && p==raw);
[p,raw]=uni06_power(120,1,6,1,-90,23,0,0);
assert(p==23 && raw>23);
assert(exist('run_uni06','file')==2,'UNI06:MissingRun','Waveform experiment must exist.');
fprintf('PASS power equation, clamp and runner.\n');
end
