function [order, tree, parents] = frame_order_from_distances(D, varargin)
% [order, tree, parents] = FRAME_ORDER_FROM_DISTANCES(D)
%
%   Determines a global order based on pairwise distances in sparse matrix
%   D.
%
% [order, tree, parents] = FRAME_ORDER_FROM_DISTANCES(D, 'root', 5)
%
%   Roots the registration tree at frame 5 (default is 1).

default_options = struct(...
    'root', 1, ...
    'method', 'MST' ... % MST or SP
);

input_options = varargin2struct(varargin{:}); 
options = mergestruct(default_options, input_options);

size_T = size(D, 2);
root = options.root;

switch options.method
    case 'MST'
        [tree, parents] = graphminspantree(D, root);
    case 'SP'
        t = shortestpathtree(digraph(D), root);
        tree = adjacency_from_digraph(t);
        parents = parents_from_tree(tree);
end

% Ensure the tree is directed correctly: 
%   tree(i,j)  -> weight given i is parent of j
tree = tree + tree';
not_root = setdiff(1:size_T, root);
bfs_directed_edges = sparse(parents(not_root), not_root, 1, size_T, size_T);
tree = tree .* bfs_directed_edges;

order = graphtraverse(tree, root, 'Method', 'BFS');