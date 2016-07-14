function out = std_all(array)
% returns the mean of elements in an array
out = std(reshape(array,1,numel(array)));