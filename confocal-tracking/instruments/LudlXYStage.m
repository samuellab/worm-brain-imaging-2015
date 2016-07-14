%% LUDL XY Stage Controller (MAC 5000)

classdef (ConstructOnLoad = true) LudlXYStage < hgsetget
    %LudlXYStage Interface to Ludl MAC 5000 Controller for XY stage control
    
    properties
        SerialObj;
        Position;
        Velocity;
        MaxVelocity = 10000; 
    end
    
    
    methods
        
        % constructor
        function obj = LudlXYStage(port)
            obj.SerialObj = serial(port, ...
                                   'BaudRate', 9600, ...
                                   'Terminator', {'LF' 'CR'});
            fopen(obj.SerialObj);
        end
        
        function position = get.Position(obj)
            fprintf(obj.SerialObj, 'where xy');
            reply = fscanf(obj.SerialObj); % example: ':A -703 46335'
            C = strsplit(reply);
            
            switch C{1}(1:2)
                case ':A'
                    position = [str2num(C{2}) str2num(C{3})];
                otherwise
                    warning(...
                        ['Unable to get position from stage. Returned ' ...
                         'string: ' reply]);
            end
        end
        
        function obj = set.Position(obj, val)
            
            command = sprintf('vmove x=%d y=%d', val(1), val(2));
            fprintf(obj.SerialObj, command);
            reply = fscanf(obj.SerialObj);
            C = strsplit(reply);
            
            switch C{1}(1:2)
                case ':N'
                    warning(['Unable to set stage position. Returned ' ...
                             'string: ' reply]);
            end
            
        end
        
        function obj = set.Velocity(obj, val)
            if norm(val) > obj.MaxVelocity
                warning(['Desired speed exceeds software limit.  No '...
                         'action taken.']);
                return;
            end
                
            command = sprintf('spin x=%d y=%d', val(1), val(2));
            fprintf(obj.SerialObj, command);
            reply = fscanf(obj.SerialObj);
            C = strsplit(reply);
            
            switch C{1}(1:2)
                case ':N'
                    warning(['Unable to set stage velocity. Returned ' ...
                             'string: ' reply]);
            end
            
            obj.Velocity = val;
        end
        
        % destructor
        function delete(obj)
            fclose(obj.SerialObj);
        end
        
    end
    
end

