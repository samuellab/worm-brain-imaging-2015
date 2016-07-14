function parents = make_order_for_frames(feature, ref_features, varargin)
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
                    'scales', [1, 1, 5], ...
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

parents(root) = 0;

% Find the registered frames that will be placed beneath the root of the
% tree.
for t = 1:size_T
    
    if is_good_feature(feature, t)
        
        parents(t) = root;
        depths(t) = 1;
        registered = [registered t];
        
        nearby = union(nearby, (t-dt):(t+dt));
    end
    
end

% Gather all the feature centers.
feature_centers = NaN(size_F, 3, size_T);
for i = 1:size_F
    f = ref_features{i};
    
    for t = 1:size_T
        
        if is_good_feature(f, t)
            
            feature_centers(i,:,t) = get_feature_center(f, t);
            
        end
        
    end
    
end


% We'll be reusing distances, so let's keep track of them.
D0 = zeros(size_T, size_T);
D = NaN(size_T, size_T);
N = size_F;
for i = 1:size_T
    for j = (i+1):size_T
        
        c1 = feature_centers(:,:,i);
        c2 = feature_centers(:,:,j);
        
        D0(i,j) = sum(sum(abs(c1-c2)).*options.scales)/N;
        
        % This handles bad frames, but is generally slower
        if isnan(D0(i,j)) 
            
            D0(i,j) = distance_between_frames(ref_features, i, j, ...
                'feature_centers', feature_centers, options);
            
        end
    end
    i
end
D0 = D0 + D0';

nearby = setdiff(nearby, registered);
nearby = intersect(nearby, all_frames);

unregistered = setdiff(1:size_T, registered);

for i = 1:options.frames_to_get
    
    best_child = [];
    best_parent = [];
    best_D = Inf;
    
    for j = row(registered)
        
        for k = row(unregistered)
            
            
            if isnan(D(j,k))
                
                D(j,k) = D0(j,k) * options.depth_penalty ^ (depths(j)+1);
                
            end
            
            if D(j,k) < best_D
                
                best_D = D(j,k);
                best_child = k;
                best_parent = j;
                
            end
                        
        end
        
    end
    
    parents(best_child) = best_parent;
    depths(best_child) = depths(best_parent) + 1;
    
    registered = [registered best_child];
    unregistered = setdiff(unregistered, best_child);
    
%     nearby = union(nearby, (best_child-dt):(best_child+dt) );
%     nearby = setdiff(nearby, registered);
%     nearby = intersect(nearby, all_frames);
    
    if options.show_updates
        
        disp(sprintf(['Register frame %d to frame %d. Depth: %d.\n' ...
            'Overall progrss: %d of %d frames assigned.'], ...
            best_child, best_parent, depths(best_child), i, size_T));
        
    end
    
end