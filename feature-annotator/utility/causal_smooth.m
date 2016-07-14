function y = causal_smooth(x, N)
% causal_smooth(x, N)
%
%   boxcar averaging, replacing x[i] with mean(x[i-N+1:i]).  x is
%   pre-padded with x(1).

if nargin == 1
    N = 5;
end

if size(x,1) == 1
    x = column(x);
end
L = size(x,1);

row_1 = x(1,:);

x_padded = [repmat(row_1, N-1, 1); x];

x_padded_smooth = conv2(ones(N,1), x_padded)/N;

y = x_padded_smooth(N:N+L-1, :);
