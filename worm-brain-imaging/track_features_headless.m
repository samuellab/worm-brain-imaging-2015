function track_features_headless(features_to_track, image_location, varargin)
% track_features_headless(features_to_track, image_location, reference_features)
%
%   Takes in a cell array of features to track along with a cell array of
%   reference features. Each output feature is stored in its own matfile.
%   
% track_features_headless(features_to_track, reference_features, ...
%    'output_directory', 'my_location')
%
%   Stores the outputed features in the specified location.

default_options = struct(...
    'output_location', 'output_features', ...
    'N_ref', 4 ...
);

input_options = varargin2struct(varargin{:}); 
options = mergestruct(default_options, input_options);

parfor i = 1:length(features_to_track)
    
    F = features_to_track{i};
    filename = fullfile(options.output_location, [F.name '.mat']);
    
    try
    
        if ~exist(filename, 'file')

            local_opts = options;

            if isfield(options, 'all_reference_features') && ...
                    isfield(options, 'primary_reference_frame')

                t_ref = options.primary_reference_frame;

                [~, nearest_features] = get_nearby_reference_features(F, ...
                    options.all_reference_features, ...
                    t_ref, ...
                    options.N_ref);
                local_opts.reference_features = nearest_features;
                
                F.reference_features = {};
                for j = 1:length(nearest_features)
                    F.reference_features{end+1} = nearest_features{j}.name;
                end

            end

            F = register_feature(F, image_location, local_opts);


        end
        
    catch err
        
        F.init_error = err;
        warning(['Init Error in feature ' F.name]);
        
    end
    
    save_features(F, filename);

end