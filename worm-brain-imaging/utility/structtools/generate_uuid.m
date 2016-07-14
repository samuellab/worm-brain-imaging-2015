function uuid = generate_uuid(n)
% uuid = GENERATE_UUID()
%
%   Generates a random canonical UUID using the jvm. (UUIDv4)
%   Version 4 UUIDs have the form xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx
%   where x is any hexadecimal digit and y is one of 8, 9, A, or B 
%   (e.g., f47ac10b-58cc-4372-a567-0e02b2c3d479).
%
% uuid = GENERATE_UUID(n)
%
%   Generates n hexadecimal digits using MATLAB's randsample function, and
%   returns them as a 1 x n character array (37fd3a)
%
%   This method does not rely on the JVM being present.


switch nargin
    
    case 0
        uuid = char(java.util.UUID.randomUUID);
        
    case 1
        x = dec2hex(randsample(16, n, true) - 1);
        uuid = lower(x');
        
end