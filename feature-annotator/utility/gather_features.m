function gather_features(top_level_directory, derived_directory, varargin)
% gather_features(main_directory, derived_directory)
%
% Takes a features.json file in derived_directory and merges the features 
% into the features file in the main directory.  Coordinates are modified
% to undo any transformation used to generate derived_directory.
%
% Allowable formats for target_directory:
%   - decimated_YYXXTT [2D image, decimated]
%   - decimated_YYXXZZTT [3D image, decimated]
%
%   NOT IMPLEMENTED YET:
%   - cropped_featurename [rectangular feature cropped out] 

derived_features = load_features(fullfile(...
                                 derived_directory, 'features.json'));
features = load_features(top_level_directory);

size_T = length(dir(fullfile(top_level_directory,'T_*')));

transformation = get_transformation(derived_directory);

if strcmp(transformation.type, 'decimated')
    
    N = [transformation.N transformation.N_t];
    t_extra = mod(size_T, transformation.N_t);
    
    for i = 1:length(derived_features)
        
        % index of derived feature name in original feature array
        if isempty(features)
            idx = 1;
        else
            idx = find(strcmp(derived_features{i}.name, ...
                              cellfun(@(x)x.name, features, ...
                                  'UniformOutput', false)),...
                       1);
            if isempty(idx)
                idx = length(features)+1;
            end
        end
        
        
        features(idx) = {scale_feature(derived_features{i}, N, ...
            'additional_time_points', t_extra)};
        

    end
end

save_features(features, top_level_directory);

end

function t = get_transformation(directory_string)
    [~, name] = fileparts(directory_string);
    parts = strsplit(name, '_');
    
    t = struct;
    t.type = parts{1};
    
    if strcmp(t.type, 'decimated')
        N = sscanf(parts{2}, '%02d');
        t.N = row(N(1:end-1));
        t.N_t = N(end);
    elseif strcmp(t.type, 'cropped')
        t.feature_name = strjoin(parts(2:end), '_');
    end
end