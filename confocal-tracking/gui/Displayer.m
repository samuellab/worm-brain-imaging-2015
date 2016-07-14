%% Display interface

classdef (ConstructOnLoad = true) Displayer < hgsetget
    
    properties
        
        % Camera object generating data to be displayed.  It should provide
        % the following properties:
        %   GroupBuffer
        %   GroupBufferIndex
        % and it should broadcast the following events when plotting is to
        % take place:
        %   GroupComplete
        Cam;
        
        % Array of axes which will receive new CData every frame.
        Axes = [];
        
        % Cell array of function handles. Each function should take a
        % volume of data and return a 2D array of data suitable as the
        % CData field of the corresponding axis handle object.
        ImageFunctions = {};
        
        % Update period (in units of GroupComplete events).
        UpdatePeriod = 1;
                
    end
    
    properties (SetAccess = private)
        
        CamListener;
        
        % Counts the number of GroupComplete events to allow periodic
        % updating of displays.
        Counter = 0;
        
    end
    
    
    methods
        
        function obj = Displayer(cam_obj)
        % Constructor, requires a camera object
        
            obj.Cam = cam_obj;
            
            obj.CamListener = obj.Cam.addlistener('GroupComplete', ...
                @obj.cam_callback);
            
        end
        
        function delete(obj)
            delete(obj.CamListener);
        end
        
        function obj = add_display(obj, haxis, fn)
        % Add a new display
            
            idx = length(obj.Axes) + 1;
            
            obj.Axes(idx) = haxis;
            obj.ImageFunctions{idx} = fn;
            
            obj.flush_axes();
            
        end
        
        function obj = flush_axes(obj)
        % Remove deleted displays
        
            remove = [];
            for i = 1:length(obj.Axes)
                if ~ishandle(obj.Axes(i))
                    remove = [remove i];
                end
            end
            
            obj.Axes(remove) = [];
            obj.ImageFunctions(remove) = [];
        end
        
    end
    
    methods (Access = private)
        
        function cam_callback(obj, src, evt)
            if ~mod(obj.Counter, obj.UpdatePeriod)
                vol = obj.Cam.get_buffer();
                for i = 1:length(obj.Axes)
                        im = obj.ImageFunctions{i}(vol);
                        set(obj.Axes(i), 'CData', im);
                end
            end
            
            obj.Counter = obj.Counter + 1;
        end
    end
    
end