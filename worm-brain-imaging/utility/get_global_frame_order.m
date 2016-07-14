function [order, tree, parents] = get_global_frame_order(image_location, varargin)
% [order, tree, parents] = GET_GLOBAL_FRAME_ORDER(image_location)
%
%   Determines a global order based on similarity of maximum intensity
%   projections in the z-direction. By default, the root is frame 1.
%
% [order, tree, parents] = GET_GLOBAL_FRAME_ORDER(image_location, 'root', 3)
%
%   Specifies the root for registration.


default_options = struct(...
    'root', 1 ...
);

input_options = varargin2struct(varargin{:}); 
options = mergestruct(default_options, input_options);

size_T = get_size_T(image_location);
root = options.root;
images = {};

for i = 1:size_T
    
    images{i} = max_intensity_z(load_image(image_location, 't', i));
    
end

D = zeros(size_T, size_T);

for i = 1:size_T
    for j = (i+1):size_T
        
        D(i,j) = 1 - get_image_overlap(images{i}, images{j});
        
    end
end

D = D + D';

% Create connections between the root node
D_sparse = sparse(D);

[tree, parents] = graphminspantree(D_sparse, root);

% Ensure the tree is directed correctly: 
%   tree(i,j)  -> weight given i is parent of j
tree = tree + tree';
not_root = setdiff(1:size_T, root);
bfs_directed_edges = sparse(parents(not_root), not_root, 1, size_T, size_T);
tree = tree .* bfs_directed_edges;

order = graphtraverse(tree, root, 'Method', 'BFS');