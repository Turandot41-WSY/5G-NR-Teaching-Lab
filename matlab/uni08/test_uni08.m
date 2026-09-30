function test_uni08
assert(exist('uni08_packet','file')==2,'UNI08:MissingPacket','Packet waveform implementation required.');
for direction=["DL" "UL"]
    rng(8008); bits=int8(randi([0 1],96,1));
    a=uni08_packet(direction,bits,Inf,0,1,0:11);
    assert(a.crc==0 && isequal(a.payload,bits));
end
assert(exist('uni08_rar','file')==2,'UNI08:MissingRAR','RAR serialization required.');
b=uni08_rar('encode',struct('rapid',0,'ta',80,'rnti',4660,'riv',264,'td',0,'mcs',4,'tpc',3));
c=uni08_rar('decode',b);
assert(numel(b)==64 && c.ta==80 && c.rnti==4660 && c.riv==264 && c.td==0);
fprintf('PASS: DL/UL payload equality and 64 bit RAR round trip.\n');
end
