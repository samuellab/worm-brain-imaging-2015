function RGB = RGB_from_HSV(HSV)
% RGB = RGB_FROM_HSV(HSV)
%
%   Convert HSV color to RGB. Both are be 1D arrays. Domains:
%       H: [0, 360)
%       S: [0, 1]
%       V: [0, 1]
%   
%       R: [0, 1]
%       G: [0, 1]
%       B: [0, 1]

H = HSV(1);
S = HSV(2);
V = HSV(3);

H = mod(H, 360);

C = V * S;
X = C * (1-abs(mod(H/60, 2) - 1));
m = V - C;

if H < 60
    RGB0 = [C, X, 0];
elseif H < 120
    RGB0 = [X, C, 0];
elseif H < 180
    RGB0 = [0, C, X];
elseif H < 240
    RGB0 = [0, X, C];
elseif H < 300
    RGB0 = [X, 0, C];
elseif H < 360
    RGB0 = [C, 0, X];
end

RGB = RGB0 + m;