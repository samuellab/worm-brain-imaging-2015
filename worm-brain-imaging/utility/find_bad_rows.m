function indices = find_bad_rows(array)
% indices = bad_rows(array)
%
%   Returns the indices corresponding to rows that are exclusively NaN in
%   an array.

indices = [];

for i = 1:size(array, 1)
    if all(isnan(array(i,:)))
        indices(end+1) = i;
    end
end