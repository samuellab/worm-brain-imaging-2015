function clone_feature(feature, locations, tag)
% clone_feature(feature, locations, tag)
%
% Copies the feature so feature.ref_offset is placed at each of the
% coordinates specified by rows of locations.  The new features are
% labelled 'tag_01', 'tag_02', ... 'tag_34' (if there are 34 rows in
% locations);

global feature_annotator_data

if isnumeric(feature)
    feature = feature_annotator_data.features{feature};
end

if ~isfield(feature, 'coordinates')
    feature.coordinates = zeros(feature_annotator_data.size_T, ...
                                    size(locations, 2));
end
if ~isfield(feature, 'modified_coordinates')
    feature.modified_coordinates = nan(feature_annotator_data.size_T, ...
                                    size(locations, 2));
end

if isempty(locations)
    i = 1;
    while true
        p = get_point();
        
        if isempty(p)
            break;
        end
        
        locations(i,:) = p;
        i = i+1;
        
    end
end



N = size(locations,1); % number of features
digits = ceil(log10(N+1));


for i = 1:size(locations,1)
    feature_annotator_data.features{end+1} = feature;
    
    if size(locations,1) > 1
        feature_annotator_data.features{end}.name = [tag sprintf(...
                                            ['_%0' num2str(digits) 'd'],...
                                                    i)];
    else
        feature_annotator_data.features{end}.name = tag;
    end
    % displacement from original reference to new reference
    offset = locations(i,:) - ...
             (feature.coordinates(1,:)+feature.ref_offset);
    
    new_coords = feature.coordinates(1,:) + offset;
    
    size_T = size(feature.coordinates,1);
    feature_annotator_data.features{end}.coordinates = ...
        kron(new_coords, ones(size_T,1));
    
    feature_annotator_data.features{end}.modified_coordinates = ...
        nan(size(feature.modified_coordinates));
    feature_annotator_data.features{end}.modified_coordinates(1,:) = ...
        feature_annotator_data.features{end}.coordinates(1,:);

end