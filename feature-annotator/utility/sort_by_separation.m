function y = sort_by_separation(x, varargin)
% y = sort_by_separation(x)
%
%  Rearranges the rows of x, placing the row with the greatest distance to
%  a nearest neighbor at the top.
%
% y = sort_by_separation(x, 'metric', [1 1 3])
%
%  Calculates the distance between p1 and p2 as p1*diag([1, 1, 3])*p2'.
%
% y = sort_by_separation(x, 'metric', 'cityblock')
%
%  Uses the City Block distance.  See the help for pdist for additional
%  options.
%
% y = sort_by_separation(x, 'metric', @f)
%
%   Use the function f to calculate distance.  See the help for pdist for
%   additional details.

% Dimension of each vector
D = size(x, 2);

default_options = struct(...
                    'metric', 'euclidean');
                
input_options = varargin2struct(varargin{:}); 
options = mergestruct(default_options, input_options);

if isnumeric(options.metric)
    options.metric = @(p1, p2) p1*diag(options.metric)*p2';
end

pairwise_distances = squareform(pdist(x, options.metric));

min_distances = min(pairwise_distances + diag(Inf(1, size(x,1))));

x_with_distances = [x, column(min_distances)];

y = flipud(sortrows(x_with_distances, D+1));

y = y(:, 1:D);