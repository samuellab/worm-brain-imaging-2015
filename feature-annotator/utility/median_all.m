function out = median_all(array)
% returns the median of elements in an array
out = median(reshape(array,1,numel(array)));