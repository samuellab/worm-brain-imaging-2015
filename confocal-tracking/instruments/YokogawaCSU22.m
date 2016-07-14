%% Interface to Yokogawa CSU22 Spinning Disc

classdef (ConstructOnLoad = true) YokogawaCSU22 < hgsetget
    %Interface to Yokogawa CSU22 Spinning Disc
   
    properties
        SerialObj;
        FilterWheel;
        Speed; %rpm
        Shutter; %bool
    end
    
    methods
        
        % constructor
        function obj = YokogawaCSU22(port)
            obj.SerialObj = serial(port, ...
                                   'BaudRate', 9600, ...
                                   'Terminator', 'CR', ...
                                   'Timeout', 6);
            fopen(obj.SerialObj);
            obj.Shutter = 1;
            obj.Speed = 5000; 
        end
        
        % destructor
        function delete(obj)
            obj.Shutter = 0;
            fclose(obj.SerialObj);
        end
        
        function obj = set.FilterWheel(obj, val)
            if ~ismember(val, [1 2 3])
                warning('Illegal filter position.  No action taken.');
                return;
            end
            
            fprintf(obj.SerialObj, sprintf('edb%d%d%d', val, val, val));
            
            while ~obj.SerialObj.BytesAvailable
                pause(0.1);
            end
            reply = fscanf(obj.SerialObj);
            
            switch reply(1:2)
                case ':A'
                    obj.FilterWheel = val;
                case ':N'
                    warning('Set filter wheel failed.');
            end
        end
        
        function obj = set.Shutter(obj, val)
            switch val
                case {'open', 1, true}
                    val = 'open';
                    fprintf(obj.SerialObj, 'sh0');
                case {'closed', 0, false}
                    val = 'closed';
                    fprintf(obj.SerialObj, 'sh1');
                otherwise
                    warning('Illegal shutter setting.  No action taken.');
            end
            
            while ~obj.SerialObj.BytesAvailable
                pause(0.1);
            end
            reply = fscanf(obj.SerialObj);
            switch reply(1:2)
                case ':A'
                    obj.Shutter = val;
                case ':N'
                    warning('Set shutter failed.');
            end
        end
        
        function obj = set.Speed(obj, val)
            if val >= 1500 && val <= 5000
                fprintf(obj.SerialObj, sprintf('ms%d', val));
            else
                warning('Illegal disc speed.  No action taken.');
            end
            
            while ~obj.SerialObj.BytesAvailable
                pause(0.1);
            end
            reply = fscanf(obj.SerialObj);
            switch reply(1:2)
                case ':A'
                    obj.Speed = val;
                case ':N'
                    warning('Set disc speed failed.');
            end
        end
        
    end
    
end

