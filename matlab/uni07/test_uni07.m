function test_uni07
assert(exist('uni07_codebook','file')==2,'UNI07:MissingCodebook','Two port rank one codebook must exist.');
w=uni07_codebook;
assert(isequal(size(w),[2 4]) && max(abs(sum(abs(w).^2)-1))<1e-12);
assert(norm(w(:,2)-[1;1i]/sqrt(2))<1e-12);
assert(exist('run_uni07','file')==2,'UNI07:MissingRun','CSI experiment must exist.');
fprintf('PASS two port codebook and runner.\n');
end
