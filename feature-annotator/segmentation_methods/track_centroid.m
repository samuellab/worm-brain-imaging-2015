function output_feature = track_centroid(input_feature, image_location, varargin)
% tracks the motion of a bright point

global feature_annotator_data;

%
% use input_options, otherwise global_options, otherwise defaults
%

im1 = load_image(image_location, 't', 1);
size_T = get_size_T(image_location);
size_X = size(im1,2);
size_Y = size(im1,1);
N = ndims(im1);

default_options = struct(...
                    'xy_filter', 1, ...
                    't_filter', 1, ...
                    'threshold', nan, ...
                    'binary_threshold', nan, ...
                    'drift', 5*ones(ndims(im1),1), ...
                    'global_search', false, ...
                    'learn_drift', false, ...
                    'timeout', Inf, ...
                    'plot_fit', false, ...
                    'learning_rate', 0.3, ...
                    'debug_timing', true, ...
                    'push_updates', false, ...
                    'fine_tune', false, ...
                    'reference_features', [], ...
                    'start_time', 1);

input_options = varargin2struct(varargin{:}); 

if isfield(feature_annotator_data, 'segmentation_options')
    global_options = feature_annotator_data.segmentation_options;
else
    global_options = struct;
end

options = mergestruct(default_options, global_options);
options = mergestruct(options, input_options);

feature_size = input_feature.size; % this is one less than the actual size
offset_to_center = 0.5*feature_size;

reference_features = options.reference_features;

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
    
    for t = start_time:end_time
        if isfield(feature_annotator_data, 'bad_frames') ...
                   && ismember(t, feature_annotator_data.bad_frames)
            continue;
        end
        
        im = load_image(image_location, 't', t);
        if options.xy_filter ~= 1
            im = imfilter(im,options.xy_filter);
        end
        if options.t_filter ~= 1
            warning('t filtering not implemented yet');
        end
        if ~isnan(options.threshold)
            im(im<options.threshold) = 0;           
        end
        if ~isnan(options.binary_threshold)
            im = im > options.binary_threshold;           
        end
        
        guess = feature_location + offset_to_center;
        
        % make a circular gaussian mask to penalize large drifts
        if ~options.global_search && ~all(isnan(options.drift))

            mask = ones(size(im));
        
            XN = cell(1,N);
            for j=1:N
                gv{j} = 1:size(mask,j);
            end
            [XN{:}] = ndgrid(gv{:});
            for j=1:N
                mask = mask.*exp(-((XN{j} - guess(j)).^2/ ...
                                  (2*options.drift(j)^2)));
            end 
            im = double(im).*mask;
        end
        
         % use a second gaussian mask to avoid nearby reference features.
        if ~isempty(reference_features)
            mask = ones(size(im));
            
            XN = cell(1,N);
            for j=1:N
                gv{j} = 1:size(mask,j);
            end
            [XN{:}] = ndgrid(gv{:});
            
            for k=1:length(reference_features)
                
                % Find the distance to the reference feature.  That will
                % determine if need to include it, and also will set the
                % scale for excluded region's width.
                ref = reference_features{k}.coordinates(i,:) + ...
                      reference_features{k}.ref_offset;
                d = norm(ref - guess);
                
                feature_mask = ones(size(im));
                
                for j = 1:N
                    feature_mask = feature_mask .* ...
                                        exp(-((XN{j} - ref(j)).^2/ ...
                                                (2*(d/10)^2)));
                end
                
                mask = mask - feature_mask;
            end
            
            im = double(im).*mask;
        end
        
        % choose the centroid, round to 2 decimal places
        if options.global_search
            coords = round(100*centroid(im))/100;
            new_feature_location = coords - offset_to_center;
        else
            
            fea = get_image_section(round(feature_location), ...
                                        feature_size, im);
            coords = round(100*centroid(fea))/100;

            new_feature_location = round(feature_location) ...
                                   + coords-1 ...
                                   - offset_to_center;
        end
        
        output_feature.coordinates(t,:) = new_feature_location;
        feature_location = new_feature_location;
        
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



end