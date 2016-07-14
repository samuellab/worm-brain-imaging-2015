function feature_annotator_register_frame(feature_index, t, varargin)
% feature_annotator_register_frame(feature_index, t, opts)
%
%   Register a frame using data stored in feature_annotator_data. See
%   register_feature_frame() for options.

input_options = varargin2struct(varargin{:}); 

global feature_annotator_data;

f = feature_annotator_data.features{feature_index};

f = register_feature_frame(f, feature_annotator_data.image_location, t, ...
    input_options);

feature_annotator_data.features{feature_index} = f;