function s=uni08_states(p,rar,identity,recovered,slots,fault)
% Selected TS38.3215.1 and38.3315.3.3 transition guards.
s=struct('connected',false,'firstDL',false,'firstUL',false,'trace',{{'SIB1_DECODED','PRACH_SENT'}});
if strcmp(fault,'missing RAR')||strcmp(fault,'wrong RAPID')||p{1}.crc||rar.rapid~=0
    s.trace{end+1}='RAR_WINDOW_EXPIRED';return;
end
assert(mod(slots(1),10)<4);s.trace{end+1}='RAR_ACCEPTED';
if strcmp(fault,'Msg3 CRC failure')||p{2}.crc,s.trace{end+1}='CONTENTION_TIMER_EXPIRED';return;end
s.trace{end+1}='SETUP_REQUEST_DECODED';
if strcmp(fault,'wrong contention identity')||p{3}.crc||~isequal(identity,recovered.request)
    s.trace{end+1}='CONTENTION_TIMER_EXPIRED';return;
end
s.trace{end+1}='CONTENTION_RESOLVED';
s.trace{end+1}='UE_RRC_CONNECTED';
if strcmp(fault,'SetupComplete transaction mismatch'),s.trace{end+1}='GNB_AWAITS_MATCHING_COMPLETE';return;end
if strcmp(fault,'SetupComplete CRC failure')||p{4}.crc,s.trace{end+1}='GNB_AWAITS_COMPLETE';return;end
s.connected=true;s.trace{end+1}='GNB_SETUP_COMPLETE';
s.firstDL=~p{5}.crc;s.firstUL=~p{6}.crc;
if s.firstDL&&s.firstUL,s.trace{end+1}='CONNECTED_AND_BIDIRECTIONAL';end
end
