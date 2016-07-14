function u = field_from_displacements_ND(d, siz, varargin)
% u = field_from_displacements(d, field_size)
%
%   converts an Mx2 cell array of N-tuples (where N is the dimension of the
%   final volume u) into a field_size sized cell array of N-tuples
%   corresponding to displacements

N = length(siz);

default_options = struct(...
                        'direction', 1, ...
                        'metric', diag([1 1 4]), ...
                        'weighting_function', @(x) 1/(1+x) ...
                        );
input_options = varargin2struct(varargin{:}); 
options = mergestruct(default_options, input_options);

w = options.weighting_function;
g = options.metric(1:N, 1:N);

u = cell(siz);

% r is a list of reference points, stored as columns
% q is a list of reference displacements, stored as columns
for i = 1:size(d,1)
    r(:,i) = d{i,1};
    q(:,i) = d{i,2};
end


for i = 1:numel(u)
    idx = cell(N,1);
    [idx{:}] = ind2sub(siz, i);
    idx = cell2mat(idx);
    
    % displacement from reference points
    y = r - kron(idx, ones(1,size(d,1)));
    
    % distance from reference points
    y = diag( y' * g * y );
    
    % normalized weights
    weights = arrayfun(w, y);
    weights = weights/sum_all(weights);
    
    u{i} = q * weights;

end