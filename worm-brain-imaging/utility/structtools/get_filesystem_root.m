function root = get_filesystem_root(field)
% root = GET_FILESYSTEM_ROOT()
%
%   Determines the root path for the current machine. This requires a file
%   named 'disk_locations.yaml' to be in the matlab search path, and that
%   file must have the field 'nas' or 'local'. 'nas' is returned by
%   default.
%
% root = GET_FILESYSTEM_ROOT('nas')
%
%   Returns the root directory for data stored on a network.
%
% root = GET_FILESYSTEM_ROOT('local')
%
%   Returns the root directory for data stored on a local disk.
%
% root = GET_FILESYSTEM_ROOT('blah')
%
%   Returns the root directory specified by field 'blah' in
%   'disk_locations.yaml'

S = structtools.load_yaml('disk_locations.yaml');

if nargin == 1
    root = S.(field);
else
    if isfield(S, 'nas')
        root = S.nas;
        return;
    elseif isfield(S, 'local')
        root = S.local;
        return;
    else
        error('Please specify a location from disk_locations.yaml');
    end
end
    