function parents = get_registration_parents(size_T, root, root_children, varargin)
% parents = get_registration_parents(size_T, root, root_children)
%
%   determine the parent of each frame in a registration tree, assuming
%   frames should generally be registered to adjacent frames and that
%   root_children is a list of frames that should be registered to root.
%
% parents = get_registration_parents(size_T, root, root_children, 'bad_frames', [33:52])
%
%   optionally specify frames that are bad.  These should not have good
%   frames as children.

default_options = struct(...
                    'bad_frames', [] ... 
                   );
input_options = varargin2struct(varargin{:}); 
options = mergestruct(default_options, input_options);

parents = [];

parents(root) = 0;

for i = root_children
    parents(i) = root;
end

for t = 1:size_T
    
    candidates = root_children;
    
    if t == root
        parents(t) = 0;
        continue
    elseif find(t==root_children)
        parents(t) = root;
        continue
    end
    
    % Find the nearest child of root
    [~, target_idx] = min(abs(candidates - t));
    target = candidates(target_idx);
    
    % ensure that there are no bad frames between the current frame and the
    % child we're going to register to
    if any(ismember(t:sign(target-t):target, options.bad_frames)) && ...
       ~ismember(t, options.bad_frames)
        
        if target > t
            
            candidates = candidates(candidates < t);
            [~, target_idx] = min(abs(candidates - t));
            target = candidates(target_idx);
            
        else
            
            candidates = candidates(candidates > t);
            [~, target_idx] = min(abs(candidates - t));
            target = candidates(target_idx);
            
        end
        
        if any(ismember(t:sign(target-t):target, options.bad_frames))
            
            error(['no assignment possible for time ' num2str(t)]);
            
        end
        
    end
    
    if target > t
        
        parents(t) = t+1;
        
    else
        
        parents(t) = t-1;
        
    end
    
end