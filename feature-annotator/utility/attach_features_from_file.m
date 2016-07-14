function attach_features_from_file(json_filename)
% grabs the feature list from a features.json file and attaches them to the
% feature annotator, replacing any features that may currently be there.
% the coordinates for the first frame in filename are used as the
% coordinates for every time in the open movie. [the only data taken from
% json_filename are those corresponding to t=1]
%
% call without any arguments to open a dialogue box for file selection

global feature_annotator_data

if nargin==0
    [filename, pathname] = uigetfile('.json', 'Select Feature File');
    json_filename = fullfile(pathname, filename);
end

features = loadjson(json_filename);

for i = 1:length(features)
    if isfield(features{i},'coordinates')
        features{i}.coordinates = ...
            kron(features{i}.coordinates(1,:),...
                 ones(feature_annotator_data.size_T,1));
    end
    if isfield(features{i},'modified_coordinates')
        features{i}.modified_coordinates = ...
            nan(feature_annotator_data.size_T, ...
                size(features{i}.modified_coordinates,2));
    end
end

feature_annotator_data.features = features;