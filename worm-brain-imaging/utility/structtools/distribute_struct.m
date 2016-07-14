function y = distribute_struct(s, y)
% y = DISTRIBUTE_STRUCT(s, y)
%
%   Merge a struct s with each element of a cell array of structs (y).
%   When s and y{i} share a field, the data in y{i} will have priority.

for i = 1:length(y)

    y{i} = mergestruct(s, y{i});
    
end