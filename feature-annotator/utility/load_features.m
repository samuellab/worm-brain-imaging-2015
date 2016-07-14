function output = load_features(feature_file)
% features = load_features(JSONfilename)
%   loads a cell array of features from the input filename
%
% features = load_features(tif_directory)
%   loads features from tif_directory/features.json
%
% features = load_features('directory/matfile.mat')
%   loads features from directory/matfile.mat
 
if exist(feature_file, 'dir')
    feature_path = feature_file;
    feature_file = fullfile(feature_path, 'features.mat');
    if ~exist(feature_file, 'file')
        feature_file = fullfile(feature_path, 'features.json');
    end
end

if exist(feature_file, 'file')
    [dir, name, ext] = fileparts(feature_file);
    if strcmp(ext, '.mat')
%        if strfind(name, 'features')
            S = load(feature_file);
            output = S.features;
%        else
%            S = load(fullfile(dir, 'features.mat'));
%           output = S.features;
%        end
    elseif(strcmp(ext, '.json'))
        output = loadjson(feature_file);
    else
        error('Not a valid feature file extension.')
    end
else
    output = struct([]);
end

% ensure the top-level list is a cell, not an array
if ~iscell(output)
    x = {};
    for i = 1:length(output)
        x{i} = output(i);
    end
    output = x;
end