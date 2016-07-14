function output_feature = track_local_imwarp(input_feature, image_location, varargin)
% tracks the motion of a bright point

global feature_annotator_data;


default_options = struct(...
                    'xy_filter', 1, ...
                    't_filter', 1, ...
                    'threshold', nan, ...
                    'binary_threshold', nan, ...
                    'drift', 5*ones(3,1), ...
                    'steps', 1, ...
                    'learn_drift', false, ...
                    'timeout', Inf, ...
                    'plot_fit', false, ...
                    'learning_rate', 0.3, ...
                    'debug_timing', true, ...
                    'push_updates', false, ...
                    'fine_tune', false, ...
                    'start_time', 1, ...
                    'reference_features', [], ...
                    'lookup_threshold', 0.1, ...
                    'update_registration', false, ...
                    'image_matfile', [] ...
                    );

input_options = varargin2struct(varargin{:}); 

if isfield(feature_annotator_data, 'segmentation_options')
    global_options = feature_annotator_data.segmentation_options;
else
    global_options = struct;
end

options = mergestruct(default_options, global_options);
options = mergestruct(options, input_options);

reference_features = options.reference_features;
if isnumeric(reference_features)
    reference_features = ...
        feature_annotator_data.features(reference_features);
    for i = 1:length(reference_features)
        if strcmp(reference_features{i}.name, input_feature.name)
            reference_features(i) = [];
            break
        end
    end
end

size_T = get_size_T(image_location);

im1 = load_image(image_location, 't', 1);
N = ndims(im1);

feature_size = input_feature.size; % this is one less than the actual size
offset_to_center = 0.5*feature_size;

if ~isempty(options.image_matfile)
    mfile = matfile(options.image_matfile.name);
    load_im = @(t) mfile.(options.image_matfile.channel)(:,:,:,t);
else
    load_im = @(t) load_image(image_location, 't', t);
end

get_local_vol = @(t, center) ...
    get_image_section(center-offset_to_center, ...
        feature_size, ...
        load_im(t));
    
get_tform_MeanSquares = @(src, target) ...
    imregtform(src, target, 'affine', ...
        registration.optimizer.RegularStepGradientDescent, ...
        registration.metric.MeanSquares, ...
        'PyramidLevels', 2);

get_tform_MutualInformation = @(src, target) ...
    imregtform(src, target, 'affine', ...
        registration.optimizer.RegularStepGradientDescent, ...
        registration.metric.MattesMutualInformation, ...
        'PyramidLevels', 2);
    
get_tform_x = get_tform_MutualInformation;
get_tform_y = get_tform_MutualInformation;
get_tform_z = get_tform_MeanSquares;

output_feature = input_feature;

% modified (control) points, along with the unmodified control point of the
% start time if a modified one is not present.
m = input_feature.modified_coordinates;
if isnan(m(options.start_time,1))
    m(options.start_time,:) = ...
        input_feature.coordinates(options.start_time,:);
end

% If we're fine tuning, use the current coordinate value as our guess,
% making sure to not overwrite any manually modified coordinates
if options.fine_tune
    for t = 1:size_T
        if isnan(m(t,1))
            m(t,:) = input_feature.coordinates(t,:);
        end
    end
end

[i , ~] = ind2sub(size(m), find(~isnan(m)));
input_times = unique(i);
input_times = input_times(input_times >= options.start_time);
input_times(end+1) = size_T+1;

runtime = tic;
for i = 1:length(input_times)-1
    start_time = input_times(i);
    end_time = input_times(i+1)-1;
        
    feature_location = m(start_time,:);
    
    t_last = start_time;
    
    for t = start_time:end_time
        
%         try
        
            if isfield(feature_annotator_data, 'bad_frames') ...
                       && ismember(t, feature_annotator_data.bad_frames)
                continue;
            end
            im = load_im(t);
            im = feature_annotator_filter(im);

            guess = feature_location + offset_to_center;

            % If there are reference features, use them to 
            % rigidly estimate where our point should go.

            near_features = [];
            good_refs = [];
            source = [];
            target =[];
            t_best = [];
            if ~isempty(reference_features) && t > start_time
                for j = 1:length(reference_features)
                    if    ~reference_features{j}.is_bad_frame(t_last) ...
                        &&~reference_features{j}.is_bad_frame(t) ...
                        && reference_features{j}.is_registered(t_last) ...
                        && reference_features{j}.is_registered(t)

                        good_refs = [good_refs j];
                        source(:, length(good_refs)) = ...
                            reference_features{j}.coordinates(t_last,:)' + ...
                            reference_features{j}.ref_offset';
                        target(:, length(good_refs)) = ...
                            reference_features{j}.coordinates(t,:)' + ...
                            reference_features{j}.ref_offset';
                    end
                end
            end

            good_features = reference_features(good_refs);

            if length(good_refs) >= 4

                nearest_4 = find_nearest(guess, source, 4);
                near_features = good_features(nearest_4);
                [lookup_guess, fit, t_best] = lookup_feature_location(...
                                                output_feature, ...
                                                near_features, ...
                                                t, ...
                                                'modified_only', false);
                disp(['Got fit : ' num2str(fit) ' from frame ' ...
                      num2str(t_best) ' for frame ' num2str(t)]);
                if fit > options.lookup_threshold
                % Lookup answer based on previously registered frames.
                    guess = lookup_guess;
                    disp('Looked up answer!');
                else 
