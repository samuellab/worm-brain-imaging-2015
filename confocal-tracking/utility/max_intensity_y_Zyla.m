function output = max_intensity_y_Zyla(vol)
% Create a maximum intensity projection in the z-direction (xy-plane)

% Take the maximum intensity projection.
vol = squeeze(max(vol,[],2));

% % Fix the bad pixel
% vol(224, :) = vol(225, :);

% Transpose and flip
output = (vol');