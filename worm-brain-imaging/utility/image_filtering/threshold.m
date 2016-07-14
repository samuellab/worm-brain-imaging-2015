function A = threshold(A, bounds)
% A = THRESHOLD(A, bounds)
%
%   Replace values in A below bounds(1) with bounds(1), and replace values
%   in A above bounds(2) with bounds(2).

if length(bounds) < 2
    bounds(2) = bounds(1);
    bounds(1) = 0;
end

A(A<bounds(1)) = bounds(1);
A(A>bounds(2)) = bounds(2);