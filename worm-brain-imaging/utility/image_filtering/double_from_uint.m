function y = double_from_uint(x, LUT)
% y = DOUBLE_FROM_UINT(x, LUT)
%
%   Convert uint image x to a floating point image y (in [0, 1]). LUT can
%   be used to specify bounds.

if nargin < 2
    LUT = [0, intmax(class(x))];
end

x = threshold(x, LUT);

y = interp1(double(LUT), [0, 1], double(x));