function depth = tree_depth(tree, root)


children = tree_children(tree, root);
N_c = length(children);

if N_c == 0
    depth = 0;
else
    child_depths = zeros(1, N_c);
    for i = 1:N_c
        child_depths(i) = tree_depth(tree, children(i));
    end
    depth = 1 + max_all(child_depths);
end
    
