function y = max_intensity(A, d)
% y = MAX_INTENSITY(A, d)
%
%   Returns the maxmium intensity projection of A along the 'd' dimension.
%
% z = MAX_INTENSITY(A, 3)
%
%   Maximum intensity projection in the z-direction.
%
% x = MAX_INTENSITY(A, 2)
%
%   Maximum intensity projection in the x-direction.
%
% y = MAX_INTENSITY(A, 1)
%
%   Maximum intensity projection in the y-direction.

y = squeeze(max(A, [], d));
