function graph = graph_from_parents(parents)
% graph = graph_from_parents(parents)
%
%   Takes in a vector of parent pointers and generates a directed graph.
%
%       G(i,j) = 1 if i is a parent of j

N = length(parents);
idx = 1;
I = [];
J = [];
for k = 1:length(parents)-1
   
    if ~isnan(parents(k))
        
       I = [I parents(k)];
       J = [J k];
       
    end
    
end

graph = sparse(I, J, true, N, N);
