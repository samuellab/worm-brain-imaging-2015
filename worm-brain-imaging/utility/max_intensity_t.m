function A = max_intensity_t(image_location)
% A = max_intensity_t(image_location)
%
%   Computes a max intensity projection in the t-direction from a 4D array
%   stored as time slices.

size_T = get_size_T(image_location);

get_slice = @(x) load_image(image_location, 't', x);

img = get_slice(1);
A = zeros(size(img), 'like', img);

for t = 1:size_T
    
    x = get_slice(t);
    
    A = bsxfun(@max, A, x);
    
end