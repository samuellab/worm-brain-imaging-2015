function RGB = random_color(varargin)
% RGB = RANDOM_COLOR()
%
%   Returns a color with a random hue, but saturation and value set to 1.
%
% RGB = RANDOM_COLOR('seed', seed)
%
%   Specify a seed to generate a fixed color. The seed can be a random
%   number between 0 and 1 (in which case it is interpreted as the hue), an
%   integer (in which case it is divided by intmax(class(seed))), or a
%   string (in which case it is hashed onto a hue).
%
% RGB = RANDOM_COLOR('saturation', 0.5, 'value', 0.8)
%
%   Specify the saturation or value of the output.
%
% RGB = RANDOM_COLOR('class', 'uint8')
%
%   Returns an array of uint8s instead of doubles.

default_options = struct(...
    'seed', rand(), ...
    'saturation', 1, ...
    'value', 1, ...
    'class', 'double' ...
);

input_options = varargin2struct(varargin{:}); 
options = mergestruct(default_options, input_options);

x = options.seed;

if isa(x, 'float')
    
    H = mod(x, 1) * 360;
    
elseif isa(x, 'integer')
    
    H = x/intmax(class(x));
    
elseif isa(x, 'char')
    
    H = mod(sum_all(cast(x, 'uint8')), 256)* 360/256;
    
end

RGB = RGB_from_HSV([H, options.saturation, options.value]);

switch options.class
    
    case 'double'
        
        RGB = RGB;
        
    case 'uint8'
        
        RGB = uint8(RGB * 2^8);
        
    case 'uint16'
        
        RGB = uint16(RGB * 2^16);
        
end
        