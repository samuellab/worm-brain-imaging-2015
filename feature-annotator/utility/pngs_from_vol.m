function pngs_from_vol(vol, image_directory, varargin)
% pngs_from_vol(vol, image_directory)
%
%   Creates a series of images in image_directory using slices of greyscale
%   vol and rendering them in green.

default_options = struct(...
                        'color', 'gray', ...
                        'intensity_scale', 1 ...
                        );

input_options = varargin2struct(varargin{:}); 
options = mergestruct(default_options, input_options);

colormap.red = [linspace(0,1,256)', zeros(256,1), zeros(256,1)];
colormap.green = [zeros(256,1), linspace(0,1,256)', zeros(256,1)];
colormap.blue = [zeros(256,1), zeros(256,1), linspace(0,1,256)'];
colormap.gray = gray;

for i = 1:size(vol, 3)
    figure(1);
    im = vol(:,:,i);
    
    im = double(im);
    im = im / max_all(im);
    im = im * 255 * options.intensity_scale;
    im = uint8(im);
    
    filename = fullfile(image_directory, sprintf('slice_%02d.png', i));
    imwrite(im, colormap.(options.color), filename);
end