function h = get_gaussian_filter(sigma, s)
% h = GET_GAUSSIAN_FILTER(sigma)
%
%   Create a guassian filter with the specified standard deviation. The
%   dimension of the filter is ndims(sigma).
%
% h = GET_GAUSSIAN_FILTER(sigma, s)
%
%   Optionally specify the array size of h. By default, s = 4*sigma.


if nargin < 2
    s = 4*sigma;
end

D = length(sigma);

if D == 1
    h = ones(s, 1);
else
    h = ones(s);
end

for i = 1:D
    idx{i} = ':';
end

for i = 1:D
    
    x = 1:s(i);
    mu = s(i)/2 + 0.5;
    
    h_1D = exp(-(x-mu).^2./(2*sigma(i)^2));
    
    for j = 1:s(i)
        idx{i} = j;
        
        h(idx{:}) = h(idx{:}) * h_1D(j);
        
    end
    
    idx{i} = ':';
end

h = h./sum_all(h);