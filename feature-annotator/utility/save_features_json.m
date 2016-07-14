function output = save_features_json(features, JSONfilename)
% features = save_features(features, JSONfilename)
%   
%   Saves a cell array of features to the specified file.  If JSONfilename
%   is a directory, the features are saved to JSONfilename/features.json.

if nargin == 0
    global feature_annotator_data;
    features = feature_annotator_data.features;
    [path, name, ext] = fileparts(feature_annotator_data.image_location);
    if isempty(ext)
        JSONfilename = fullfile(path, name);
    else
        JSONfilename = path;
    end
end

[~, ~, ext] = fileparts(JSONfilename);

if strcmp(ext, '.json')
    savejson('',features,JSONfilename);
elseif exist(JSONfilename, 'dir')
    savejson('',features,fullfile(JSONfilename, 'features.json'));
end