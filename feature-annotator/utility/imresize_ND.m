function image_out = imresize_ND(image, N)
% image_out = imresize(image, [Ny Nx Nz ...])
%
%   Resize an image by a factor of Nd along dimension d, using a boxcar
%   filter.  The size of the resulting image is floor(size(image)./N), so
%   remainder rows/columns will get thrown out in the decimation process.

filter = ones(N)/prod(N);

S = size(image);

image = imfilter(image, filter, 'full');

for i = 1:length(N)
    idx{i} = N(i):N(i):S(i);
end

image_out = image(idx{:});