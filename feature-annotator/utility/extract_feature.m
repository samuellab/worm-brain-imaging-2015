function extract_feature(features, image_location, varargin)
% extract_feature(features, image_location)
%
% To extract the feature with index 1 in freature_annotator_data.features,
%   extract_features(1)
%
% extract the specified feature from the images in image_location and saves
% it as a separate tif stack for further annotation.
%
% if features is a cell array, each feature will be extracted into its own
% directory
%
% if no args are provided, the global feature_annotator_data.features
% object will be used along with the global 
% feature_annotator_data.image_location.


if nargin < 2
    global feature_annotator_data;
    image_location = feature_annotator_data.image_location;
    
    if nargin == 1
        if isnumeric(features)
            idx = features;
            features = feature_annotator_data.features(idx);
        end
    else
        features = feature_annotator_data.features;
    end
    
    if isfield(feature_annotator_data, 'color')
        color = feature_annotator_data.color;
        folder_suffix = ['_' color];
    else
        color = '';
    end
end

if ~iscell(features)
    features = {features};
end

[path, name, ext] = fileparts(image_location);
if strcmp(ext, '.mat')
    input_directory = path;
    if isfield(feature_annotator_data, 'color')
        color = feature_annotator_data.color;
        folder_suffix = ['_' color];
    end
else    
    input_directory = fullfile(path, name);
    folder_suffix = '';
end
time_file = fullfile(input_directory, 'times.json');

if exist(time_file, 'file')
    times = loadjson(time_file);
else
    times = false;
end

opts = varargin2struct(varargin{:});

size_T = get_size_T(image_location);


for f = 1:length(features)
    
    u = nan(size_T, 3);
    
    feature = features{f};
    output_directory = fullfile(input_directory,...
                                [sprintf('cropped_%s',feature.name) ...
                                 folder_suffix]);
    if isstruct(times)
        new_times.offset = times.offset;
    end
    
    t_idx = 1;
    for t = 1:size_T
        
        if ~isfield(feature, 'is_bad_frame') || ...
           ~feature.is_bad_frame(t)

            im = load_image(image_location, 't', t, 'c', color);
            
            offset = round(feature.coordinates(t,:));
            u(t, :) = offset - 1;
            
            im_sec=get_image_section(offset, feature.size, im);
            
            save_tiff_stack(im_sec, fullfile(output_directory,...
                                     sprintf('T_%05d.tif',t_idx)));
            if isstruct(times)
                new_times.times(t_idx, 1) = times.times(t, 1);
            end
            t_idx = t_idx + 1;
            
        end
        
    end
    
    save_transformation(struct('u',u), output_directory);
    
    if isstruct(times)
        savejson('', new_times, fullfile(output_directory, 'times.json'));
    end
end