%% Logging interface.
%
% This logger stores all image (and auxilliary) data in memory, and writes
% to disk only after logging is complete. This guarentees smooth operation,
% but also introduces dead time after acquisition during which no recording
% can take place.


classdef (ConstructOnLoad = true) MemoryLogger < hgsetget
    
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
        %     .myVariable1 <- user supplied property to be logged
        %       .Data  <- D x T array of measured values
        %       .Function <- 0-argument function that produces the data
        %       .SamplePeriod <- How often to measure the property, in
        %                        camera group frames
        %
        % Properties should be added using the 'add_aux_data()' method.
        Aux;
                
    end
    
    properties (SetAccess = private)
        
        CamListener;
        
    end
    
    methods
        
        function obj = MemoryLogger(cam_obj)
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
            
            H = obj.Cam.AOIHeight;
            W = obj.Cam.AOIWidth;
            D = obj.Cam.ImageGroupSize;

            % Preallocate 15 GB for the data in memory.
            n_total = round(15e9 ... 15 GB
                            / obj.Cam.ImageSizeBytes ... Bytes per image
                            / D); % images per volume
            obj.Images = zeros([H, W, D, n_total], ...
                               'uint16');
        end
        
        function obj = start(obj)
            
            obj.CamListener.Enabled = true;
            
        end
        
        function obj = finish(obj)
            
            obj.CamListener.Enabled = false;
            ix = {':',':',':',1:obj.Idx};
            
            filename = fullfile(obj.Directory, obj.Filename);
            
            f = fieldnames(obj.Aux);
            auxdata = struct();
            for i = 1:length(f)
                auxdata.(f{i}) = obj.Aux.(f{i}).Data;
            end
            
            save(filename, '-struct', 'auxdata', '-v7.3');
            
            % Matlab insists on using compression, so we will save the
            % image using Matlab's high-level HDF5 interface.
            h5create(filename, '/images', size(obj.Images(ix{:})), ...
                'DataType', class(obj.Images));
            h5write(filename, '/images', obj.Images(ix{:}));
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
            
            obj.Images(:,:,:,idx) = vol;
            
            % Get and store all the auxilliary data
            f = fields(obj.Aux);
            for i = 1:length(f)
                if ~mod(i, obj.Aux.(f{i}).SamplePeriod)
                    obj.Aux.(f{i}).Data(:,idx) = ...
                        obj.Aux.(f{i}).Function();
                end
            end
            
        end
    end
    
end