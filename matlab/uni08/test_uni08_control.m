function test_uni08_control
% Bounded DCI and feedback fixture; no main runner mutation.
a=uni08_control("RAR",struct('rnti',127,'slot',161,'seed',80801));
assert(numel(a.txBits)==37 && a.crc==0 && isequal(a.txBits,a.rxBits));
assert(a.fields.riv==264 && a.fields.mcs==4 && isequal(a.prbs,0:11));
assert(a.symbolScramblingRNTI==0 && a.crcRNTI==127);
assert(a.carrier.NStartGrid==4 && a.pdcch.NStartBWP==4);
b=uni08_control("MSG4",struct('rnti',4660,'slot',170,'seed',80802));
assert(numel(b.txBits)==37 && b.crc==0 && isequal(b.txBits,b.rxBits));
assert(b.fields.format==1 && b.fields.feedback==4 && b.feedbackSlot==175);
c=uni08_control("MSG4",struct('rnti',4660,'rxRnti',4661,'slot',170,'seed',80802));
assert(c.crc~=0,'Wrong CRC identity must be rejected.');
d=uni08_control("ACK",struct('slot',175,'ack',1,'seed',80803));
assert(d.detected && d.rxACK==1 && numel(d.symbols)==24);
assert(d.carrier.NStartGrid==0 && d.pucch.NStartBWP==0);
e=uni08_control("ACK",struct('slot',175,'ack',0,'seed',80804));
assert(e.detected && e.rxACK==0);
f=uni08_control("ACK",struct('slot',175,'ack',1,'seed',80805,'absent',true));
assert(~f.detected,'No transmitted feedback must not become a valid ACK.');
fprintf('PASS: RA/TC DCI37 bit payloads through OFDM and practical estimation; wrong RNTI rejected; PUCCH0 ACK/NACK/absent.\n');
end
