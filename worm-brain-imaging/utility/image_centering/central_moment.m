function m = central_moment(A, p, q)
% M = CENTRAL_MOMENT(A, p, q)
%
%   Returns the (p,q)th central moment of an array A.

A = double(A);

c = get_image_centroid(A);

S = size(A);

A = A .* kron(((((1:S(1))-c(1))').^p), ones(1, S(2)));
A = A .* kron((((1:S(2))-c(2)).^q), ones(S(1), 1));

m = sum_all(A);