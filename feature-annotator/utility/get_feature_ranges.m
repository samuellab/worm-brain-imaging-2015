function ranges = get_feature_ranges(features)
% ranges = get_feature_ranges(features)
%
%   Returns the ranges of features{i}.coordinates (1 x D) as an array of
%   size 2 x D x N, where N = length(features).  If the field
%   'is_registered' is present, it must be marked as true for each time
%   point to be used in this computation.  Similarly, if the field
%   'is_bad_frame' is present and marked true, that frame won't be used.

N = length(features);
D = size(features{1}.coordinates, 2);
T = size(features{1}.coordinates, 1);

ranges = repmat([inf(1, D); -inf(1, D)], [1, 1, N]);

for i = 1:N
    for t = 1:T
        
        use_time = true;
        if isfield(features{i}, 'is_registered')
            use_time = features{i}.is_registered(t);
        end
        if isfield(features{i}, 'is_bad_frame')
            use_time = use_time && ~features{i}.is_bad_frame(t);
        end
        
        if use_time
            c = features{i}.coordinates(t,:);
            ranges(1,:,i) = min(c, ranges(1,:,i));
            ranges(2,:,i) = max(c, ranges(2,:,i));
        end
        
    end
end