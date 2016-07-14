function y = min_all(varargin)
% y = MIN_ALL(x)
% 
%   Returns the minimum element of an array.
%
% y = MIN_ALL(x1, x2, ...)
%
%   Returns the smallest element present in any argument.

y = Inf;
for i = 1:nargin
    x = varargin{i};
    y0 = min(reshape(x,1,numel(x)));
    y = min(y0, y);
end