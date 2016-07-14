function a = adjacency_from_digraph(d)
% a = ADJACENCY_FROM_DIGRAPH(d)
%
%   Convert a digraph object to a sparse adjacency matrix.

links = d.Edges{:,'EndNodes'};
weights = d.Edges{:,'Weight'};

s = size(d.Nodes, 1);

a = sparse(links(:,1), links(:,2), weights, s, s);