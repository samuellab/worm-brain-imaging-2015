function features = find_nuclei_in_volume_old(image_location, t, siz, sep, N_max, varargin)
% features = FIND_NUCLEI_IN_VOLUME(image_location, t, siz, sep, N_max)
%
%   This locates bright dots in a volume v that are roughly a given size,
%   separated by a given amount, and have a peak intensity above a given
%   threshold.

default_options = struct(...
    'filter', @(x) x ...
);

input_options = varargin2struct(varargin{:}); 
options = mergestruct(default_options, input_options);

size_T = get_size_T(image_location);
vol = load_image(image_location, 't', t);
filtered_vol = options.filter(vol);

locations = find_local_maxima(filtered_vol, 0.5*siz, ...
    'minimum_separation', sep, ...
    'max', N_max);

for i = 1:size(locations, 1)

    x = locations(i,:) - siz/2;

    features{i} = new_feature(sprintf('neuron_%03d',i), size_T, siz, ...
        'coordinates', x);
    features{i}.modified_coordinates(t, :) = x;

end