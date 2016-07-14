function color = set_color_class(color, new_type)
% color = SET_COLOR_CLASS(color, new_type)
%
%   Changes an RGB color value to either a double in [0, 1], a uint8 in
%   [0, 255] or a uint16 in [0, 2^16 - 1].


current_type = element_class(color);

if any(strcmp(current_type, {'double', 'float', 'single'}))
    current_max = 1;
else
    current_max = intmax(current_type);
end

if strcmp(new_type, 'double')
    color = double(color/current_max);
elseif strcmp(new_type, 'uint8')
    color = uint8(double(color)/current_max * 2^8);
elseif strcmp(new_type, 'uint16')
    color = uint16(double(color)/current_max * 2^16);
end

