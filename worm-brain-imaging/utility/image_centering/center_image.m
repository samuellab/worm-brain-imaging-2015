function [centered_image, tform] = center_image(A, ref)
% [centered_image, tform] = CENTER_IMAGE(A)
%
%   Takes an image and puts in a position that is invariant to rotations or
%   tanslations in the input image A.
%
% [centered_image, tform] = CENTER_IMAGE(A, ref)
%
%   You can optionally supply the extent of the final image's bounds in x
%   and y. The coordinate system for these values has its center at the
%   centroid of the original image
%
%  See also GET_OUTPUT_VIEW

if nargin < 2
    S = size(A);
    ref = imref2d(S, [-0.5, 0.5]*S(2), [-0.5, 0.5]*S(1));
end

tform = get_centering_transformation(A);

centered_image = imwarp(A, tform, 'OutputView', ref);