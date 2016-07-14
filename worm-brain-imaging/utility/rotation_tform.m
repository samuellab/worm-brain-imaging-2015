function tform = rotation_tform(theta, center, displacement)
% tform = rotation_tform(theta, displacement)
%
%   Generates an affine2d transformation corresponding to a rigid rotation
%   of theta about the specified point.

if nargin < 3
    displacement = [0 0];
end
displacement = row(displacement);

if nargin < 2
    center = [0 0];
end
center = row(center);

R = [cos(theta), sin(theta);...
    -sin(theta), cos(theta)];

b = (eye(2) - R) * center';
b = b';

tform = affine2d([ R', zeros(2,1); ...
                   b+displacement, 1]);