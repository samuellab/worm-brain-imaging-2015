function out = ndims1(in)
% Returns the number of dimensions of an array, including 1 if the array is
% a row or column, and 0 if it is a scalar.
out = numel(find(size(in)>1));