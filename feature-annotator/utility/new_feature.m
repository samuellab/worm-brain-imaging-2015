function feature = new_feature(name, size_T, fsize, varargin)
% feature = new_feature(name, size_T, size)
%
%   Creates a new feature with the specified parameters.

default_options = struct(...
    'ref_offset', fsize/2, ...
    'coordinates', zeros(size_T, 3), ...
    'modified_coordinates', NaN(size_T, 3), ...
    'is_good_frame', true(size_T, 1), ...
    'is_registered', false(size_T,1) ...
);

input_options = varargin2struct(varargin{:}); 
options = mergestruct(default_options, input_options);

if size(options.coordinates, 1) == 1
    options.coordinates = repmat(options.coordinates(1,:), [size_T, 1]);
elseif size(options.coordinates, 1) ~= size_T
    error('size(coordinates, 1) incorrect.');
end

if size(options.modified_coordinates, 1) ~= size_T
    error('size(modified_coordinates, 1) incorrect.');
end

if length(options.is_good_frame) == 1
    options.is_good_frame = repmat(options.is_good_frame, [size_T, 1]);
elseif length(options.is_good_frame) ~= size_T
    error('length(is_good_frame) is incorrect');
end

if length(options.is_registered) == 1
    options.is_registered = repmat(options.is_registered, [size_T, 1]);
elseif length(options.is_registered) ~= size_T
    error('length(is_registered) is incorrect');
end

feature = struct(...
    'name', name, ...
    'size', fsize, ...
    'ref_offset', options.ref_offset, ...
    'coordinates', options.coordinates, ...
    'modified_coordinates', options.modified_coordinates, ...
    'is_good_frame', options.is_good_frame, ...
    'is_registered', options.is_registered ...
);