function im = clamp_intensity(im, threshold)
% im = clamp_intensity(im, threshold)
%
%   Saturates the image by clamping all values above threshold to
%   threshold. 

im(im>threshold)=threshold;