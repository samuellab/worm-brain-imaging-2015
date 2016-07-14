function features = find_nuclei_in_volume(image, t, siz, sep, N_max, varargin)
% features = FIND_NUCLEI_IN_VOLUME(image_location, t, siz, sep, N_max)
%
%   This locates brightest dots in a volume v that are roughly a given
%   size and separated by a given amount.
%
%   features is a FeatureCollection of BoxFeatures, with at most N_max
%   elements.

default_options = struct(...
    'filter', @(x) x ...
);

input_options = varargin2struct(varargin{:}); 
options = mergestruct(default_options, input_options);

vol = get_slice(image, t);
filtered_vol = options.filter(vol);

locations = find_local_maxima(filtered_vol, siz, ...
    'minimum_separation', sep, ...
    'max', N_max);

creator = struct(...
    'Method', 'find_nuclei_in_volume', ...
    'siz', siz, ...
    'sep', sep, ...
    'N_max', N_max, ...
    'Options', input_options);

for i = 1:size(locations, 1)

    f{i} = BoxFeature(siz, locations(i,:), t, image, creator);

end

features = FeatureCollection(f);