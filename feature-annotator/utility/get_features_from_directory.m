function features = get_features_from_directory(features, directory, indices)

all_files = dir(fullfile(directory, '*.mat'));

if nargin < 3
    indices = [];
    
    for i = 1:length(all_files)
        idx_us = strfind(all_files(i).name, '_');
        idx_us = idx_us(end);
        idx_dot = strfind(all_files(i).name, '.mat');
        filename = all_files(i).name;
        num_str = filename(idx_us+1 : idx_dot-1);
        indices = [indices, str2double(num_str)];
        name{i} = filename(1:idx_us-1);
        fn{i} = filename;
    end
end

if nargin < 2
   
    global feature_annotator_data;
    features = feature_annotator_data.features;
    
end

load_feat = @(x) load_features(fullfile(...
    directory, ...
    fn{x}...
));

indices
for i = 1:length(indices)
    
    f = load_feat(i);
    features(indices(i)) = f;
    
end

if nargin < 2
    
    features = feature_annotator_data.features;
    
end