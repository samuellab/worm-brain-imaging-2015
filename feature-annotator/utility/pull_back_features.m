function pull_back_features(source_directory, destination_directory)
% pull_back_features(start_directory, end_directory)
%
%   Takes all the features in a directory and pulls them back to the parent
%   directory using the transform specified by u.  u can be:
%
%       1. a Tx3 array of displacements corresponding to frame-by-frame
%       translations.
%
%       2. a series of files named 'u_00345.mat', etc. containing the
%       transforms to be used.
%
%   In all cases, u specifies the forward transform (the transform used to
%   get the images in the current directory from the parent directory).
%   This method inverts those u's to pull features upstream.


[parent, ~, ext] = fileparts(source_directory);

if strcmp(ext, '.mat')
    feature_file = source_directory;
    source_directory = parent;
else
    feature_file = fullfile(source_directory, 'features.mat');
end

[parent, ~, ~] = fileparts(source_directory);

if nargin == 1
    destination_directory = parent;
end

directory = source_directory;
while ~strcmp(directory, destination_directory)
    [parent, ~] = fileparts(directory);
    parent_features = {};
    
    % Save the features in the parent directory
    if exist(fullfile(parent, 'features.mat'))
        parent_features = load_features(parent);
        time_vector = datevec(now);
        time_suffix = '';
        for i = 1:5
            time_suffix = [time_suffix sprintf('%02d', time_vector(i))];
        end
        
        backup_filename = fullfile(parent, ...
            ['features_' time_suffix '.mat']);
        
        save_features(parent_features, backup_filename)
    end
    
    parent_features = {};
    
    if exist(fullfile(directory, 'u.mat'), 'file')
        
        F = load_features(feature_file);
        
        S = load(fullfile(directory, 'u.mat'));
        u = S.u; % old_T x 3, where old_T > new_T, unused frames are nans
        
        good_frames = ~isnan(u(:,1));
        bad_frames = isnan(u(:,1));
        u(bad_frames, :) = 0; % nans -> 0
        N_good = length(find(good_frames));
        
        for i = 1:length(F)
            if isfield(F{i}, 'coordinates')
                c_new = F{i}.coordinates; % new_T x 3
                
                c = zeros(size(u));
                c(good_frames, :) = c_new(1:N_good, :);
                
                F{i}.coordinates = c + u;
            end
            if isfield(F{i}, 'modified_coordinates')
                c_new = F{i}.modified_coordinates; % new_T x 3
                
                c = zeros(size(u));
                c(good_frames, :) = c_new(1:N_good, :);
                
                F{i}.modified_coordinates = c + u;
            end
            if isfield(F{i}, 'is_bad_frame')
                c_new = F{i}.is_bad_frame; % new_T x 1
                
                c = true(size(u, 1), 1);
                c(good_frames) = c_new(1:N_good, :);
                
                F{i}.is_bad_frame = c;
            end
            if isfield(F{i}, 'is_registered')
                c_new = F{i}.is_registered; % new_T x 1
                
                c = false(size(u, 1), 1);
                c(good_frames) = c_new(1:N_good, :);
                
                F{i}.is_registered = c;
            end
        end
        
        parent_features = [parent_features F];
        save_features(parent_features, parent);
        
    elseif exist(fullfile(directory, 'u_00001.mat'), 'file')
        
        size_u = get_size_u(directory);
        
        F = load_features(feature_file);
        S = load(fullfile(directory, 'WorldLimits'));
        offset = [S.global_YWorldLimits(1) - 0.5, ...
                  S.global_XWorldLimits(1) - 0.5, ...
                  0];
        
        for i = 1:size_u
            S = load(fullfile(directory, sprintf('u_%05d.mat', i)));
            tform_inv = S.tform.invert;
            
            for j = 1:length(F)
                
                center = F{j}.coordinates(i,:) + F{j}.ref_offset;
                center = center + offset;
                
                new_center = [center(2) center(1) 1]*tform_inv.T;
                new_center = [new_center(2) new_center(1) center(3)];
                
                F{j}.coordinates(i,:) = new_center - F{j}.ref_offset;
                
                if ~isnan(F{j}.modified_coordinates(i,1))
                    
                    center = F{j}.modified_coordinates(i,:) + ...
                        F{j}.ref_offset;
                    center = center + offset;
                
                    new_center = [center(2) center(1) 1]*tform_inv.T;
                    new_center = [new_center(2) new_center(1) center(3)];

                    F{j}.modified_coordinates(i,:) = ...
                        new_center - F{j}.ref_offset;
                    
                end
                
            end
            
        end
        
        parent_features = [parent_features, F];
        save_features(parent_features, parent);
        
    else
        
        F = load_features(feature_file);
        save_features(F, parent);
        
    end
    
    directory = parent;
end