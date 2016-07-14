function u = field_from_displacements(d, siz, varargin)
% u = field_from_displacements(d, field_size)
%
%   converts an Mx2 cell array of 3-tuples into a field_size sized cell 
%   array of 3-tuples corresponding to displacements


default_options = struct(...
                        'direction', 1, ...
                        'metric', diag([1 1 4]), ...
                        'weighting_function', @(x) 1/(1+x), ...
                        'rigid_preprocess', true, ...
                        'num_nearest', 5 ...
                        );
                    
input_options = varargin2struct(varargin{:}); 
options = mergestruct(default_options, input_options);

w = options.weighting_function;
g = options.metric;

u = cell(siz);

% r is a list of reference points, stored as columns
% q is a list of reference displacements, stored as columns
for i = 1:size(d,1)
    r(:,i) = column(d{i,1});
    q(:,i) = column(d{i,2});
end

targets = r + q;

if options.rigid_preprocess
    global_transform = estimateRigidTransform(targets, r);
else
    global_transform = eye(4);
end

% new_r = transform * [r; ones(1,size(r,2))];
% new_r = new_r(1:3, :);
% 
% new_q = targets - new_r;
for i = 1:numel(u)
    
    [iy, ix, iz] = ind2sub(siz, i);
    idx = [iy; ix; iz];

    nearest = find_nearest(idx, r, options.num_nearest);
    if options.rigid_preprocess
        if length(nearest) == options.num_nearest
            local_r = r(:, nearest);
            local_targets = targets(:, nearest);
            local_transform = estimateRigidTransform(local_targets, ...
                                                     local_r);
        else
            loal_transform = global_transform;
        end
    else
        local_transform = eye(4);
    end

    
    new_r = local_transform * [r; ones(1,size(r,2))];
    new_r = new_r(1:3, :);

    new_q = targets - new_r;
    
    new_idx = local_transform * [idx; 1];
    new_idx = new_idx(1:3);
    
    % displacement from transformed reference points
    y = new_r - kron(new_idx, ones(1,size(d,1)));
    
    % distance from transformed reference points
    y = diag( y' * g * y );
    
    % normalized weights
    weights = arrayfun(w, y);
    weights = weights/sum_all(weights);
    
    u{i} = (new_idx - idx) + new_q * weights;

end