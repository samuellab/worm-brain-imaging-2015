function out = sum_all(array)
% sums all the elements of an N-D array
out = sum(reshape(array,1,numel(array)));