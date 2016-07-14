function display_vol = zyla_vol(buffer_vol)
% Converts a volume from the buffer in Andor's SDK3 to a volume for
% display (permutes dimensions 1 and 2).  This should always be used when
% accessing data stored directly from the camera.

% switch ndims(buffer_vol)
%     
%     % deprecated 9/22/2015
%     case 2
%         display_vol = permute(buffer_vol, [2, 1]);
%     case 3
%         display_vol = permute(buffer_vol, [2, 1 ,3]);
%     case 4
%         display_vol = permute(buffer_vol, [2, 1 ,3, 4]);
%     
% end

display_vol = flip(buffer, 1);