function uni03_setup
root=fileparts(mfilename('fullpath'));
addpath(fileparts(root));
addpath(fullfile(root,'..','uni01'));
example=getenv('NR_CELL_SEARCH_EXAMPLE');
if ~isempty(example), addpath(example); end
assert(~isempty(which('hPDCCH0Configuration')),'uni03:Dependency', ...
    ['Open the licensed MathWorks example with openExample(''5g/NRCellSearchMIBAndSIB1RecoveryExample''). ' ...
     'Set NR_CELL_SEARCH_EXAMPLE to its folder; see setup/README.md.']);
end
