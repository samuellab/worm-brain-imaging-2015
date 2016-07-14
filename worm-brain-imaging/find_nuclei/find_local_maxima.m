function [maxima, vals] = find_local_maxima(x, K, varargin)
% maxima = local_maxima(x, K)
%
%   Returns a MxN array containing coordinates of the M local maxima found 
%   in the N-dimensional array x.
%
%   An element is a considered a local max if it is the largest of the K^N
%   elements in a cube centered on it.  K should be odd, and it defaults to
%   3.
%
% maxima = local_maxima(x, [K1, K2 ...])
%
%   Similar to local_maxima(x, K), but uses different values of K for
%   the different dimensions.  Typially, K will have the form [5, 5, 3],
%   corresponding to different sampling for XY versus Z.
%
% maxima = local_maxima(x, K, 'minimum_separation', [20, 20, 10])
%
%   This will only accept maxima that are at least 20 away (in X and Y)
%   from a brighter maximum, and 10 away in Z.
%
% maxima = local_maxima(x, K, 'max', 12)
%
%   Only return the 12 brightest maxima (possibly avoiding those that are
%   too close to previously found maxima).
%
% [maxima, vals] = local_maxima(x)
%
%   Optionally returns the values of x at the found maxima.

default_options = struct(...
    'minimum_separation', 0, ...
    'max', Inf ...
);

input_options = varargin2struct(varargin{:}); 
options = mergestruct(default_options, input_options);

x = double(x);

N = ndims1(x);
S = size(x);

if nargin == 1
    K = 3;
end

if length(K) == 1
    K = K * ones(1, N);
end

% Make sure K is odd
K = ceil(K/2)*2-1;

% make a slightly larger array to allow maxima at boundaries
x_large = zeros(size(x)+(K-1), class(x));

for i = 1:N
    idx{i} = (K(i)+1)/2:((K(i)+1)/2-1+S(i));
end

x_large(idx{:}) = x;

% maxima(j, :) = [column, row, slice, x(column, row, slice)]
maxima = zeros(0,N+1);

for i = 1:numel(x)
    xi = cell(1,N);
    [xi{:}] = ind2sub(S,i);
    
    elmt = x(xi{:});
    
    % indices for cube around xi in x_large
    for j = 1:N
        ci{j} = xi{j} : (xi{j}+(K(j)+1)/2);
    end
    
    c = x_large(ci{:});

    mx = max_all(c);

    
    if elmt == mx   &&   length(find(c==mx)) == 1
        maxima(end+1,:) = [cell2mat(xi) x(xi{:})];
    end
end

% order maxima by size (higest maxima at the top)
maxima = flipud(sortrows(maxima, N+1));

% Only accept maxima that are sufficiently separated
separated_maxima = zeros(0, N+1);
if all(options.minimum_separation > 0)
    if length(options.minimum_separation) == 1
        options.minimum_separation = options.minimum_separation ...
                                     * ones(1, N);
    end

    for i = 1:size(maxima, 1)
        v1 = maxima(i, 1:end-1);
        accept_v1 = true;

        for j = 1:size(separated_maxima, 1)
            v2 = separated_maxima(j, 1:end-1);
            if all(abs(v2-v1) < options.minimum_separation)
                accept_v1 = false;
                break;
            end
        end

        if accept_v1
            separated_maxima(end+1, :) = maxima(i, :);
        end
    end
    
    maxima = separated_maxima;

end


% Limit the number of returned maxima
if options.max < Inf
    max_returned = min(size(maxima, 1), options.max);
    maxima = maxima(1:max_returned, :);
end

% The last column has the values at the maxima
if nargout == 2
    vals = maxima(:, end);
end

maxima = maxima(:, 1:end-1);