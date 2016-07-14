function size_T = get_size_T(F)
% size_T = get_size_T(directory)
%
%   Returns the size of the time-dimension of a matfile or tif directory.

if isa(F, 'char') && exist(F, 'dir') % TIF directory
    size_T = length(dir(fullfile(F, 'T_*')));
    if size_T == 0
        features = load_features(F);
        size_T = size(features{1}.coordinates, 1);
    end
    return
end

if isa(F, 'matlab.io.MatFile')
    mfile = F;
    size_T = size(mfile, 'times', 2);
    return
end

if isa(F, 'char')
    mfile = matfile(F);
    size_T = size(mfile, 'times', 2);
    return
end

if isa(F, 'struct') && isfield(F, 'coordinates')
    size_T = size(F.coordinates, 1);
end

