function T = compose_transforms(varargin)
% T = COMPOSE_TFORMS(T1, T2, ...)
%
%   Returns an affine2d object representing the transform obtained by
%   applying T1, then T2, then T3, etc.
%
%   T = T3 * T2 * T1

T = eye(3);

for i = 1:nargin
    
    T = T * varargin{i}.T;
    
end

T = affine2d(T);