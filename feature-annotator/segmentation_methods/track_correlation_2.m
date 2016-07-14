function output_feature = ...
    track_correlation_2(input_feature, tif_directory, varargin)
% allows you to choose a feature in the key frames of a time series, then
% track the feature from frame to frame.


size_T = length(dir(fullfile(tif_directory,'T_*')));
im1 = load_tiff_stack(fullfile(tif_directory,sprintf('T_%05d.tif',1)));

%
% use input_options, otherwise global_options, otherwise defaults
% 

default_options = struct(...
                    'xy_filter', 1, ...
                    't_filter', 1, ...
                    'threshold', nan, ...
                    'binary_threshold', nan, ...
                    'drift', 5*ones(ndims(im1),1), ...
                    'learn_drift', false, ...
                    'timeout', Inf, ...
                    'plot_fit', false, ...
                    'learning_rate', 0.3, ...
                    'debug_timing', true, ...
                    'push_updates', false, ...
                    'fine_tune', false, ...
                    'start_time', 1);

input_options = varargin2struct(varargin{:}); 

global feature_annotator_data;

if isfield(feature_annotator_data, 'segmentation_options')
    global_options = feature_annotator_data.segmentation_options;
else
    global_options = struct;
end

options = mergestruct(default_options, global_options);
options = mergestruct(options, input_options);

feature_size = input_feature.size; % this is one less than the actual size
offset_to_center = round(0.5*feature_size);

% modified (control) points, along with the unmodified control point of the
% start time if a modified one is not present.
m = input_feature.modified_coordinates;
if isnan(m(options.start_time,1))
    m(options.start_time,:) = ...
        input_feature.coordinates(options.start_time,:);
end

% If we're fine tuning, use the current coordinate value as our guess.
if options.fine_tune
    m = input_feature.coordinates;
end

[i, j] = ind2sub(size(m), find(~isnan(m)));
input_times = unique(i);
input_times = input_times(input_times >= options.start_time);
input_times(end+1) = size_T+1;

output_feature = input_feature;

drift = options.drift;
new_drift = drift;

runtime = tic;
for i = 1:length(input_times)-1
    start_time = input_times(i);
    end_time = input_times(i+1)-1;
        
    feature_location = round(m(start_time,:));
    
    % determine the initial feature for matching
    im = load_tiff_stack(fullfile(...
                            tif_directory, ...
                            sprintf('T_%05d.tif',start_time)));
    feature_image = double(get_image_section( ...
                              feature_location, feature_size, im));

    new_feature_image = feature_image;
    
    for t = start_time:end_time
        
        if options.debug_timing
            disp(['starting time point ' num2str(t)]);
        end

        feature_image = (1-options.learning_rate) * feature_image + ...
                        options.learning_rate * new_feature_image;

        guess = feature_location + offset_to_center;
        
        if options.learn_drift
            drift = ceil(...
                        (1-options.learning_rate) * drift + ...
                        options.learning_rate * new_drift + ...
                        ones(size(drift)) ...                        
                    );
        end
        
        % get the image for the current step
        im = double(load_tiff_stack(fullfile(...
                            tif_directory, ...
                            sprintf('T_%05d.tif',t))));
        if options.xy_filter ~= 1
            im = imfilter(im, options.xy_filter);
        end
        if options.t_filter ~= 1
            warning('t filtering not implemented yet');
        end
        if ~isnan(options.threshold)
            im = im .* (im > options.threshold);
        end
        if ~isnan(options.binary_threshold)
            im = im > options.binary_threshold;
        end

        [indices, new_feature_image] = ...
            locate_feature_ND_corrcoef(feature_image, im, guess, drift);
        new_feature_image = double(new_feature_image);

        new_feature_location = indices - offset_to_center;
        output_feature.coordinates(t,:) = new_feature_location;
        
        new_drift = abs(new_feature_location - feature_location);
        
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
        
        % update feature location for next iteration
        feature_location = new_feature_location;        
        
    end
end
