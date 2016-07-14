function ref_out = flow_reference_points(ref_in, vol, varargin)
% ref_out = find_reference_points(ref_in, vol)
%
%   Takes an array of reference points and attempts to match them with high
%   intensity regions in vol.  ref_in should be 3 x N, where N is the
%   number of reference points.


default_options = struct( ...
    'metric', diag([1 1 4]), ...
    'filter', @(x) imfilter(x, ones(4,4,1)/16, 'symmetric'),...
    'weighting_function', @(x) 1/(1+x));

input_options = varargin2struct(varargin{:}); 
options = mergestruct(default_options, input_options);

vol = options.filter(vol);
g = options.metric;
N = size(ref_in, 2);
N_passes = 2;

k = 1;
refs{k} = ref_in;


for i = 1:N_passes
    for j = 1:N
        refs{k+1} = local_3_align(refs{k}, j, vol, options);
        k = k + 1;
    end
end

ref_out = refs{end};