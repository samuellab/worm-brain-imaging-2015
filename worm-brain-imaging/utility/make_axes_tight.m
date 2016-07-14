function make_axes_tight(axis_handle)
% make_axes_tight(axis_handle)
%
%   Makes the specified axis fit tightly in a figure, and removes all
%   axes/labels.

if nargin == 0
    axis_handle = gca;
end

set(axis_handle, ...
    'YTickLabel', [], ...
    'XTickLabel', [], ...
    'Visible', 'off', ...
    'Position', [0 0 1 1]);