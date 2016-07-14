function varargout = make_offset_feature(reference_feature, varargin)
% new_feature = make_offset_feature(reference_feature, 'offset', [dy dx (dz)])
%
%   Creates a new feature identical to reference_feature, but with an
%   offset of [dy dx dz].
%
% new_feature = make_offset_feature(reference_feature)
%
%   Creates a new feature using an offset provided by feature_annotator
%   (queries the user)
%
% new_feature = make_offset_feature(reference_feature, 'new_name', 'Red')
%
%   Creates a new feature with a name of 'Red'
%
% make_offset_feature(reference_feature)
%
%   The new feature is appended to feature_annotator_data.features

global feature_annotator_data;

if isnumeric(reference_feature)
    reference_feature = feature_annotator_data.features{reference_feature};
end

default_options = struct(...
                        'new_name', reference_feature.name, ...
                        'offset', []...
                        );
input_options = varargin2struct(varargin{:}); 
options = mergestruct(default_options, input_options);


new_feature = reference_feature;
new_feature.name = options.new_name;

if isempty(options.offset)
    offset = get_displacement();
else
    offset = options.offset;
end

new_feature = shift_feature_coordinates(new_feature, offset);

if nargout == 1
    varargout(1) = new_feature;
else
    feature_annotator_data.features(end+1) = new_feature;
end