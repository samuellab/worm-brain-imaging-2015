function tform = get_centering_transformation(A)
% tform = GET_CENTERING_TRANSFORMATION(A)
%
%   Computes a transformation that will put an image A in a canonical 
%   positon based on rotationally-invariant image statistics. The 
%   transformation is always rigid. The result of this transformation
%   should center the image at the origin and orient it so that the most
%   variance is along the x-axis with a positive skewness in the
%   positive x-direction.

[c, theta] = get_image_directions(A);

R = [cos(theta), -sin(theta); sin(theta), cos(theta)];
b = -R*c';

tform = affine2d(...
    [R, [0;0];
     b(2), b(1), 1]);