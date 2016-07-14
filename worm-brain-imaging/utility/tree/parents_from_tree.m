function parents = parents_from_tree(t)
% parents = PARENTS_FROM_TREE(t)
%
%   Returns a list of parents for all nodes in a tree represented as an
%   adjacency matrix. The parent of the root node is zero.

[i, j] = find(t);

N = length(i) + 1;
parents = zeros(N, 1);

for k = 1:length(i)
    
    parents(j(k)) = i(k);
    
end