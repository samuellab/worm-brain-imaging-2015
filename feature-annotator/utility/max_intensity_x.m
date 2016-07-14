function output = max_intensity_x(vol)
% Create a maximum intensity projection in the x-direction (yz-plane)

output = squeeze(max(vol,[],2));