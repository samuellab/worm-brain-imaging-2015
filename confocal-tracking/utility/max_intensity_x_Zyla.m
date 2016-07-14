function output = max_intensity_x_Zyla(vol)
% Create a maximum intensity projection in the z-direction (xy-plane)

% DEPRECATED 15-04-15
% Take the maximum intensity projection.
%output = squeeze(max(vol,[],1));

% Transpose and flip 
%output = flipud(vol');

% END

output = flipud(squeeze(max(vol,[],2)));

