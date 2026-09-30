function test_uni09_outputs
t=readtable(fullfile(fileparts(mfilename('fullpath')),'results','per_ue.csv'));
assert(all(isnan(t.DLDelayMs(t.DLDeliveredBytes==0))),'UNI09:UndefinedDelay','No delivered packets must mean undefined delay.');
assert(all(isnan(t.ULDelayMs(t.ULDeliveredBytes==0))));
assert(all(t.DLJain>=.25 & t.DLJain<=1+1e-12));
assert(sum(t.DLRetransmissions+t.ULRetransmissions)>0);
fprintf('PASS missing delay semantics and actual retransmissions.\n');
end
