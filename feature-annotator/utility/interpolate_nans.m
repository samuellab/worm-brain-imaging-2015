function x = interpolate_nans(x, method)
%   y = interpolate_nans(x, method)
%
%       Replaces the nan values in x with an interpolated estimate

if nargin == 1
    method = 'nearest';
end
t = 1:length(x);
nans = isnan(x);
x(nans) = interp1(t(~nans), x(~nans), t(nans), method, 'extrap');