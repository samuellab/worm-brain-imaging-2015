function b = ncircshift(a,p)
% b = ncircshift(a,p)
%
%    Identical to circshift, but pads with zeros

N = ndims1(a);
S = size(a);

for i = 1:N
    idx = cell(1,N);
    for j = 1:N
        idx{j} = ':';
    end
    if p(i) < 0
        idx{i} = 1:(-p(i));
    else
        idx{i} = (S(i)-p(i)+1):S(i);
    end
    a(idx{:}) = 0;
end

b = circshift(a,p);
        