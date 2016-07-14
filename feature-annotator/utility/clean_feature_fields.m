function F = clean_feature_fields(F)
% F = clean_feature_fields(F)
% 
%   Adds the fields 'is_bad_frame' and 'is_registered' as a field for each
%   in put feature in the cell array F (if the field isn't present
%   already).

if nargin == 0
    global feature_annotator_data;
    F = feature_annotator_data.features;
end

for i = 1:length(F)
    size_T = size(F{i}.coordinates, 1);
    if ~isfield(F{i}, 'is_bad_frame')
        F{i}.is_bad_frame = zeros(size_T, 1);
    end
    if ~isfield(F{i}, 'is_registered')
        F{i}.is_registered = zeros(size_T, 1);
    end
end

if nargin == 0
   feature_annotator_data.features = F;
end