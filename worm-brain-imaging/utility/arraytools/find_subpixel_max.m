function subpixel_coords = find_subpixel_max(array)
% coords = FIND_SUBPIXEL_MAX(array)
%
%   Finds the global maximum of an array to sub-pixel accuracy using a 
%   quadratic fit (one for each dimension).  It may be improved by doing an
%   ND quadratic fit instead.
%
%   No fitting is done for maxima at boundaries (integer coords returned)


N = ndims(array);

% Get the indices of the global max.  The actual max should be close.
coords = cell(1,N);
[coords{:}] = ind2sub(size(array), find(array == max_all(array),1));
coords = cell2mat(coords);

subpixel_coords = zeros(1,N);

for i = 1:N
    
    idx = cell(1,N);
    for j= [1:(i-1) (i+1):N]
        idx{j} = coords(j);
    end
    idx{i} = coords(i)-1 : coords(i)+1;
    
    if idx{i}(1) < 1
        subpixel_coords(i) = 1;
    elseif idx{i}(end) > size(array,i)
        subpixel_coords(i) = size(array,i);
    else
        % get 3 elements along the current dimension for fitting
        y = row(array(idx{:}));

        % fit a quadratic to the three elements in y, and return the
        % coordinates of the maximum
        subpixel_coords(i) = (y(1) - y(3))/(2*y(1) - 4*y(2) + 2*y(3)) ...
                             + coords(i);
    end
    
end