function features = set_feature_size(features, new_size, varargin)
% features = set_feature_size(features, new_size)
%
%   Sets the size of each feature in features to new_size, assuming the
%   reference point is in the middle of the feature.


use_global = false;
if isnumeric(features)
    idx = features;
    global feature_annotator_data;
    features = feature_annotator_data.features(idx);
    use_global = true;
end

for i = 1:length(features)
        
    f = features{i};
    
    old_offset = f.ref_offset;
    
    new_offset = new_size/2;

    f.size = new_size;
    f.ref_offset = new_size/2;
    
    f = translate_feature(f, old_offset - new_offset);
    
    features{i} = f;
    
end

if use_global
    
    feature_annotator_data.features(idx) = features;
    
end