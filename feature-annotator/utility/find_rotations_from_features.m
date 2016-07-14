function find_tform_from_features(image_location, t_ref, varargin)
% find_rotations_from_features(image_location, reference_time)
%
%   Uses the x and y coordinates of the feature locations to determine a
%   transformation that maps each image onto the image at reference_time.


default_options = struct(...
                        'transformation_type', 'affine', ...
                        'times_to_align', 'all' ...
                        );
input_options = varargin2struct(varargin{:}); 
options = mergestruct(default_options, input_options);

features = load_features(image_location);

size_T = get_size_T(image_location);
N_features = length(features);

for t = 1:size_T
    
    moving_coords = zeros(0,2);
    fixed_coords = zeros(0,2);
    
    for i = 1:N_features
        
        if ~features{i}.is_bad_frame(t)
            
            moving_coords(end+1, :) = ...
                features{i}.coordinates(t, [2, 1]) ...
                + 0.5 * features{i}.size;
            fixed_coords(end+1, :) = ...
                features{i}.coordinates(t_ref, [2, 1]) ...
                + 0.5 * features{i}.size;
            
        end
        
        tform = fitgeotrans(moving_coords, fixed_coords, options);
        
    end
    
end