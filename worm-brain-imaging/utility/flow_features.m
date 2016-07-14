function flow_features(features, tif_directory, varargin)


global feature_annotator_data;

if nargin < 2 
    tif_directory = feature_annotator_data.tif_directory;
end

if nargin == 0
    features = feature_annotator_data.features;
end

if isnumeric(features) && ~isempty(features)
    features = feature_annotator_data.features(features);
elseif isempty(features)
    features = load_features(tif_directory);
end

input_options = varargin2struct(varargin{:});
default_options = struct(...
                    'output_directory', ...
                        fullfile(tif_directory, 'registered'), ...
                    'reference_time', 1, ...
                    'times_to_register', [], ... % empty means ALL
                    'deformations_directory', [] ...
                        );
                    
options = mergestruct(default_options, input_options);

size_T = length(dir(fullfile(tif_directory,'T_*')));
t_ref = options.reference_time;

if isempty(options.times_to_register)
    to_reg = [1:t_ref-1 t_ref+1:size_T];
else
    to_reg = options.times_to_register;
end

if ~exist(options.output_directory, 'dir')
    mkdir(options.output_directory);
end

copyfile(fullfile(tif_directory, sprintf('T_%05d.tif', t_ref)), ...
         fullfile(options.output_directory, sprintf('T_%05d.tif', t_ref)));

parfor t = to_reg
    
    v = load_tiff_stack(tif_directory, t);
    
    if ~isempty(options.deformations_directory)
        
        S = load(fullfile(options.deformations_directory, ...
                          sprintf('u%05d.mat',t)));
        u = S.u;
        
        v_reg = field_deform(v, u);
        
    else
        
        % reference displacements
        d = {};
        for i = 1:length(features)
            f = features{i};
            if ~f.is_bad_frame(t) && ~f.is_bad_frame(t_ref)
                d{end+1, 1} = f.coordinates(t,:) + f.ref_offset;
                d{end  , 2} = f.coordinates(t_ref,:) - f.coordinates(t,:);
            end
        end
        
        [v_reg, u] = field_deform(v, d);
        
        save_wrap_u(fullfile(options.output_directory, ...
                      sprintf('u%05d.mat',t))...
                    , u);
    end
    
    save_tiff_stack(v_reg, options.output_directory, t);
    
end
