function d = distance_between_frames(features, t1, t2, varargin)
% d = distance_between_frames(features, ref_indices, t1, t2)
%
%   Returns the distance between two frames using the average displacement
%   between centers of ref_features as a metric.

default_options = struct(...
                    'scales', [1, 1, 5], ...
                    'metric_fn', @(x,y) sum(abs(x-y)), ...
                    'feature_centers', []...
                    );

input_options = varargin2struct(varargin{:}); 
options = mergestruct(default_options, input_options);

S = 0;
N = 0;
for i = 1:length(features)
    f = features{i};

    if is_good_feature(f, [t1, t2])

        if ~isempty(options.feature_centers)

            c1 = options.feature_centers(i, :, t1);
            c2 = options.feature_centers(i, :, t2);

        else

            c1 = get_feature_center(f, t1);
            c2 = get_feature_center(f, t2);

        end

        c1 = c1.*options.scales;
        c2 = c2.*options.scales;

        S = S + options.metric_fn(c1, c2);
        N = N + 1;

    end

end

d = S/N;