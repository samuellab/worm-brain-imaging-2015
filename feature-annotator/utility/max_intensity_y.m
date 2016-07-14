function output = max_intensity_y(vol)
% Create a maximum intensity projection in the y-direction (xz-plane)

output = squeeze(max(vol,[],1))';