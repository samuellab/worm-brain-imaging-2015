function output = load_features_json(JSONfilename)
% features = load_features(JSONfilename)
%   loads a cell array of features from the input filename
%
% features = load_features(tif_directory)
%   loads features from tif_directory/features.json
%
% features = load_features('directory/matfile.mat')
%   loads features from directory/features.mat
 
if exist(JSONfilename, 'dir')
    JSONfilename = fullfile(JSONfilename, 'features.json');
end

if exist(JSONfilename, 'file')
    [directory, ~, ext] = fileparts(JSONfilename);
    if strcmp(ext, '.mat')
        JSONfilename = fullfile(directory, 'features.json');
    end
    output = loadjson(JSONfilename);
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