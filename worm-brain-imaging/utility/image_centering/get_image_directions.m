function [c, theta] = get_image_directions(A)
% [c, theta] = GET_IMAGE_DIRECTIONS(A)
%
%   Returns the two principal directions of an image, ordered by variance.
%   The direction of u is the direction of the first principal component,
%   chosen such that a rotation by theta will result in an image with a
%   positive skewness in the x-direction.

m00 = raw_moment(A, 0, 0);

c = get_image_centroid(A);

m20 = central_moment(A, 2, 0);
m11 = central_moment(A, 1, 1);
m02 = central_moment(A, 0, 2);

S = [m20/m00, m11/m00; m11/m00, m02/m00];

[V, D] = eig(S);

if D(1,1) < D(2,2)
    d(1) = D(2,2);
    d(2) = D(1,1);
    u = V(:,2);
    v = V(:,1);
else
    d(1) = D(1,1);
    d(2) = D(2,2);
    u = V(:,1);
    v = V(:,2);
end

theta = atan2(u(1), u(2));
rotated_image = imrotate(A, theta*180/pi);
skew = central_moment(rotated_image, 0, 3);

if skew < 0
    theta = -theta;
end

theta = mod(theta, 2*pi);
