function out = mean_all(array)
% returns the mean of elements in an array
out = mean(reshape(array,1,numel(array)));