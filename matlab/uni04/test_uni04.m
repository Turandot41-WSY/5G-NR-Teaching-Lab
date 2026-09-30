function test_uni04
% Deterministic acceptance tests, written before implementation.
assert(exist('uni04_ta','file')==2,'UNI04:MissingTA','TA conversion is not implemented.');
Fs=7.68e6; Tc=1/(480e3*4096);
a=uni04_ta(161,Fs,0,0);
assert(abs(a.stepSeconds-1/1.92e6)<1e-15);
assert(a.command==40 && a.advanceSamples==160);
assert(a.NTA==40960 && abs(a.residualSamples-1)<1e-10);
b=uni04_ta(161,Fs,1,0);
assert(b.command==81 && b.advanceSamples==162 && b.residualSamples==-1);
o=uni04_ta(161,Fs,0,25600);
assert(o.command==a.command,'Configured offset must not enter the measured residual quantizer.');
assert(abs(o.totalAdvanceSeconds-a.totalAdvanceSeconds-25600*Tc)<1e-15);
assert(abs(o.arrivalRelativeDLSeconds-(161/Fs-a.advanceSamples/Fs-25600*Tc))<1e-15);
z=uni04_ta(0,Fs,0,0); assert(z.command==0);
assert(exist('uni04_wilson','file')==2,'UNI04:MissingWilson','Binomial interval is not implemented.');
[lo,hi]=uni04_wilson(0,100); assert(lo==0 && hi>0.036 && hi<0.038);
[lo,hi]=uni04_wilson(100,100); assert(hi==1 && lo>0.962 && lo<0.964);
[lo,hi]=uni04_wilson(50,100); assert(lo<0.5 && hi>0.5);
assert(exist('uni04_prach','file')==2,'UNI04:MissingPRACH','PRACH waveform is not implemented.');
[c,p,w,info]=uni04_prach;
assert(info.SampleRate==Fs && p.LRA==839 && strcmp(p.Format,'0'));
for d=[0 1 7 40 161]
    [ind,off]=nrPRACHDetect(c,p,[zeros(d,1);w]);
    assert(ind==p.PreambleIndex && abs(off-d)<0.51,'Noiseless PRACH timing failed.');
end
assert(exist('uni04_pusch','file')==2,'UNI04:MissingPUSCH','PUSCH receiver is not implemented.');
rng(90404,'twister');
r=uni04_pusch(c,161,160,Inf);
assert(r.correctedCRC==0 && r.correctedBitErrors==0,'Corrected noiseless UL-SCH failed.');
assert(r.uncorrectedCRC==1,'Large uncorrected delay should fail the fixed FFT window.');
assert(r.correctedResidual==1 && r.sampleRate==Fs);
fprintf('PASS: TA units, SCS, reference planes, Wilson limits, five noiseless PRACH offsets, and UL-SCH CRC.\n');
end
