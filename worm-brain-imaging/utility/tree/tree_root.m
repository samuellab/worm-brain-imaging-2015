function root = tree_root(tree, start)

if nargin == 1
    start = 1;
end

parent = tree_parent(tree, start);
if isempty(parent)
    root = start;
else
    root = tree_root(tree, parent);
end