function register_time_series(tif_directory, varargin)
% attempts to deform images to fit a template (currently the first volume)

input_options = varargin2struct(varargin{:}); 

%
% DEFAULT PARAMETERS 
% todo: make compatible with 2D
%

default_options = struct( ...
    'output_directory',fullfile(tif_directory, '../', 'registered'), ...
    'start_time', 1, ...
    'end_time', length(dir(fullfile(tif_directory,'T_*'))) ...
    );

options = mergestruct(default_options, input_options);

options.output_directory = fullfile(tif_directory, '../', ...
    sprintf('registered_T%05d_to_T%05d', ...
            options.start_time, options.end_time));

size_T = length(dir(fullfile(tif_directory,'T_*')));

% use the first image as a template for all others
v1 = double(load_tiff_stack(...
                  fullfile(tif_directory, sprintf('T_%05d.tif', ...
                  options.start_time))...
                ));            
save_tiff_stack(uint16(v1), ...
             fullfile(options.output_directory, sprintf('T_%05d.tif',1)));
            
for t = 2 : (options.end_time - options.start_time + 1)
    v2 = double(load_tiff_stack(...
                  fullfile(tif_directory, sprintf('T_%05d.tif', ...
                  t + options.start_time - 1))...
                ));
            
    v2_registered = register_pair(v1, v2, options);
    save_tiff_stack(uint16(v2_registered), ...
              fullfile(options.output_directory, sprintf('T_%05d.tif',t)));
end