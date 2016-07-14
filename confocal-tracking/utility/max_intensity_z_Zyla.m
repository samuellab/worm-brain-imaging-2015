function output = max_intensity_z_Zyla(vol)
% Create a maximum intensity projection in the z-direction (xy-plane)

% Take the maximum intensity projection.
vol = squeeze(max(vol,[],3));

% % Fix the bad pixel
% vol(224, 190) = vol(224, 191);

% Transpose
output = (vol');