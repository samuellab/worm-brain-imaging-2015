function children = children_from_parents(parents)
% children = children_from_parents(parents)
%
%   Takes a list of parent references and generates a cell array of
%   children for each parent.
%
%   Assumes the parents(end) = 0 is the root of the tree.

for i = 1:length(parents)
    
    children{i} = [];
    
end

for i = 1:length(parents)-1
    
    parent = parents(i);

    if ~isnan(parent)
        children{parent} = [children{parent} i];
    end
        
end