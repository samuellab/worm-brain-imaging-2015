function imagedata = get_feature_image(t, feature, image_location)
% imagedata = get_feature_image(t, feature, image_location)
%
%   Returns the image or volume corresponding to feature at time t.

if nargin < 3
    
    global feature_annotator_data;
    image_location = feature_annotator_data.image_location;
    
end

if nargin < 2
    
    idx = get(feature_annotator_data.gui.active_feature, 'Value');
    feature = feature_annotator_data.features{idx};
    
end
if nargin < 1
    
    t = feature_annotator_data.t;
    
end

if isnumeric(feature)
    
    global feature_annotator_data;
    feature = feature_annotator_data.features{feature};
    
end


if isnumeric(image_location)
    
    vol = image_location;
    
else
    
    vol = load_image(image_location, 't', t);
    
end

imagedata = get_image_section(feature.coordinates(t,:), ...
    feature.size, vol);