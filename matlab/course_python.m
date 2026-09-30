function python = course_python
% Locate the existing Python environment selected by setup/install.py.
python = getenv('COURSE_PYTHON');
if isempty(python)
    root=fileparts(fileparts(mfilename('fullpath')));
    config=fullfile(root,'local-config.json');
    folder='.venv';
    if isfile(config)
        c=jsondecode(fileread(config));
        if isfield(c,'python'), python=c.python; end
        if isfield(c,'environment'), folder=c.environment; end
    end
    if isempty(python)
        if ispc
            if strcmp(folder,'.conda')
                python=fullfile(root,folder,'python.exe');
            else
                python=fullfile(root,folder,'Scripts','python.exe');
            end
        else
            python=fullfile(root,folder,'bin','python');
        end
    end
end
assert(isfile(python),'Course:Python','Run python setup/install.py before using the ASN.1 codec.');
end
