function output = get_left_image(reference_data, vol)
% output = get_left_image(reference_data, vol)
%
%   returns the left image from a splitview camera.  reference_data should
%   consist of the following fields:
%       crop_size: size of the region to be cropped
%       left_tform: affine2d object describing how to transform the cropped
%           image
%       output_view: final view to be displayed
section = vol(1:reference_data.crop_size(1), ...
              1:reference_data.crop_size(2), ...
              :);
output = imwarp(section, reference_data.left_tform, ...
                'OutputView', reference_data.output_view);