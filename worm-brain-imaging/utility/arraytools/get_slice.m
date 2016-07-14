function B = get_slice(A, t, d)
% B = GET_SLICE(A, t)
%
%   B = A(:, :, ..., t)
%
% B = GET_SLICE(A, t, d)
%
%   B = squeeze(A(:, :, ...., t, ..., :, :)), where t is in the d-th
%   dimension.
%
%   If you're attempting to get a y-slice of a 3D array, you may want to
%   use the transposed result GET_SLICE(A,34, 1)' to put it into a
%   canonical position.

N = ndims(A);

if nargin < 3
    d = N;
end

idx = cell(N,1);
[idx{:}] = deal(':');

idx{d} = t;

B = squeeze(A(idx{:}));