function [x, y, t, offset] = get_stage(mfile, varargin)
% [x, y, t, offset] = GET_STAGE(mfile)
%
%   output: x in microns, y in microns, t in seconds, offset in seconds
%
%   using 'row, column' convention to address locations on the stage: x
%   corresponds to distance right from left edge, y corresponds to distance
%   down from top edge.

default_options = struct( ...
    'expand', false, ...
    'center', true ...
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

x = mfile.stage(1,:) * 1e-1;
y = mfile.stage(2,:) * 1e-1;
t_all = mfile.times;

good_indices = find(x~=0);

x = x(good_indices);
y = y(good_indices);
t = t_all(good_indices);

if options.center
    x = x - x(1);
    y = y - y(1);
end

if options.expand
    
    x = interp1(t, x, t_all, 'linear', 'extrap');
    y = interp1(t, y, t_all, 'linear', 'extrap');
    t = t_all;
    
end

[t, offset] = get_referenced_time(t);