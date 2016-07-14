function y = max_all(varargin)
% y = MAX_ALL(x)
% 
%   Returns the maximum element of an array.
%
% y = MAX_ALL(x1, x2, ...)
%
%   Returns the largest element present in any argument.

y = -Inf;
for i = 1:nargin
    x = varargin{i};
    y0 = max(reshape(x,1,numel(x)));
    y = max(y0, y);
end