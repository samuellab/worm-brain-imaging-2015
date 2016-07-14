function image = load_image(filename, varargin)
% image = load_image(filename)
%
%   Loads an ND image from a matfile or tif directory.  If 'filename' is a
%   matfile, the image should be stored under the variable 'images'. If
%   'filename' is a tif directory, the images should be stored as separate
%   files for each time index with the format T_03423.tif.
%
%   Matfiles should be >= v7.3.
%
% image = load_image(filename, 't', 34)
%
%   Loads the image (matfile.images) corresponding to time index 34.
%
% image = load_image(filename, 'z', 30)
%
%   Loads the image corresponding to z index 30.
%
% image = load_image(filename, 'c', 'green', 't', 30)
%
%   Loads the green image (matfile.green) corresponding to t index 30.

default_options = struct(...
    'z', [], ...
    't', [], ...
    'c', 'images', ...
    'rgb_output', false ...
);
global feature_annotator_data;
if isstruct(feature_annotator_data) && ...
   isfield(feature_annotator_data, 'color')
    default_options.c = feature_annotator_data.color;
end
input_options = varargin2struct(varargin{:}); 
options = mergestruct(default_options, input_options);

if isempty(filename)
    filename = feature_annotator_data.image_location;
end

if isa(filename, 'char') && exist(filename, 'dir') % TIF directory
    
    if isempty(options.z) && isempty(options.t)
        image = load_tiff_stack(filename);
    elseif isempty(options.z) && isnumeric(options.t)
        image = load_tiff_stack(filename, options.t);
    elseif isempty(options.t) && isnumeric(options.t)
        error('Z-slicing without T-slicing not allowed for tifs.');
    elseif isnumeric(options.t) && isnumeric(options.z)
        image = load_tiff_stack(filename, options.t);
        image = squeeze(image(:,:,options.z));
    end


else
    
    if isa(filename, 'matlab.io.MatFile')
        mfile = filename;
    elseif isa(filename, 'char')
        mfile = matfile(filename);
    end

    if isempty(options.z) && isempty(options.t)
        image = mfile.(options.c);
    elseif isempty(options.z) && isnumeric(options.t)
        image = squeeze(mfile.(options.c)(:,:,:,options.t));
    elseif isempty(options.t) && isnumeric(options.z)
        image = squeeze(mfile.(options.c)(:,:,options.z,:));
    else
        image = squeeze(mfile.(options.c)(:,:,options.z, options.t));
    end
    
end

if options.rgb_output
    if strcmp(options.c, 'red')
        image = image_from_rgb('r', image);
    else
        image = image_from_rgb('g', image); 
    end
end