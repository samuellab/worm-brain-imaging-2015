function save_features(features, filename, varargin)
% features = save_features(features, filename)
%   
%   Saves a cell array of features to the specified file.  If filename
%   is a directory, the features are saved to filename/features.mat.

default_options = struct(...
    'backup', 'true' ...
);

input_options = varargin2struct(varargin{:}); 
options = mergestruct(default_options, input_options);

if nargin == 0
    global feature_annotator_data;
    features = feature_annotator_data.features;
    [path, name, ext] = fileparts(feature_annotator_data.image_location);
    if isempty(ext)
        filename = fullfile(path, name);
    else
        filename = path;
    end
end

[~, ~, ext] = fileparts(filename);

if strcmp(ext, '.json')
    savejson('',features,filename);
elseif strcmp(ext, '.mat')
    save(filename, 'features');
elseif exist(filename, 'dir')
    s = fullfile(filename, 'features.mat');
    if options.backup
        old_features = load_features(s);
        s_backup = append_timestamp(s);
        save_features(old_features, s_backup);
    end
    save(fullfile(filename, 'features.mat'), 'features');
end