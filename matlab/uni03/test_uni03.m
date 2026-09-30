function test_uni03
assert(exist('uni03_table','file')==2,'uni03:MissingTable','CORESET table function must exist.');
m=struct('crcError',false,'pdcchConfigSib1',0,'subcarrierSpacingCommon',30,'kSsb',0,'ssbIndex',0,'systemFrameNumber',426,'cellID',321,'dmrsTypeAPosition',2);
q=uni03_table(m);
assert(q.nrb==24 && q.duration==2 && q.offsetRB==0 && isequal(q.monitorSlots,[0 1]));
m.pdcchConfigSib1=16; q=uni03_table(m); assert(q.offsetRB==1);
m.crcError=true;
try, uni03_table(m); error('uni03:ExpectedReject','Bad MIB accepted'); catch e, assert(strcmp(e.identifier,'uni03:MibCRC')); end
disp('CORESET mapping and bad MIB tests passed');
assert(exist('uni03_tx','file')==2,'uni03:MissingTransmitter','Broadcast transmitter must exist.');
t=uni03_tx; r=uni03_receive(t.mib,t.grid,struct);
assert(r.dciCRC==0 && r.transportCRC==0 && isequal(r.transportBits,t.transportBits));
w=uni03_receive(t.mib,t.grid,struct('siRNTI',65534)); assert(w.dciCRC~=0);
disp('Broadcast transport and wrong identity tests passed');
end
