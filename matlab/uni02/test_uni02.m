function test_uni02
assert(exist('uni02_link','file')==2,'uni02:missing','The receiver experiment must exist.');
a=uni02_link(25,0,2,42001,false);
assert(a.ber<0.01,'Baseline QPSK recovery failed.');
assert(numel(a.dmrs)>0 && all(size(a.Hhat)==size(a.H)),'Estimator dimensions disagree.');
b=uni02_link(25,0,2,42001,true);
assert(b.ber>0.1,'Wrong DM-RS identity must produce a visible failure.');
assert(a.nData+a.nDMRS<=24*12*14,'Resource accounting exceeds the grid.');
assert(exist('uni02_coded','file')==2,'Coded payload recovery fixture must exist.');
c=uni02_coded(false); assert(~c.crcFailure&&c.bitErrors==0,'Coded PDSCH must recover the payload.');
d=uni02_coded(true); assert(d.crcFailure,'Wrong identity must fail the coded payload CRC.');
disp('uni02 receiver tests passed');
end
