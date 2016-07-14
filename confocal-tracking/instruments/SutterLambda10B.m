%% Sutter Lambda 10-B Filter wheel
%
% This provides an interface to the Sutter Lambda Filter Wheel on the
% upright spinning disc microscope.
%
% From the operation manual:
% Filter commands are encoded into specific bit groups of the command byte.
% As discussed earlier in this chapter, and as shown in the table titled 
% “Filter Command Structure”, there are actually three commands stored at 
% the same time in the command byte. The filter wheel selector is stored in
% Bit 7 (the most significant bit (MSB)) of the command byte, allowing 2 
% values (0 and 1). The filter wheel speed is stored in the next lower 
% three bits (Bits 6, 5, and 4), allowing 8 different values (0 through 7).
% In addition, the filter selector is stored in the next lower four bits 
% (least significant nibble, Bits 3, 2, 1, and 0). Of the 16 possible 
% values that can be stored in the least significant nibble, only the first
% 10 (0 through 9) are used for the filter selector. Any value above 9 will
% invalidate the entire command byte as a “filter command”, making the value
% stored in the byte as whole as either a shutter, special, or undefined 
% command.
%
% our filters:
%     0: 607/36
%     1: 488longpass
%     2: full
%     3: full
%     4: full
%     5: empty
%     6: 540/15
%     7: full
%     8: 479/40
%     9: 525/40

classdef (ConstructOnLoad = true) SutterLambda10B < hgsetget
    
    properties
        Filters = { ...
                    '607/36' ...      % 0 -> val=1
                    '488longpass' ... % 1
                    'full' ...        % 2
                    'full' ...        % 3
                    'full' ...        % 4
                    'empty' ...       % 5
                    '540/15' ...      % 6
                    'full' ...        % 7
                    '479/40' ...      % 8
                    '525/40' ...      % 9 -> val=10
                  };
        SerialObj;
        ActiveFilter;
    end
    
    properties (SetAccess = private)
        Speed = 6; % taken from our NIS Elements Configuration
    end
    
    methods
        
        % constructor
        function obj = SutterLambda10B(port)
            obj.SerialObj = serial(port, ...
                                   'BaudRate', 9600,...
                                   'Terminator', 'CR');
            fopen(obj.SerialObj);
        end
        
        % set filter
        function obj = set.ActiveFilter(obj,val)
            if ischar(val)
                val = find(strcmp(val, obj.Filters),1);
                if isempty(val)
                    error(...
                      'Filter not configured.  Try calling with a number');
                end
            end
            
            byte_to_send = uint8(0*2^7 + obj.Speed*2^4 + val-1);
            
            fwrite(obj.SerialObj, byte_to_send);
            ret = fread(obj.SerialObj, 2);
            
            if ret(1) ~= 95+val
                error('Unable to set filter wheel');
            end
            
            obj.ActiveFilter = obj.Filters{val};
            
        end
        
        % destructor
        function delete(obj)
            fclose(obj.SerialObj);
        end
        
    end
    
end