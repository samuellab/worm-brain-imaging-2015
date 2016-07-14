function generate_transformed_images(target_directory, varargin)
% generate_transformed_images(target_directory)
%
%   Uses the transformations specified in target_directory to generate
%   transformed images from target directory's parent.

default_options = struct(...
    'times', [] ...
);

input_options = varargin2struct(varargin{:}); 
options = mergestruct(default_options, input_options);

[parent, ~, ~] = fileparts(target_directory);
size_T = get_size_T(parent);

if isempty(options.times)
    times = 1:size_T;
else
    times = options.times;
end

load_parent = @(t) load_image(parent, 't', t);
save_img = @(img, t) save_tiff_stack(img, target_directory, t);
get_tform = @(t) load(fullfile(...
    target_directory, sprintf('u_%05d.mat', t)));

worldlimits = load(fullfile(target_directory, 'WorldLimits.mat'));

for t = times

    S = get_tform(t);
    T = S.tform;
    r = S.R;

    r.XWorldLimits = worldlimits.global_XWorldLimits;
    r.YWorldLimits = worldlimits.global_YWorldLimits;

    V = load_parent(t);

    new_V = zeros([r.ImageSize, size(V,3)], class(V));

    for z=1:size(V,3)
        im = imwarp(V(:,:,z), T, 'OutputView', r);
        new_V(:,:,z) = im;
    end

    save_tiff_stack(new_V, target_directory, t);

end