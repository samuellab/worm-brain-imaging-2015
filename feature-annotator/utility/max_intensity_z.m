function output = max_intensity_z(vol)
% Create a maximum intensity projection in the z-direction (xy-plane)

output = squeeze(max(vol,[],3));