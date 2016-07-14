function save_tiff_folder(vol,directory)
% Takes an ND volume with time as the last index and saves it as a
% series of (N-1)D time slices labelled T_#####.tif (the format required by
% the feature annotator).  The output is stored in the folder 'directory'

size_v = size(vol);
N = ndims(vol);

size_T = size_v(end);

for i = 1:(N-1)
    idx{i} = ':';
end

if ~exist(directory,'dir')
    mkdir(directory);
end

for t = 1:size_T
    save_tiff_stack(vol(idx{:},t),...
        fullfile(directory,sprintf('T_%05d.tif',t)));
end