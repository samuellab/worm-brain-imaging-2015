function track_features(feature_indices)
% track_features(features)
% 
%   tracks all the features using the current settings in 
%   feature_annotator
%
% track_features()
%
%   tracks all features in feature_annotator using current settings

global feature_annotator_data

if nargin == 0
    feature_indices = 1:length(feature_annotator_data.features);
end

for i = feature_indices
    set(feature_annotator_data.gui.active_feature, 'Value', i);
    
    disp(['Starting to track feature ' ...
          feature_annotator_data.features{i}.name]);
      
    feature_annotator_callbacks('auto_segment');
end