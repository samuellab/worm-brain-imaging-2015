function depth = tree_node_depth(tree, node)
% depth = TREE_NODE_DEPTH(tree, node)
%
%   Returns the distance from a given node to the root of a tree.
%

parent = tree_parent(tree, node);

if isempty(parent)
    
    depth = 0;
    
else
    
    depth = 1 + tree_node_depth(tree, parent);
    
end