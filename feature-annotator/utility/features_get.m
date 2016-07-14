function [feature, idx] = features_get(features, name)
% feature = features_get(features, name)
%
%   Returns the element of features that has a specified name. If multiple
%   features have a given name, a warning is thrown and the first feature
%   is returned. If no feature exists for a given name, the returned value
%   is false.

matches = [];
for i = 1:length(features)
    
    if strcmp(features{i}.name, name)
        matches(end+1) = i;
    end
    
end

switch length(matches)
    case 0
        
        idx = [];
        feature = false;
        
    case 1
        
        idx = matches;
        feature = features{idx};
        
    otherwise
        
        warning(['Multiple features with name ' name ' found.' ...
            '  Returning only the first one.']);
        
        idx = matches(1);
        feature = features{idx};
        
end