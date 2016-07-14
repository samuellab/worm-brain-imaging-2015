function align_directories_to_library(red_directory, green_directory, lib, varargin)
% align_directories_to_library(red_directory, green_directory, lib)
%
%   Creates a series of transformations in red_directory/rigidly_aligned
%   that should create images with the same shape as those in the specified
%   library.
%
%   You will have to run rigidly_align_time_series after this to actually
%   generate the images.

default_options = struct(...
    'output_directory', fullfile(red_directory, 'rigidly_aligned'), ...
    'times', [] ...
);

input_options = varargin2struct(varargin{:}); 
options = mergestruct(default_options, input_options);

mkdir(options.output_directory);

size_T = get_size_T(red_directory);

if isempty(options.times)
    times = 1:size_T;
else
    times = options.times;
end

green_lib = fullfile(lib, 'green');
red_lib = fullfile(lib, 'red');

load_red = @(t) max_intensity_z(load_image(red_directory, 't', t));
load_green = @(t) max_intensity_z(load_image(green_directory, 't', t));

% create a referencing object for storage using the image from reference
% time.
ref_image = load_image(red_lib, 't', 1);
S = size(ref_image);
refdata = struct();
refdata.global_YWorldLimits = [0.5 0.5+S(1)];
refdata.global_XWorldLimits = [0.5 0.5+S(2)];
R = imref2d(S, refdata.global_XWorldLimits, refdata.global_YWorldLimits);
save(fullfile(options.output_directory, 'WorldLimits.mat'), ...
    '-struct', 'refdata');

tform_data = struct('R', R);

library_match = nan(size_T, 1);
guess_tf = [];
for t = times

    [tf, best_lib] = align_to_library(load_green(t), load_red(t), ...
        lib, 'initial_tform', guess_tf, input_options);

    tform_data.tform = tf;
    save_transformation(tform_data, options.output_directory, t);
    
    library_match(t) = best_lib;
    
    guess_tf = tf;

end

save(fullfile(options.output_directory, 'library_match.mat'), ...
    'library_match');