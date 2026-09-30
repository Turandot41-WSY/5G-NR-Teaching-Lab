function test_uni05
assert(exist('uni05_link','file')==2,'uni05:missing','The coding experiment must exist.');
a=uni05_link(12,[0 2 3 1],52001,1024,0.5,2048,12);
assert(~a.fail(1) && a.bitErrors(1)==0,'High SNR round trip failed.');
b=uni05_link(-8,[0 2 3 1],52001,1024,0.5,2048,12);
assert(b.fail(1),'The failure fixture must fail the CRC.');
assert(all(size(b.recovered{1})==size(b.combined{1})),'Soft buffers disagree.');
assert(b.info.C==1 && b.info.BGN==2,'Expected the one code block BG2 fixture.');
large=uni05_link(12,[0 2],52001,9000,.5,18000,12);
assert(large.info.C==2 && ~large.fail(1),'Segmented block must recover with per-block iteration counts.');
disp('uni05 coding tests passed');
end
