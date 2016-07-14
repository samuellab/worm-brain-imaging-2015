function tifs_from_matfile(mfile, reference_data, varargin)
% max_intensity_movie_from_matfile(mfile, reference_data)
%
%   Creates a max-intensity projection movie from the camera data in the
%   given matfile.  It's assumed that the left half of reference_data 
%   consists of red data and the right half consists of green data.

if ~isa(mfile, 'matlab.io.MatFile')
    mfile = matfile(mat_filename);
end

if isa(reference_data, 'char')
    if exist(reference_data, 'file')
        reference_data = load(reference_data);
    end
end

default_options = struct(...
                    'load_fn', @zyla_vol, ...
                    'filter', @(x) imfilter(x, fspecial('gaussian', 3, 3)) ...
                    );
input_options = varargin2struct(varargin{:}); 
options = mergestruct(default_options, input_options);

load_t = @(t) options.load(mfile.images(:,:,:,t));

image_size = size(mfile, 'images');
vol = load_t(1);
sample_red = get_left_image(reference_data, vol);
sample_green = get_right_image(reference_data, vol);

image_size(1:3) = size(sample_green);