%                 % Do a rigid transform using the nearest 4 references.
                    source = source(:, nearest_4(2));
                    target = target(:, nearest_4(2));
%                     transform = estimateRigidTransform(target, source);
%                     guess = transform * column([guess 1]); %homog. coords.
%                     guess = row(guess(1:3));
                    displacements = target - source;
                    guess = guess + mean(displacements, 2)';
                end

            elseif length(good_refs) == 3

                nearest_3 = find_nearest(guess, source, 3);
                near_features = good_features(nearest_3);
                [lookup_guess, fit, t_best] = lookup_feature_location(...
                                        output_feature, ...
                                        near_features, ...
                                        t);
                disp(['Got fit : ' num2str(fit) ' from frame ' ...
                      num2str(t_best) ' for frame ' num2str(t)]);
                if fit > options.lookup_threshold
                % Lookup answer based on previously registered frames.
                    guess = lookup_guess;
                    disp('Looked up answer!');
                else 
%                 % Do a rigid transform using the nearest 3 references.
                    source = source(:, nearest_3(2));
                    target = target(:, nearest_3(2));
%                     transform = estimateRigidTransform(target, source);
%                     guess = transform * column([guess 1]); %homog. coords.
%                     guess = row(guess(1:3));
                    displacements = target - source;
                    guess = guess + mean(displacements, 2)';
                end
            elseif ~isempty(good_refs) % translation only
                displacements = target - source;
                guess = guess + mean(displacements, 2)';
            end

            % Now use the guess along with local max-intensity projections to
            % determine a set of 3 image transformations (x, y, and z) that
            % will be used to update the guess.

            % If we there's a previous match, use that frame (even if it wasn't
            % sufficient for lookup).
            
            if ~isempty(t_best) && fit > 0.07 % hard coded minimum fit quality
                t_ref = t_best;
            else
                t_ref = t_last;
            end

            if ~isnan(m(t_ref,:))
                old_coords = m(t_ref,:);
            else
                old_coords = output_feature.coordinates(t_ref,:);
            end
            old_center = old_coords + offset_to_center;

            old_center = feature_location + offset_to_center;
            prev_vol = get_local_vol(t_ref, old_center);
            curr_vol = get_local_vol(t, guess);

            px = max_intensity_x(prev_vol);
            py = max_intensity_y(prev_vol);
            pz = max_intensity_z(prev_vol);

            cx = max_intensity_x(curr_vol);
            cy = max_intensity_y(curr_vol);
            cz = max_intensity_z(curr_vol);

            tx = get_tform_x(px, cx);
            ty = get_tform_y(py, cy);
            tz = get_tform_z(pz, cz);

            new_center = 1 + offset_to_center;
            [new_x(1), new_y(1)] = ...
                transformPointsForward(tz, new_center(2), new_center(1));
            [new_z(1), new_y(2)] = ...
                transformPointsForward(tx, new_center(3), new_center(1));
            [new_x(2), new_z(2)] = ...
                transformPointsForward(ty, new_center(2), new_center(3));

            new_x = mean(new_x);
            new_y = mean(new_y);
            new_z = mean(new_z);

            guess = guess + ([new_y, new_x, new_z]-1 - offset_to_center);

            for step = 1:options.steps

                % make a circular gaussian mask to penalize large drifts
                if ~all(isnan(options.drift))

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

                % use a second gaussian mask to avoid nearby reference
                % features.
                if ~isempty(near_features)
                    mask = ones(size(im));

                    XN = cell(1,N);
                    for j=1:N
                        gv{j} = 1:size(mask,j);
                    end
                    [XN{:}] = ndgrid(gv{:});

                    for k=1:length(near_features)

                        % Find the distance to the reference feature.  That
                        % will determine if need to include it, and also will
                        % set scale for excluded region's width.
                        ref = near_features{k}.coordinates(i,:) + ...
                              near_features{k}.ref_offset;
                        d = norm(ref - guess);

                        feature_mask = ones(size(im));

                        scale = 1.5;
                        height = 3;

                        s = options.drift;
                        for j = 1:N

                            feature_mask = height/scale * feature_mask .* ...
                                                exp(-((XN{j} - ref(j)).^2/ ...
                                                        ((scale*s(j))^2)));
                        end

                        mask = mask - feature_mask;
                    end

                    im = double(im).*mask;
                end

                % choose the brightest point

                guess = subpixel_max_ND(im);
            end
            
            new_feature_location = guess - offset_to_center;
            output_feature.coordinates(t,:) = new_feature_location;
            
            if options.update_registration
                output_feature.is_registered(t) = true;
            end
            
            feature_location = new_feature_location;
        
%         catch err
%             
%             warn(err.identifier);
%             output_feature.is_bad_frame(t) = true;
%             
%         end
        
        t_last = t;



        % plot to feature_annotator
        if options.push_updates
            feature_annotator_data.features{options.push_updates} = ...
                    output_feature;
            feature_annotator_data.t = t;
            feature_annotator_data.z = round(guess(3));
            feature_annotator_data.projection_ok = false;
            feature_annotator_callbacks('Update_Image');
            pause(0.001);
        end
        
        toc(runtime)
        % if we've been running too long, return
        if toc(runtime) > options.timeout
            return;
        end
        
    end

end



end