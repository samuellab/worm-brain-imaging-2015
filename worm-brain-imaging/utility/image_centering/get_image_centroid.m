function c = get_image_centroid(A)
% u = GET_IMAGE_CENTROID(A)
%
%   Returns the centroid of an image as a (y, x) pair.

m00 = raw_moment(A, 0, 0);

m10 = raw_moment(A, 1, 0);
m01 = raw_moment(A, 0, 1);

c = [m10/m00, m01/m00];