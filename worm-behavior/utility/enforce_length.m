function [new_x, new_y] = enforce_length(x, y, L)
% [x, y] = enforce_length(x, y, L)
%
%   Takes in x(t) and y(t) and modifies them to be uniformly spaced
%   (arc-length parametrized) with a total length of L. Distances are
%   adjusted, but angles between subsequent segments are preserved.

N = length(x);

dx = diff(x);
dy = diff(y);

dL = L / (N-1);

new_x(1) = x(1);
new_y(1) = y(1);

for i = 1:N-1
    
    % Determine the old distance
    ds = norm([dx(i), dy(i)]);
    
    new_x(i+1) = new_x(i) + dx(i) * dL/ds;
    new_y(i+1) = new_y(i) + dy(i) * dL/ds;
    
end