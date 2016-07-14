function vol = load_zyla_vol(raw_volume)
% vol = LOAD_ZYLA_VOL(raw_volume)
%
%   Takes in a raw volume from the Zyla's framebuffer and rotates it to
%   match the global coordinate system defined by the stage and the piezo.
%   It should be used whenever accessing data stored directly from the
%   camera, and is senstive to details of the optical path at the time of
%   measurement.
%
%   The size of raw_volume will be [Y0, X0, Z], where Y0 and X0 are
%   determined by the camera's buffer. The output vol will have shape
%   [Y, X, Z, C], where side-by-side images are rearranged to form the
%   'C', or channel, dimension. The convention is to take first correct for
%   geometry (rotations and mirrors), then to extract channels.

%   This is correct as of 5/1/2015.
raw_size = size(raw_volume);
size_Z = raw_size(3);

rotated = flip(raw_volume, 1);

top = rotated(1:256,:,:);
bottom = rotated(257:512,:,:);

vol = zeros(256, 256, size_Z, 2, 'uint16');

vol(:,:,:,1) = top; % green emission
vol(:,:,:,2) = bottom; % red emission