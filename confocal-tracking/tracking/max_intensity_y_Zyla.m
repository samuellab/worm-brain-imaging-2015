function output = max_intensity_y_Zyla(vol)
% Create a maximum intensity projection in the z-direction (xy-plane)

% DEPRECATED 15-04-15
% Take the maximum intensity projection.
% im = squeeze(max(vol,[],2));

% % Fix the bad pixel
% vol(224, :) = vol(225, :);

% Transpose and flip
%output = im';
% END

output = squeeze(max(vol,[],1))';
