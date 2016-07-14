function center_time_series(image_location, varargin)
% CENTER_TIME_SERIES(image_location)
%
%   Rigidly aligns all frames in a time series to a reference time.

default_options = struct(...
    't_ref', 1, ...
    'target_directory', fullfile(image_location, 'centered'), ...
    'decimation', 4, ...
    'smoothing', 10 ...
);

input_options = varargin2struct(varargin{:}); 
options = mergestruct(default_options, input_options);

t_ref = options.t_ref;
target_directory = options.target_directory;
mkdir(target_directory);

get_raw_volume = @(t) load_image(image_location, 't', t);
get_z_image = @(t) max_intensity_z(get_raw_volume(t));

get_filtered_image = @(t) automatically_smooth_image(get_z_image(t), ...
    options.smoothing);

get_thumbnail = @(t) imresize(get_filtered_image(t), 1/options.decimation);

save_tform = @(S, t) save(fullfile(...
    target_directory, sprintf('u_%05d.mat', t)), '-struct', 'S');

large_size = size(get_z_image(t_ref));
reference_image = get_thumbnail(t_ref);

size_X = size(reference_image, 2);
size_Y = size(reference_image, 1);
size_T = get_size_T(image_location);

% Referencing information for the centered view
ref_c = get_output_view([-0.5 0.5]*size_X, [-0.5 0.5]*size_Y);

% Save the transform for the reference image.
S.tform = affine2d(eye(3));
S.R = imref2d(large_size);
save_tform(S, t_ref);

[optimizer, metric] = imregconfig('monomodal');

[img0_center, tform0] = center_image(reference_image, ref_c);


for t = [1:t_ref-1, t_ref+1:size_T]
    
    img = get_thumbnail(t);
    [img_center, tform_center] = center_image(img, ref_c);
    
    tform_2 = imregtform(img_center, ref_c, img0_center, ref_c, ...
            'rigid', optimizer, metric, 'PyramidLevels', 1);
    
    tform = compose_transforms(tform_center, tform_2, tform0.invert());
    
    tform.T(end,1:2) = options.decimation * tform.T(end,1:2);
    
    S.tform = tform;
    S.R = imref2d(large_size);
    
    save_tform(S, t);
    
end

worldlimits.global_XWorldLimits = [1, large_size(2)] - 0.5;
worldlimits.global_YWorldLimits = [1, large_size(1)] - 0.5;
worldlimit_filename = fullfile(target_directory, 'WorldLimits.mat');
save(worldlimit_filename, '-struct', 'worldlimits');

generate_transformed_images(target_directory);