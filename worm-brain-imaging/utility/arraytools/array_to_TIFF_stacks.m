function array_to_TIFF_stacks(A, location)
% ARRAY_TO_TIFF_STACKS(A, location)
%
%   Writes out the array A to a series of TIFF stacks in the directory
%   specified by location. The files will be numbered T_00034.tif, and A
%   will be sliced along its last dimension.


S = size(A);
N = ndims(A);

size_T = S(end);

for i = 1:(N-1)
    idx{i} = ':';
end

if ~exist(location,'dir')
    mkdir(location);
end

for t = 1:size_T
    save_tiff_stack(A(idx{:},t),...
        fullfile(location,sprintf('T_%05d.tif',t)));
end