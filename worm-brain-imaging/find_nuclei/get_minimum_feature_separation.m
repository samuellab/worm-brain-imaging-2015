function sep = get_minimum_feature_separation(features, times, metric)
% sep = GET_MINIMUM_FEATURE_SEPARATION(features, times, metric)
%
%   Returns the minimum distance between feature centers found in the
%   given image location and feature set. Specify a metric (e.g. [1, 1, 3])
%   if the pixels are non-cubic in physical space.

sep = Inf;

for i = 1:length(features)
    
    x = get_feature_center(features{i}, times);
    
    for j = 1:length(times)
        
        locations{j}(i,:) = x(j,:).*metric;
        
    end 
    
end

for i = 1:length(times)
    
    z = squareform(pdist(locations{i}));
    z = z + diag(Inf(1, size(z,1)));
    pause
    m = min_all(z);
    
    if m < sep
        
        sep = m;
        
    end
    
end