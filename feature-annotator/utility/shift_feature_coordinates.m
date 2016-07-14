function output_features = shift_feature_coordinates(input_features, delta)
% input is cell array of features along with a vector of shifts (should be
% the same size as features{i}.coordinates)
%
% output is result of shifting the field 'coordinates' and the field
% 'modified_coordinates' of input_features.  otherwise identical to
% input_features.

if ~iscell(input_features)
    input_features = {input_features};
end

output_features = input_features;

for i=1:length(output_features)
    if isfield(output_features{i}, 'coordinates')
        output_features{i}.coordinates = ...
            output_features{i}.coordinates + ...
            kron(delta, ...
                 ones(size(output_features{i}.coordinates,1),1));
    end
    
    if isfield(output_features{i}, 'modified_coordinates')
        output_features{i}.modified_coordinates = ...
            output_features{i}.modified_coordinates + ...
            kron(delta, ...
                 ones(size(output_features{i}.modified_coordinates,1),1));
    end
end