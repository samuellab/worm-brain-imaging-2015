function output_feature = cross_interpolate(input_feature, ...
                                            tif_directory, varargin)
% Tracks the motion of a feature by interpolating from the positions of
% existing features.

global feature_annotator_data;

im1 = load_tiff_stack(tif_directory, 1);

size_T = length(dir(fullfile(tif_directory, 'T_*')));
size_X = size(im1,2);
size_Y = size(im1,1);

N = ndims(im1);

default_options = struct(...
                    'drift', 5*ones(ndims(im1),1), ...
                    'learn_drift', false, ...
                    'timeout', Inf, ...
                    'plot_fit', false, ...
                    'learning_rate', 0.3, ...
                    'debug_timing', true, ...
                    'push_updates', true, ...
                    'metric', diag([1 1 4]), ...
                    'weighting_function', @(x) 1/(1+x), ...
                    'start_time', 1);
                
default_options.reference_features = feature_annotator_data.features(...
        cellfun(@(x) ~strcmp(x.name, input_feature.name), ...
                feature_annotator_data.features) ...
    );

input_options = varargin2struct(varargin{:}); 

if isfield(feature_annotator_data, 'segmentation_options')
    global_options = feature_annotator_data.segmentation_options;
else
    global_options = struct;
end

options = mergestruct(default_options, global_options);
options = mergestruct(options, input_options);

if isnumeric(options.reference_features)
    options.reference_features = feature_annotator_data.features( ...
        options.reference_features);
end

g = options.metric;
w = options.weighting_function;
reference_features = options.reference_features;

feature_size = input_feature.size; % this is one less than the actual size
offset_to_center = 0.5*feature_size;

% modified (control) points, along with the unmodified control point of the
% start time if a modified one is not present.
m = input_feature.modified_coordinates;
if isnan(m(options.start_time,1))
    m(options.start_time,:) = ...
        input_feature.coordinates(options.start_time,:);
end

[i j] = ind2sub(size(m), find(~isnan(m)));
input_times = unique(i);
input_times = input_times(input_times >= options.start_time);
input_times(end+1) = size_T+1;

output_feature = input_feature;

runtime = tic;
for i = 1:length(input_times)-1
    start_time = input_times(i);
    end_time = input_times(i+1)-1;
    
    feature_location = m(start_time,:);
    
    output_feature.coordinates(start_time, :) = feature_location;
    
    % reference locations
    d = {};
    for i = 1:length(reference_features)
        f = reference_features{i};
        d{i} = f.coordinates(start_time, :) + f.ref_offset;
    end
    
    for t = start_time+1 : end_time
        
        % previous coordinate
        x = output_feature.coordinates(t-1, :);
        
        for i = 1:length(reference_features)
            f = reference_features{i};
            d_new{i} = f.coordinates(t, :) + f.ref_offset;
            
            % displacement of feature i compared to last time step
            q(:,i) = column(d_new{i} - d{i});
            
            % displacement of target feature from reference feature
            offset = d{i} - (x + input_feature.ref_offset);
            
            % distance of target freature from reference feature i
            r(i) = offset * g * offset';
            
            d{i} = d_new{i};
        end
        
        weights = arrayfun(w, r);
        weights = weights / sum_all(weights);
        
        % new coordinate
        output_feature.coordinates(t, :) = x + weights * q';
        
        % plot to feature_annotator
        if options.push_updates
            feature_annotator_data.features{options.push_updates} = ...
                    output_feature;
            feature_annotator_data.t = t;
            feature_annotator_data.projection_ok = false;
            feature_annotator_callbacks('Update_Image');
            pause(0.001);
        end
        
        % if we've been running too long, return
        if toc(runtime) > options.timeout
            return;
        end
    end
        
end

