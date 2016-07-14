%% Logging interface.
%
% This logger stores all image (and auxilliary) data. 


classdef (ConstructOnLoad = true) Logger < hgsetget
    
    properties
        
        % Camera object generating data to be logged.  It should provide
        % the following properties:
        %   GroupBuffer
        %   GroupBufferIndex
        % and it should broadcast the following events when logging is to
        % take place:
        %   GroupComplete
        Cam;
        
        % Images
        Images = [];
        
        % Pre-save processing function. This should take a volume from the
        % camera's buffer group and return an array to be saved.
        Processor = [];
        
        % Index of current time
        Idx = 1;

        % Directory for saving data
        Directory;
        
        % Filename
        Filename;
        
        % Extra data to be logged.  This has the following (dynamic)
        % structure:
        %   Aux
        %     .myVariable1 : user supplied property to be logged
        %       .Data  : D x T array of measured values
        %       .Function : 0-argument function that produces the data
        %       .SamplePeriod : How often to measure the property, in
        %                        camera group frames
        %
        % Properties should be added using the 'add_aux_data()' method.
        Aux;
                
    end
    
    properties (SetAccess = private)
        
        CamListener;
        
        % Counts the number of GroupComplete events to allow periodic
        % updating of displays.
        Counter = 0;
        
    end
    
    methods
        
        function obj = Logger(cam_obj)
        % Constructor, requires a camera object
        
            obj.Cam = cam_obj;
            
            obj.CamListener = obj.Cam.addlistener('GroupComplete', ...
                @obj.cam_callback);
            
            obj.CamListener.Enabled = false;
            
            % By default, record the time at which each frame was
            % collected.
            obj.add_aux_data('times', @() now);

        end
        
        function delete(obj)
        % Destructor
            delete(obj.CamListener);
        end
        
        function obj = add_aux_data(obj, var_name, fn, period)
        % Adds data to be logged with name 'var_name', accessor function
        % 'fn', and measurement interval 'period' (units: camera groups)
        
            if nargin == 3
                period = 1;
            end
            
            obj.Aux.(var_name).Data = [];
            
            obj.Aux.(var_name).Function = fn;
            
            obj.Aux.(var_name).SamplePeriod = period;
        
        end
        
        function obj = initialize(obj)
            obj.Idx = 0;
            
            % Empty the stored auxilliary data
            f = fields(obj.Aux);
            for i = 1:length(f)
                obj.Aux.(f{i}).Data = [];
            end
            
            % Get image size
            H = obj.Cam.AOIHeight;
            W = obj.Cam.AOIWidth;
            D = obj.Cam.ImageGroupSize;
            
            % Create a file for saving using a dummy variable
            if ~exist(obj.Directory, 'dir')
                mkdir(obj.Directory);
            end
            filename = fullfile(obj.Directory, obj.Filename);
            initialize_matfile(filename);
            
            % Create an unbounded container for images.
            h5create(filename, '/images', [W H D Inf], ...
                'DataType', 'uint16', ...
                'ChunkSize', [W H D 1]);
        end
        
        function obj = start(obj)
            
            obj.CamListener.Enabled = true;
            
        end
        
        function obj = finish(obj)
            
            obj.CamListener.Enabled = false;
            
            filename = fullfile(obj.Directory, obj.Filename);
            
            f = fieldnames(obj.Aux);
            auxdata = struct();
            for i = 1:length(f)
                auxdata.(f{i}) = obj.Aux.(f{i}).Data;
            end
            
            save(filename, '-struct', 'auxdata', '-append');
            
            obj.Filename = increment_filename(obj.Filename);
            obj.initialize();
            
        end
        

    end
    
    methods (Access = private)
        
        function cam_callback(obj, src, evt)
            
            idx = obj.Idx+1;
            obj.Idx = idx;
            
            % Get and store the image
            vol = obj.Cam.get_buffer();
            
            if ~isempty(obj.Processor)
                vol = obj.Processor(vol);
            end
            
            filename = fullfile(obj.Directory, obj.Filename);
            h5write(filename, '/images', vol, [1 1 1 idx], [size(vol) 1]);
            
            % Get and store all the auxilliary data
            f = fields(obj.Aux);
            for i = 1:length(f)
                if ~mod(obj.Counter, obj.Aux.(f{i}).SamplePeriod)
                    obj.Aux.(f{i}).Data(:,idx) = ...
                        obj.Aux.(f{i}).Function();
                end
            end
            
            obj.Counter = obj.Counter + 1;
            
        end
    end
    
end