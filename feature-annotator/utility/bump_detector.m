function h = bump_detector(s1, s2, S)
% h = bump_detector(s1, s2, S)
%
%   Returns a zero-sum filter that looks for a bump of width s1 on a
%   uniform background that extends a width of s2 around the bump.
%   The size of the returned output is S (default s2);

if length(s1) == 1
    s1(2) = [s1, s1];
end

if nargin < 2
    s2 = 3 * s1;
end

if length(s2) == 1
    s2 = [s2, s2];
end

if nargin < 3
    S = s2;
end

if length(S) == 1
    S = [S, S];
end

N = length(S); % should be 2 or 3


switch N
    case 2
        [Y, X] = ndgrid(1:S(1), 1:S(2));
        mu = (S+1)/2;
        
        h1 = (1/sqrt(2*pi*s1(1)^2) * exp(-(Y-mu(1)).^2/(2*s1(1)^2))) .* ...
             (1/sqrt(2*pi*s1(2)^2) * exp(-(X-mu(2)).^2/(2*s1(2)^2)));
        h2 = (1/sqrt(2*pi*s2(1)^2) * exp(-(Y-mu(1)).^2/(2*s2(1)^2))) .* ...
             (1/sqrt(2*pi*s2(2)^2) * exp(-(X-mu(2)).^2/(2*s2(2)^2)));
         
        h = h1 - h2;
        h = h/h(round(mu(1)), round(mu(2)));
    case 3
        [Y, X, Z] = ndgrid(1:S(1), 1:S(2), 1:S(3));
        mu = (S+1)/2;
        
        h1 = (1/sqrt(2*pi*s1(1)^2) * exp(-(Y-mu(1)).^2/(2*s1(1)^2))) .* ...
             (1/sqrt(2*pi*s1(2)^2) * exp(-(X-mu(2)).^2/(2*s1(2)^2))) .* ...
             (1/sqrt(2*pi*s1(3)^2) * exp(-(Z-mu(3)).^2/(2*s1(3)^2)));
        h2 = (1/sqrt(2*pi*s2(1)^2) * exp(-(Y-mu(1)).^2/(2*s2(1)^2))) .* ...
             (1/sqrt(2*pi*s2(2)^2) * exp(-(X-mu(2)).^2/(2*s2(2)^2))) .* ...
             (1/sqrt(2*pi*s2(3)^2) * exp(-(Z-mu(3)).^2/(2*s2(3)^2)));
         
        h = h1 - h2;
        h = h/h(round(mu(1)), round(mu(2)), round(mu(3)));
end