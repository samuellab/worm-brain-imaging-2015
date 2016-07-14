function add_library_frames(target, library, varargin)
% add_library_frames(target, library)
%
%   Adds the library frames (red by default) to the specified directory,
%   placing them at the end of the time series.
%
% add_library_frames(target, library, 'color', 'green')
%
%   Add green frames to the time series instead.

default_options = struct(...
    'color', 'red', ...
    'backup', 'true' ...
);

input_options = varargin2struct(varargin{:}); 
options = mergestruct(default_options, input_options);

green_lib = fullfile(library, 'green');
red_lib = fullfile(library, 'red');

switch options.color
    case 'red'
        
        load_im = @(t) load_image(red_lib, 't', t);
        
    case 'green'
        
        load_im = @(t) load_image(green_lib, 't', t);
        
    otherwise
        
        error('Invalid color selection.');
        
end


size_T = get_size_T(target);

size_lib = get_size_T(red_lib);

for i = 1:size_lib

    im = load_im(i);
    save_tiff_stack(im, target, size_T + i);

end

lib_features = load_features(red_lib);
target_features = load_features(target);

target_features = merge_features(target_features, lib_features, ...
    size_T+1:size_T+size_lib);

save_features(target_features, target, options);