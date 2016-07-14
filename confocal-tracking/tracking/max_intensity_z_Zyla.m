function output = max_intensity_z_Zyla(vol)
% Create a maximum intensity projection in the z-direction (xy-plane)

% Take the maximum intensity projection.

im = squeeze(max(vol,[],3));

% Transpose and flip
%output = fliplr(vol');

% Just flip vertically now (deprecated 15-04-15)
%output = im';

% Transpose and flip up/down
output = flipud(im);