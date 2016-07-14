function coords = get_all_feature_coordinates(features, time)
% coords = get_all_feature_coordinates(features, time)
%
%   Returns a list of coordinates of the N features at the given time. The
%   result is size Nx3
if nargin == 0
    global feature_annotator_data;
    features = feature_annotator_data.features;
end

if nargin < 2
    time = 1;
end

coords = zeros(length(features), 3);
for i = 1:length(features)
    c = get_feature_center(features{i}, time);
    coords(i,:) = column(c);
end
