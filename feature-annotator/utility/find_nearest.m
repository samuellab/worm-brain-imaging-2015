function [idx, vals] = find_nearest(source, targets, N, varargin)
% idx = find_nearest(source, targets, N)
%
%   Returns the indices of the nearest N columns in targets for a given
%   source coordinate (column vector).
%
% [idx, vals] = find_nearest(source, targets, N)
%
%   Include the values.

default_options = struct(...
                    'scales', [1, 1, 1], ...
                    'distance', 'cityblock' ...
                    );

input_options = varargin2struct(varargin{:}); 
options = mergestruct(default_options, input_options);

N_tot = size(targets,2) + 1;
all_pts = [column(source), targets];

all_pts = diag(options.scales) * all_pts;

all_separations = squareform(pdist(all_pts', options.distance)) ...
    + diag(Inf(1,N_tot));

separations = all_separations(1,2:end);

[vals, I] = sort(separations);

N_to_return = min(length(separations), N);

idx = I(1:N_to_return);
vals = vals(1:N_to_return);