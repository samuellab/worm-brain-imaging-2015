function out = translate_feature(in, d)
% out = translate_feature(in, d)
%   translate a feature by d


if isnumeric(in)
    use_index = true;
    idx = in;
    
    global feature_annotator_data;
    in = feature_annotator_data.features{idx};
else
    use_index = false;
end

d = row(d);
out = in;

if isfield(in, 'coordinates')
    size_T = size(in.coordinates, 1);
    out.coordinates = in.coordinates + kron(d, ones(size_T,1));
end

if isfield(in, 'modified_coordinates')
    size_T = size(in.modified_coordinates, 1);
    out.modified_coordinates = ...
        in.modified_coordinates + kron(d, ones(size_T,1));
end

if use_index
    feature_annotator_data.features{idx} = out;
end