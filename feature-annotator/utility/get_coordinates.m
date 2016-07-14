function output = get_coordinates(array)
% if array is n-dimensional with m 'true' values, output is an 
% m x n array containing the indices of all the 'true's

out = cell(1,ndims(array));
[out{:}] = ind2sub(size(array), find(array));
output = cell2mat(out);               
               
end