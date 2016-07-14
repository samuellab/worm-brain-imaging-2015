function features = merge_features(features, new_features, new_times)
% features = merge_features(features, new_features, new_times)
%
%   Merges new_features into features, mapping onto the specified new
%   times.

if ~isempty(features)
    size_T = get_size_T(features{1});
else
    size_T = 1;
end

size_new = get_size_T(new_features{1});

if nargin < 3
    new_times = size_T+1 : size_T+size_new;
end

new_size_T = max([size_T, new_times]);

for i = 1:length(new_features)
    nf = new_features{i};

    [f, idx] = features_get(features, nf.name);

    if isempty(idx)

        idx = length(features)+1;
        f = new_feature(nf.name, new_size_T, nf.size, ...
            'coordinates', nf.coordinates(1, :));

    end

    for j = 1:size_new

        f.coordinates(new_times(j), :) = ...
            get_feature_center(nf, j);
        f.modified_coordinates(new_times(j), :) = ...
            get_feature_center(nf, j);
        f.is_bad_frame(new_times(j), :) = nf.is_bad_frame(j, :);
        f.is_registered(new_times(j), :) = nf.is_registered(j, :);

    end

    features{idx} = f;

end