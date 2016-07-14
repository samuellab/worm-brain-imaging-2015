function posture = posture_from_head(head_trajectory, L, varargin)
% posture_from_head(head_trajectory, length)
%
%   Takes in a trajectory (2 x size_T) of (x, y) coordinates correspoding
%   to a worm's head trajectory over time. The parameter L should be the
%   length of the worm in the same units as head_trajectory.  It's assumed
%   that points are uniformly sampled in time.
%
%   The position is determined by assuming the body follows the head while
%   the worm is moving forward, and the posture backtracks perfectly when 
%   the worm is reversing. When the worm swings its head, it is assumed
%   that the first 10% of the posture is smoothly updated.
%
%   By default, the posture is returned as a 2 x N x size_T array of
%   the time trajectories of each component. posture(:,1,:) should
%   correspond identicaly to the provide head_trajectory and
%   posture(:,end,:) corresponds to the estimated tail trajectory.
%
%   It is assumed that the worm begins by heading forward. Otherwise, use:
%
% posture_from_head(head_trajectory, length, 'initial', reverse)
%
%   Assumes the animal begins by moving backwards.
%
% posture_from_head(head_trajectory, length, 'segments', 200)
%
%   Segments the animal into 200 instead of 100 points.
%
% posture_from_head(head_trajectory, length, 'segments_for_normal', 9)
%
%   Use the vector from segment 10 to segment 1 (head) to determine normal
%   vector.
%
% posture_from_head(head_trajectory, length, 't_init', 30)
%
%   Wait for 30 frames before making estimates.
%
% posture_from_head(head_trajectory, length, 'xhat', xhat)
%
%   use the normal vectors provided (when they're not nan)
%



% kwarg boilerplate
default_options = struct(...
    'initial', 'forward', ...
    'segments', 100, ...
    'segments_for_normal', 5, ...
    't_init', 30, ...
    'xhat', [] ...
);
input_options = varargin2struct(varargin{:}); 
options = mergestruct(default_options, input_options);
% end boilerplate

N_seg = options.segments;
dL = L / (N_seg - 1);
size_T = size(head_trajectory, 2);

% Length-parameterized history for the head (units: dL).  This will behave
% as a stack, with elements pushed as the worm moves forward and popped as
% it reverses.
ix = N_seg;
X = NaN(2, N_seg);
X(:, ix) = head_trajectory(:, 1);

dx = @(t) head_trajectory(:,t) - head_trajectory(:,t-1);
ds = @(t) norm(dx(t));

posture = NaN(2, N_seg, size_T);

if strcmp(options.initial, 'forward')
    moving_forward = 1;
else
    moving_forward = -1;
    error('does not work yet');
end


ds_vec = [0];
X1 = [head_trajectory(1,1)];
X2 = [head_trajectory(2,1)];

for t = 2:options.t_init
    
    ds_vec = [ds_vec ds(t)];
    X1 = [X1, head_trajectory(1,t)];
    X2 = [X2, head_trajectory(2,t)];
    
    posture(1,:,t) = interp1(1:size(X,2), X(1,:), (ix-(N_seg-1)):ix);
    posture(2,:,t) = interp1(1:size(X,2), X(2,:), (ix-(N_seg-1)):ix);
end

ds_cumsum = cumsum(ds_vec);
init_idx = 0:floor(ds_cumsum(end)/dL);
X1_init = interp1(ds_cumsum/dL, X1, init_idx);
X2_init = interp1(ds_cumsum/dL, X2, init_idx);

X(1,N_seg + init_idx) = X1_init;
X(2,N_seg + init_idx) = X2_init;

ix = N_seg + ds_cumsum(end)/dL;

for t = t_init+1 :size_T
    
    xhat = get_xhat();
    dx_par = dot(dx(t), xhat);
    dx_perp = dx(t) - dx_par;
    
    ix = ix + dx_par / dL;
    
    t
    if dx_par < 0
        X1 = interp1([1:floor(ix) ix], [X(1,1:floor(ix)) head_trajectory(1,t)], ...
            1:floor(ix), 'spline', 'extrap');
        X2 = interp1([1:floor(ix) ix], [X(2,1:floor(ix)) head_trajectory(2,t)], ...
            1:floor(ix), 'spline', 'extrap');
        X = [X1; X2];
    else
        X1 = interp1([1:size(X,2) ix], [X(1,:) head_trajectory(1,t)], ...
            1:floor(ix), 'spline', 'extrap');
        X2 = interp1([1:size(X,2) ix], [X(2,:) head_trajectory(2,t)], ...
            1:floor(ix), 'spline', 'extrap');
        X = [X1; X2];
    end

    posture(1,:,t) = interp1(1:size(X,2), X(1,:), ix:-1:(ix-(N_seg-1)), ...
        'spline', 'extrap');
    posture(1,:,t) = smooth(posture(1,:,t), round(0.15*N_seg));
    posture(2,:,t) = interp1(1:size(X,2), X(2,:), ix:-1:(ix-(N_seg-1)), ...
        'spline', 'extrap');
    posture(2,:,t) = smooth(posture(2,:,t), round(0.15*N_seg));
    
end

    function xhat = get_xhat

        if ~isempty(options.xhat) && all(~isnan(options.xhat(:,t)))

            xhat = options.xhat(:,t);

        else

            n = X(:,floor(ix)) - X(:,floor(ix)-options.segments_for_normal);
            %n = dx(t) * moving_forward;
            xhat = n / norm(n); % should be unnecessary      

        end

    end

    
end