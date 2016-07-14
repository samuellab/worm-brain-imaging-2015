function center = get_feature_center(feature, t, varargin)
% center = get_feature_center(feature, t)
%
%   Returns the center of a feature are the specified times as a T x 3
%   array. center(t,1) is the row index at time t, center(t,2) is the
%   column index, and center(t,3) is the z index.


default_options = struct(...
                    'all', false ...
);

input_options = varargin2struct(varargin{:}); 
options = mergestruct(default_options, input_options);


if nargin < 2

    global feature_annotator_data;
    t = feature_annotator_data.t;
    
end

if isnumeric(feature)
    
    global feature_annotator_data;
    feature = feature_annotator_data.features{feature};
    
end

if options.all
    
    t = 1:size(feature.coordinates, 1);
    
end

center = NaN(length(t), 3);
for i = 1:length(t)
    
    if ~feature.is_bad_frame(t(i))
        center(i,:) = feature.coordinates(t(i),:) + ...
            0.5 * feature.size;
    else
        center(i,:) = NaN;
    end
    
end