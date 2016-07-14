function feature = register_local_centroid(parent, varargin)
% feature = REGISTER_LOCAL_CENTROID(parent, options)
%
%   Registers a PointFeature (parent) in an image with the specified 
%   optiosn. This method attempts to find the centroid of an image near a
%   given feature.
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
%     'radius': This defines the width of a gaussian mask applied to the
%       target image to create an elastic penalty (centered around the
%       initial guess). If the parent feature is a BoxFeature and radius
%       is not specified, it will default to parent.Size. This should be
%       an array with N-1 elements.
%
%     'cutoff': (default 'elastic') If this is set to 'sharp', there is no
%       elastic penalty. The brightest feature in the search radius will be
%       returned.
%
%     'steps': This is the number of hill-climbing iterations. It is only
%       relevant when the radius is set to a small enough size that a
%       global maximum won't be found in a single iteration.
%
%     'keep_parent': (default true) This determines whether the parent
%       feature is kept in feature.Creator. If this is false,
%       feature.Creator will just contain parent.ID.

default_options = struct(...
    'image', parent.Image, ...
    't', parent.Time, ...
    'guess', parent.get_center(), ...
    'radius', NaN, ...
    'cutoff', 'elastic', ... % elastic or sharp
    'steps', 1, ...
    'keep_parent', true ...
);

input_options = varargin2struct(varargin{:}); 
options = mergestruct(default_options, input_options);

if isa(parent, 'BoxFeature') && isnan(options.radius)
    options.radius = parent.Size;
end

switch options.cutoff
    case 'elastic'
        box_size = 4*options.radius;
        h = get_gaussian_filter(options.radius, box_size);
    case 'sharp'
        box_size = 2*options.radius;
        h = ones(box_size);
end

% Copy the parent feature, but with a new context.
feature = clone_feature(parent, ...
    'Image', options.image, ...
    'Time', options.t, ...
    'Coordinates', options.guess);

for step = 1:options.steps

    old_center = feature.get_center();

    A = feature.get_image(box_size);

    A = A .* h;

    local_centroid = centroid(A);

    box_center = center_from_size(box_size);
    
    new_center = old_center + (local_centroid - box_center);

    feature = feature.clone_feature('Coordinates', new_center);

end

if option.keep_parent 
    parent_data = parent;
else
    parent_data = parent.ID;
end

% Create a version of the feature with a cleaner history.
creator = struct(...
    'Method', 'register_local_centroid', ...
    'Parent', parent_data, ...
    'Options', input_options, ...
    'Fit', NaN ...
);

feature = clone_feature(parent, ...
    'Coordinates', feature.get_center(), ...
    'Time', options.t, ...
    'Image', options.image, ...
    'Creator', creator ...
);