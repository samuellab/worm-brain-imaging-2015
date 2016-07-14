function [z, t, offset] = get_z(mfile, varargin)
% [z, t, offset] = get_z(mfile)
%
%   output: z in microns, t in seconds, offset in seconds
%
%   using 'row, column' convention to address locations on the stage: x
%   corresponds to distance right from left edge, y corresponds to distance
%   down from top edge.

default_options = struct( ...
    'expand', false ...
);

input_options = varargin2struct(varargin{:}); 
options = mergestruct(default_options, input_options);

% This was the correct for images taken prior to ~11/15/2014.
% x = mfile.stage(1,:) * 1e-1; % 1 stage unit = 100nm
% y = mfile.stage(2,:) * 1e-1;
% t = mfile.times;
% 
% good_indices = find(x~=0);
% 
% x = -x(good_indices);
% y = -y(good_indices);
% t = t(good_indices);

z = mfile.Z;

t_all = mfile.times;

good_indices = find(z~=0);

z = z(good_indices);
t = t_all(good_indices);

if options.expand
    
    z = interp1(t, z, t_all, 'linear', 'extrap');
    t = t_all;
    
end

if any(abs(z) > 100) % Hack to detect the focus motor
    z = z*1e-1; % 1 unit = 100 nm
    z = z - min(z); % recenter
end
    

[t, offset] = get_referenced_time(t);