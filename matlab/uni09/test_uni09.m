function test_uni09
assert(exist('run_uni09','file')==2,'UNI09:MissingRun','Connected network experiment must exist.');
assert(exist('wirelessNetworkSimulator','file')==2);
assert(exist('nrGNB','file')==2);
fprintf('PASS network dependencies and runner.\n');
end
