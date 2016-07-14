function feature = register_image(parent, varargin)
% feature = REGISTER_IMAGE(parent, options)
%
%   Registers a PointFeature (parent) in an image with the specified 
%   options. This method uses image registration with maximum intensity
%   projections of a local volume around the feature's center.
%
%   Options for this process:
%
%     'image': A ND array with the first N-1 dimensions matching the shape
%       of parent.Image. To efficiently store features, this must be a
%       reference object (e.g. LambdaArray, CachedArray, TIFFArray, etc.).
%       This defaults to parent.Image.
%
%     't': The slice of the above image to use for registration. This
%       defaults to parent.Time.
%
%     'guess': An initial guess (defaults to the coordinates of parent).
%
%     'size': This defines the size of the box to use to obtain images for
%       registration (centered around the initial guess). It should have 
%       N-1 elements. If size is not specified and parent is a BoxFeature
%       object, the default value will be 4*parent.Size.
%
%     'keep_parent': (default true) This determines whether the parent
%       feature is kept in feature.Creator. If this is false,
%       feature.Creator will just contain parent.ID.

default_options = struct(...
    'image', parent.Image, ...
    't', parent.Time, ...
    'guess', parent.get_center(), ...
    'size', NaN, ...
    'keep_parent', true ...
);

input_options = varargin2struct(varargin{:}); 
options = mergestruct(default_options, input_options);

if isa(parent, 'BoxFeature') && isnan(options.size)
    options.size = 4 * parent.Size;
end

[optimizer, metric] = imregconfig('monomodal');
get_tform = @(src, target) ...
    imregtform(src, target, 'rigid', optimizer, metric);

box_size = options.size;

% Copy the parent feature, but with a new context.
feature = clone_feature(parent, ...
    'Image', options.image, ...
    'Time', options.t, ...
    'Coordinates', options.guess);

prev_vol = parent.get_image();
curr_vol = feature.get_image();

px = max_intensity_x(prev_vol);
py = max_intensity_y(prev_vol);
pz = max_intensity_z(prev_vol);

cx = max_intensity_x(curr_vol);
cy = max_intensity_y(curr_vol);
cz = max_intensity_z(curr_vol);

tx = get_tform(px, cx);
ty = get_tform(py, cy);
tz = get_tform(pz, cz);

nz = imwarp(pz, tz, 'OutputView', imref2d(size(cz)));
image_registration_score = get_image_overlap(nz, cz);

box_center = center_from_size(box_size);

[new_x(1), new_y(1)] = ...
    transformPointsForward(tz, box_center(2), box_center(1));
[new_z(1), new_y(2)] = ...
    transformPointsForward(tx, box_center(3), box_center(1));
[new_x(2), new_z(2)] = ...
    transformPointsForward(ty, box_center(2), box_center(3));

new_x = mean(new_x);
new_y = mean(new_y);
new_z = mean(new_z);

offset = [new_y new_x new_z] - box_center;

new_center = feature.get_center() + offset;

if option.keep_parent 
    parent_data = parent;
else
    parent_data = parent.ID;
end

% Create a version of the feature with a cleaner history.
creator = struct(...
    'Method', 'register_image', ...
    'Parent', parent_data, ...
    'Options', input_options, ...
    'Fit', image_registration_score ...
);

feature = clone_feature(parent, ...
    'Coordinates', new_center, ...
    'Time', options.t, ...
    'Image', options.image, ...
    'Creator', creator ...
);