function D = get_pairwise_image_distances(A, varargin)
% D = GET_PAIRWISE_IMAGE_DISTANCES(A)
%
%   Returns a sparse T x T array of pairwise distances between frames in
%   the time-series described by array A (T = size(A, ndims(A)). Distances
%   are computed using the overlap between images using a correlation
%   coefficient.

default_options = struct(...
    'f', @(x,y) 1 - get_image_overlap(x,y) ...
);

input_options = varargin2struct(varargin{:}); 
options = mergestruct(default_options, input_options);

size_T = size(A, ndims(A));

D = zeros(size_T, size_T);

for i = 1:size_T
    for j = (i+1):size_T

        D(i, j) = options.f(t_slice(A, i), t_slice(A, j));

    end
end

D = sparse(D + D');