function size_u = get_size_u(F)
% size_u = get_size_u(directory)
%
%   Returns the number of transforms in a directory.

if isa(F, 'char') && exist(F, 'dir') % TIF directory
    size_u = length(dir(fullfile(F, 'u_*')));
    return
end