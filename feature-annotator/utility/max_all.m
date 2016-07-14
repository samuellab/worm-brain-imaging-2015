function out = max_all(array)
% returns the maximum element of an array
out = max(reshape(array,1,numel(array)));