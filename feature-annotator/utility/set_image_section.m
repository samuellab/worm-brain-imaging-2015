function image = set_image_section(image, start_indices, section)
% function out_image = set_image_section(image, start_indices, section)
% Sets a section of an image with coordinates starting at
% 'start_indices'. 

feature_size = size(section);
size_image = size(image);
N = length(size_image); 

% create a larger version of vol to allow features near edges. pad with
% the average value on the border pixels 
end_indices = start_indices + feature_size - 1;

adj_start_indices = max(start_indices, ones(size(start_indices)));
adj_end_indices = min(end_indices, size(image));

for i=1:N
    idx{i} = adj_start_indices(i):adj_end_indices(i);
    section_idx{i} = (adj_start_indices(i)-start_indices(i) + 1):...
                     (adj_end_indices(i)-end_indices(i) + feature_size(i));
end

image(idx{:}) = section(section_idx{:});
