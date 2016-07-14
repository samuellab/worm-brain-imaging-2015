function find_tform_from_features(image_location, target_location, t_ref, varargin)
% find_rotations_from_features(image_location, target_location, reference_time)
%
%   Uses the x and y coordinates of the feature locations to determine a
%   transformation that maps each image onto the image at reference_time.
%
%   Target location specifies a child directory of image_location that will
%   consiste of the transformed images.

size_T = get_size_T(image_location);

default_options = struct(...
    'transformation_type', 'nonreflectivesimilarity', ...
    'times_to_align', 1:size_T, ...
    'transformation_param', [], ...
    'feature_indices', NaN, ...
    'library', [] ...
);
input_options = varargin2struct(varargin{:}); 
options = mergestruct(default_options, input_options);

if ~exist(target_location, 'dir')
    mkdir(target_location);
end


% create a referencing object for storage using the image from reference
% time.
ref_image = load_image(image_location, 't', t_ref);
S = size(ref_image);
refdata = struct();
refdata.global_YWorldLimits = [0.5 0.5+S(1)];
refdata.global_XWorldLimits = [0.5 0.5+S(2)];
R = imref2d(S, refdata.global_XWorldLimits, refdata.global_YWorldLimits);
save(fullfile(target_location, 'WorldLimits.mat'), '-struct', 'refdata');


features = load_features(image_location);

if ~isempty(options.library)
    
    ref_image = load_image(fullfile(options.library, 'red'), 't', 1);
    S = size(ref_image);
    refdata = struct();
    refdata.global_YWorldLimits = [0.5 0.5+S(1)];
    refdata.global_XWorldLimits = [0.5 0.5+S(2)];
    R = imref2d(S, refdata.global_XWorldLimits, ...
        refdata.global_YWorldLimits);
    save(fullfile(target_location, 'WorldLimits.mat'), ...
        '-struct', 'refdata');
    
    lib_features = load_features(fullfile(options.library, 'red'));
    
    f_ref = lib_features;
    t_ref = 1;
    
else
    
    f_ref = features;
    
end

if ~isnan(options.feature_indices)
    features = features(options.feature_indices);
    f_ref = f_ref(options.feature_indices);

end

tform_data = struct('R', R);
N_features = length(features);
for t = options.times_to_align
    
    moving_coords = zeros(0,2);
    fixed_coords = zeros(0,2);
    
    for i = 1:N_features
        if ~features{i}.is_bad_frame(t)
            
            moving_coords(end+1, :) = ...
                features{i}.coordinates(t, [2, 1]) ...
                + 0.5 * features{i}.size([2, 1]);
            fixed_coords(end+1, :) = ...
                f_ref{i}.coordinates(t_ref, [2, 1]) ...
                + 0.5 * f_ref{i}.size([2, 1]);
            
        end 
    end
        
    try
        if isempty(options.transformation_param)
            tform = fitgeotrans(moving_coords, fixed_coords, ...
                options.transformation_type);
        else
            tform = fitgeotrans(moving_coords, fixed_coords, ...
                options.transformation_type, ...
                options.transformation_param);
        end
    catch err
        if (strcmp(err.identifier,...
                'images:geotrans:requiredNonCollinearPoints'))
            
            disp(['Time ' num2str(t) ' has ' ...
                num2str(size(fixed_coords,1)) ' good features.' ...
                'Using previous transform instead.'])
            tform = last_tform;
            %tform = fitgeotrans(moving_coords, fixed_coords, 'affine');
            
        else
            rethrow(err)
        end
    end
    
    last_tform = tform;
    tform_data.tform = tform;
    save_transformation(tform_data, target_location, t);
    
end