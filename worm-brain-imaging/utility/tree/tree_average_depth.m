function [avg_depth, depths] = tree_average_depth(tree, root)
% avg_depth = tree_average_depth(tree)
%
%   Returns the average depth of nodes in a given tree.

if nargin == 1
    
    root = tree_root(tree);
    
end

order = graphtraverse(tree, root, 'Method', 'BFS');
depths = zeros(1, size(tree,2));

for i = order(2:end)

    parent = tree_parent(tree, i);
    depths(i) = depths(parent) + 1;
    
end

avg_depth = mean(depths);