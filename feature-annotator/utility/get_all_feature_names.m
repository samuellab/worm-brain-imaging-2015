function names = get_all_feature_names(features)
% names = get_all_feature_names(features)
%
%   Returns a cell array of names of the provided features.

if nargin == 0
    global feature_annotator_data;
    features = feature_annotator_data.features;
end

for i = 1:length(features)
    names{i} = features{i}.name;
end
