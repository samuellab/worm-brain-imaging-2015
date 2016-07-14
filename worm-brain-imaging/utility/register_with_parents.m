function features = register_with_parents(features, image_location, order, parents, varargin)
% features = REGISTER_WITH_PARENTS(features, image_location, order, parents)
%
%   Register a time series using specified reference frames.

default_options = struct(...
    'show_progress', false ...
);

input_options = varargin2struct(varargin{:}); 
options = mergestruct(default_options, input_options);

if options.show_progress
    global feature_annotator_data;
    feature_annotator_data.image_location = image_location;
    feature_annotator_data.features = features;
end

for i = 1:length(features)
    f = features{i};
    
    if options.show_progress
        
        set(feature_annotator_data.gui.active_feature, 'Value', i);
        set(feature_annotator_data.gui.feature_list, 'Value', i);
        feature_annotator_callbacks('Configure_Feature_UI_Elements');
        
    end
    
    for t = order

        f = register_feature_frame(f, image_location, t, ...
            't_ref', parents(t), options);
        
        if options.show_progress
            
            feature_annotator_data.t = t;
            feature_annotator_data.features{i} = f;
            feature_annotator_callbacks('Update_Image');
            
        end

    end
    
    features{i} = f;
end