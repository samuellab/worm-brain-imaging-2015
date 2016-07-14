function y = get_fullfile(s, f, varargin)
% y = GET_FULLFILE(s, f)
%
%   Gets the filename in field f of struct s. If s has a field named
%   'f_directory', the returned value is fullfile(s.f_directory, s.f).
%   Otherwise, this is equivalent to calling s.f.
%
% y = GET_FULLFILE(s, f, 'append_root', true)
%
%   Generates a full filename by adding the system's data root directory.
%
% y = GET_FULLFILE(s, f, 'append_root', 'local')
%
%   Generates a full filename by prepending the location described by
%   'local'.

default_options = struct(...
    'append_root', false ...
);
input_options = structtools.varargin_to_struct(varargin{:});
options = structtools.merge_struct(default_options, input_options);

dir_string = [f '_directory'];

if isfield(s, dir_string)
    y = fullfile(s.(dir_string), s.(f));
else
    y = s.(f);
end

if options.append_root
    
    if ischar(options.append_root)
        root = structtools.get_filesystem_root(options.append_root);
    else
        root = structtools.get_filesystem_root();
    end
    
    y = fullfile(root, y);
    
end
    