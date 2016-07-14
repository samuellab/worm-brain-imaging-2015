function m = raw_moment(A, p, q)
% M = RAW_MOMENT(A, p, q)
%
%   Returns the (p,q)th moment of an array A.

A = double(A);

S = size(A);

A = A .* kron((((1:S(1))').^p), ones(1, S(2)));
A = A .* kron(((1:S(2)).^q), ones(S(1), 1));

m = sum_all(A);