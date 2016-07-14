function y = subpixel_translate(x, d)
% y = subpixel_translate(x, d)
%
%   Offsets all the data in x by d, where d can be fractional.  y is the
%   same size as x, with undefined outputs replaced by zeros.


y = zeros(size(x));
x_float = double(x);

N = ndims1(x);

d_int = floor(d);
d_frac = d - d_int;

switch N
    
    case 3

        for i = 1:2^3
            [iy, ix, iz] = ind2sub([2 2 2], i);
            idx = [iy, ix, iz];
            idx = idx - 1; % 0-indexed coords
            
            weight = prod(d_frac.^idx .* (1-d_frac).^(1-idx));
            
            y = y + weight * ncircshift(x_float, d_int + idx);
        end
        
    case 2

        for i = 1:2^2
            [iy, ix] = ind2sub([2 2], i);
            idx = [iy, ix];
            idx = idx - 1; % 0-indexed coords
            
            weight = prod(d_frac.^idx .* (1-d_frac).^(1-idx));
            
            y = y + weight * ncircshift(x_float, d_int + idx);
        end
        
    case 1

        for i = 1:2^1
            i = i-1;
            
            weight = d_frac.^i .* (1-d_frac).^(1-i);
            
            y = y + weight * ncircshift(x_float, d_int + i);
        end
end

y = cast(y, class(x));