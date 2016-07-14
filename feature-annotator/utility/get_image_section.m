function section = get_image_section(start_indices, feature_size, image)
% function section = get_image_section(start_indices, feature_size, image)
% extracts a section of an image with coordinates starting at
% 'start_indices' and a size of 'size'.  The final coordinates are 
% start_indices+size, so a size of 6 corresponds to 7 indices. boundaries
% are padded with the average value on the face to allow extraction of
% regions that jut out of the original image.


size_image = size(image);
N = length(size_image); 

% Determine the average value of border pixels
border_pixels = [];
for i=1:N
    for j=1:N
        if j==i
            idx{j} = [1 size_image(j)];
        else
            idx{j} = [1:size_image(j)];
        end
    end
    border_pixels = [border_pixels ...
                     reshape(image(idx{:}),1,numel(image(idx{:})))];
end
background_intensity = mean(border_pixels);
clear border_pixels;


% create a larger version of vol to allow features near edges. pad with
% the average value on the border pixels 
bigimage_start_indices = feature_size;
bigimage_end_indices = bigimage_start_indices + size_image - 1;

for i=1:N
    idx{i} = bigimage_start_indices(i):bigimage_end_indices(i);
end

image_large_size = size(image) + 2*feature_size;

image_large = ones(image_large_size, class(image))*background_intensity;
image_large(idx{:})=image;
clear idx vol; % don't need this anymore

new_start_indices = start_indices + bigimage_start_indices - 1;
end_indices = new_start_indices + feature_size;

for i=1:N
    idx{i} = round(new_start_indices(i):end_indices(i));
end
section = image_large(idx{:});
