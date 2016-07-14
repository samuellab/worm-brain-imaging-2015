function s = varargin_to_struct(varargin)
% s = VARARGIN_TO_STRUCT('key1', value1, 'key2', value2, ...)
%
%   Converts a set of key value pairs to a structure with the specified
%   keys and values.

s = struct();

i = 1;
while i<=length(varargin)
    
    if isstruct(varargin{i})
        
        s = structtools.merge_struct(s, varargin{i});
        i = i + 1;
        
    elseif ischar(varargin{i})
        
        s.(varargin{i}) = varargin{i+1};
        i = i + 2;
        
    end
    
end