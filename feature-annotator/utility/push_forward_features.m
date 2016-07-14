function push_forward_features(source_directory, destination_directory, F)
% push_forward_features(source_directory, destination_directory)
%
%   Takes the specified features and pushes them downstream to destination
%   directory. Each child folder should have a transform specified by u.  
%   u can be:
%
%       1. a Tx3 array of displacements corresponding to frame-by-frame
%       translations.
%
%       2. a series of files named 'u00345.mat', etc. containing the
%       transforms to be used.
%
%   In all cases, u specifies the forward transform (the transform used to
%   get the images in the child directory from the parent directory).
%
%   If features is not specified, all features in the parent directory are
%   pushed forward.

if nargin < 3
    F = load_features(source_directory);
end

if isnumeric(F)
    all_F = load_features(source_directory);
    F = all_F(F);
end

child_features = {};

% backup featurs in child directory
if exist(fullfile(destination_directory, 'features.json')) || ...
        exist(fullfile(destination_directory, 'features.mat'))

    child_features = load_features(destination_directory);

    time_vector = datevec(now);
    time_suffix = '';
    for i = 1:5
        time_suffix = [time_suffix sprintf('%02d', time_vector(i))];
    end

    backup_filename = fullfile(destination_directory, ...
        ['features_' time_suffix '.mat']);

    save_features(child_features, backup_filename)
end

if exist(fullfile(destination_directory, 'u.mat'), 'file')

    S = load(fullfile(destination_directory, 'u.mat'));
    u = S.u;

    good_frames = ~isnan(u(:,1));
    u = u(good_frames, :);

    for i = 1:length(F)
        
        if isfield(F{i}, 'coordinates')
            
            c = F{i}.coordinates(good_frames, :); % new_T x 3
            F{i}.coordinates = c - u;
            
        end
        
        if isfield(F{i}, 'modified_coordinates')
            
            c = F{i}.modified_coordinates(good_frames, :); % new_T x 3
            F{i}.modified_coordinates = c - u;
            
        end
        
        if isfield(F{i}, 'is_bad_frame')

            F{i}.is_bad_frame = F{i}.is_bad_frame(good_frames);

        end
        
        if isfield(F{i}, 'is_registered')

            F{i}.is_registered = F{i}.is_registered(good_frames);

        end

    end

elseif exist(fullfile(destination_directory, 'u_00001.mat'), 'file')
    
    if exist(fullfile(destination_directory, 'WorldLimits.mat'))
        
        S = load(fullfile(destination_directory, 'WorldLimits.mat'));
        offset = [S.global_YWorldLimits(1) - 0.5, ...
                  S.global_XWorldLimits(1) - 0.5, ...
                  0];
              
    else
        
        offset = [0, 0, 0];
        
    end
    size_u = get_size_u(destination_directory);
    
    for i = 1:size_u
        
        S = load(fullfile(destination_directory, sprintf('u_%05d.mat', i)));
        tform = S.tform;
        
        for j = 1:length(F)
            
            center = F{j}.coordinates(i,:) + F{j}.ref_offset;
            
            [new_x, new_y] = transformPointsForward(...
                    tform, center(2), center(1));
                
            new_center = [new_y new_x center(3)];
            
            new_center = new_center - offset;
            
            F{j}.coordinates(i,:) = new_center - F{j}.ref_offset;
            
            if ~isnan(F{j}.modified_coordinates(i,1))
                
                center = F{j}.modified_coordinates(i,:) + F{j}.ref_offset;
                
                [new_x, new_y] = transformPointsForward(...
                    tform, center(2), center(1));
                
                new_center = [new_y new_x center(3)];

                new_center = new_center - offset;
                
                F{j}.modified_coordinates(i,:) = new_center - ...
                    F{j}.ref_offset;
                
            end
            
        end
        
    end
    
end

child_features = [child_features, F];

save_features(child_features, destination_directory);