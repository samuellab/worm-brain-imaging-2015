function f = get_average_feature(features, image_location, times)
% s = GET_AVERAGE_FEATURE(features, image_location, times)
%
%   Extracts the average feature from a particular location.

if nargin < 3
    times = 1;
end

if isempty(features)
    features = load_features(image_location);
end

f = [];
N = 0;
for t = times

    for i = 2:length(features)

        new_f = get_feature_image(t, features{i}, image_location);

        if isempty(f)
            f = new_f;
        else
            f = f + new_f;
        end

        N = N + 1;

    end

end

f = f/N;

