function [A, Rx, Ry, Rz] = orthoview_from_slices(x, y, z, pixel_size, varargin)
% A = ORTHOVIEW_FROM_SLICES(x, y, z)
%
%   Create a single image from three orthogonal slices or maximum intensity
%   projections. The arrangement is always as follows:
%
%       Z Z X
%       Z Z X
%       Y Y
%
% [A, Rx, Ry, Rz] = IMAGE_FROM_PROJECTIONS(x, y, z)
%
%   Optain spatial referencing information associated with the three
%   subregions of the resulting image. These are useful if you wish to add
%   annotations to the images.
%
% A = IMAGE_FROM_PROJECTIONS(x, y, z, pixel_size)
%
%   Prescribes the size of pixels to alter the aspect ratio of the final
%   image. pixel_size should be specified as [size_y, size_x, size_z].

default_options = struct(...
    'padding', 2 ...
);

input_options = varargin2struct(varargin{:}); 
options = mergestruct(default_options, input_options);

padding = options.padding;

sx = size(z, 2);
sy = size(z, 1);
sz = size(x, 2);

assert(sx == size(y, 2));
assert(sy == size(x, 1));
assert(sz == size(y, 1));

scaled_size = [sy sx sz] .* pixel_size;

scaled_x = imresize(x, [scaled_size(1), scaled_size(3)]);
scaled_y = imresize(y, [scaled_size(3), scaled_size(2)]);
scaled_z = imresize(z, [scaled_size(1), scaled_size(2)]);

width =  scaled_size(2) + padding + scaled_size(3);
height = scaled_size(1) + padding + scaled_size(3);

A = [scaled_z, ones(scaled_size(1), padding, size(x,3)), scaled_x; ...
    ones(padding, width, size(x,3)); ...
    scaled_y, ones(scaled_size(3), padding + scaled_size(3), size(x,3))];