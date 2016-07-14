function [order, tree, parents] = make_order_for_frames(feature, ref_features, varargin)
%   make_order_for_frames(feature, ref_features)
%
%       Makes an order of frames for registering feature using a distance
%       computed with ref_features. ref_features should be registered in
%       every frame. 
%
%       Because many frames may be valid roots, we'll make them all
%       children of a 'null' root. By convention, that will be frame 
%       size_T + 1.

size_T = size(feature.coordinates, 1);
size_F = length(ref_features);

default_options = struct(...
    'scales', [1, 1, 4], ...
    'depth_penalty', 1, ...
    'frames_to_get', size_T, ...
    'show_updates', false, ...
    'dt', 5000 ...
);

input_options = varargin2struct(varargin{:}); 
options = mergestruct(default_options, input_options);

% Convention: the root of the tree is at index end+1
root = size_T + 1; 
parents = nan(size_T+1, 1);
depths = nan(size_T+1, 1);
all_frames = 1:options.frames_to_get;
registered = [];

nearby = [];
dt = options.dt;

% We'll be reusing distances, so let's keep track of them.
D = zeros(size_T+1, size_T+1);

% Find the registered frames that will be placed beneath the root of the
% tree.
for t = 1:size_T
    
    if is_good_feature(feature, t) || feature.is_bad_frame(t)
        
        D(root, t) = 1;
	 
    end
    
end

% Gather all the reference feature centers.
feature_centers = NaN(size_F, 3, size_T);
for i = 1:size_F
    f = ref_features{i};
    
    for t = 1:size_T
        
        if is_good_feature(f, t)
            
            feature_centers(i,:,t) = get_feature_center(f, t);
            
        end
        
    end
    
end


N = size_F;
for i = 1:size_T
    
    for j = (i+1):size_T
        
        c1 = feature_centers(:,:,i);
        c2 = feature_centers(:,:,j);
        c = abs(c1-c2);
        
        good_rows = find(~isnan(c(:,1)));
        c = c(good_rows, 1);
        N = length(good_rows);
        
        D(i,j) = sum(sum(c).*options.scales)/N;
        
    end
    
end
D = D + D';

% Create connections between the root node
D_sparse = sparse(D);

[tree, parents] = graphminspantree(D_sparse, root);

% Ensure the tree is directed correctly: 
%   tree(i,j)  -> weight given i is parent of j
tree = tree + tree';
bfs_directed_edges = sparse(parents(1:size_T), 1:size_T, 1, root, root);
tree = tree .* bfs_directed_edges;

order = graphtraverse(tree, root, 'Method', 'BFS');
order = order(2:end); % eliminate dummy root node