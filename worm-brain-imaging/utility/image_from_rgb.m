function im = image_from_rgb(varargin)
% im = image_from_rgb('r', red_im, 'g', green_im, 'b', blue_im)
%
%   Creates an image given equal-sized arrays corresponding to the red,
%   green and blue channels. Omitted channels are set zero.

ref_image = varargin{2};

default_options = struct(...
    'r', zeros(size(ref_image), class(ref_image)), ...
    'g', zeros(size(ref_image), class(ref_image)), ...
    'b', zeros(size(ref_image), class(ref_image)) ...
);
input_options = varargin2struct(varargin{:}); 
options = mergestruct(default_options, input_options);

im = cat(3, options.r, options.g, options.b);