function maxima = find_local_maxima(x)
% maxima = find_local_maxima(x)
%
% Returns a MxN array containing coordinates of the M local maxima found in
% the N-dimensional array x.
%
% An element is a considered a local max if it is the largest of the 3^N
% elements in a cube centered on it.


N = ndims1(x);
S = size(x);

% make a slightly larger array to allow maxima at boundaries
x_large = zeros(size(x)+2, class(x));

for i = 1:N
    idx{i} = 2:(1+S(i));
end

x_large(idx{:}) = x;

maxima = zeros(0,N);

for i = 1:numel(x)
    xi = cell(1,N);
    [xi{:}] = ind2sub(S,i);
    
    elmt = x(xi{:});
    
    % indices for cube around xi in x_large
    for j = 1:N
        ci{j} = xi{j} : (xi{j}+2);
    end
    
    c = x_large(ci{:});
    
    mx = max_all(c);
    
    if elmt == mx   &&   length(find(c==mx)) == 1
        maxima(end+1,:) = cell2mat(xi);
    end
end

