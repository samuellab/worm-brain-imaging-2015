function ref_out = local_3_align(ref_in, idx, vol, varargin)
% ref_out = local_3_align(ref_in, idx, vol, varargin)
%
%   Aligns the point ref_in(:, idx) to a nearby local maximum in vol.  This
%   will also simultaneously align the two nearest neighbors of the main
%   point, penalizing large changes in pairwise distances.

default_options = struct( ...
    'metric', diag([1 1 4]), ...
    'weighting_function', @(x) 1/(1+x));
input_options = varargin2struct(varargin{:});
options = mergestruct(default_options, input_options);

g = options.metric;
N = size(ref_in, 1);

% Not including the metric here to encourage picking points separated in Z
all_separations = squareform(pdist(ref_in))+diag(Inf(1,N));

separations = all_separations(idx, :);

[~, I] = sort(separations);
neighbors = I(1:2);

idxs = [idx neighbors];
points = ref_in(idxs, :);

% Find the most separated point to align first
for i = 1:100
    
end