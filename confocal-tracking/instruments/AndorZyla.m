%% Andor Zyla Camera
%
% This provides a limited interface to Andor CMOS cameras.  It mostly
% wraps the downloadable SDK3 provided by Andor.  This should work for
% any camera that uses Andor's SDK3 (MATLAB interface).

classdef (ConstructOnLoad = true) AndorZyla < hgsetget
    
    properties 
        
        %
        % Andor SDK3 Properties
        %
        
        % Sets the number of images that should be summed to obtain each
        % image in a sequence
        AccumulateCount;
        
        % Configures the height of the sensor area of interest in
        % super-pixels
        AOIHeight;
        
        % Configures the width of the senor area of interest in
        % super-pixels
        AOIWidth;
        
        % Configures the left hand coordinate of the sensor area of
        % interest in sensor pixels
        AOILeft;
        
        % Configures the top coordinate of the sensor coordinate in pixels
        AOITop;
        
        % Sets up the pixel binning on the camera.  Options:
        %   '1x1'
        %   '2x2'
        %   '4x4'
        %   '8x8'
        AOIBinning;
        
        % The size of one row in the image in bytes. Extra padding 
        % bytes may be added to the end of each line after pixel data to 
        % comply with line size granularity restrictions imposed by the 
        % underlying hardware interface.
        AOIStride;
        
        % Configures whether the camera will acquire a fixed length
        % sequence or a continuous sequence.  In 'Fixed' mode the camera 
        % will acquire 'FrameCount' number of images and then stop
        % automatically.  In 'Continuous' mode the camera will continue to
        % acquire images indefinitely until the 'AcquisitionStop' command
        % is issued.  Options:
        %   'Fixed'
        %   'Continuous'
        CycleMode;
        
        % Configures which on-sensor electronic shuttering mode is used.
        % For pulsed or fast moving images, 'Global' shuttering is
        % recommended.  For the highest frame rates and best noise
        % performance, 'Rolling' is recommended.
        % Options:
        %   'Rolling'
        %   'Global'
        ElectronicShutteringMode;
        
        % The requested exposure time in seconds.  Note: In some modes the
        % exposure time can also be modified while the acquisition is still
        % running.
        ExposureTime;
        
        % Configures the speed of the fan in the camera.
        % Options:
        %   'Off'
        %   'On'
        FanSpeed;
        
        % Configures the number of images to acquire in the sequence. 
        % When this feature is unavailable then the camera does not 
        % currently support fixed length series, therefore you must 
        % explicitly abort the acquisition once you have acquired the 
        % amount of frames required.
        FrameCount;
        
        % Configures the frame rate in Hz at which each image is 
        % acquired during any acquisition sequence. This is the rate at 
        % which frames are acquired by the camera which may be 
        % different from the rate at which frames are delivered to the 
        % user. For example when AccumulateCount has a value other 
        % than 1, the apparent frame rate will decrease proportionally.
        FrameRate;
        
        % Configures the format of data stream. 
        % Neo, Zyla and SimCam Options: 
        %   'Mono12'
        %   'Mono12Packed'
        %   'Mono16'
        %   'Mono32'
        PixelEncoding;
        
        % Configures the state of the sensor cooling. Cooling is 
        % disabled by default at power up and must be enabled for the 
        % camera to achieve its target temperature. The actual target 
        % temperature can be set with the TemperatureControl feature 
        % where available for example on the Neo camera.
        SensorCooling;
        
        % Wrapper Feature to simplify selection of the sensitivity and 
        % dynamic range options. This feature should be used as a 
        % replacement for the PreAmpGainControl feature as some of 
        % the options in the PreAmpGainControl feature are not 
        % supported on all cameras. Supported Bit Depth will be 
        % dependent on the camera. 
        % Options:
        %   '11-bit (high well capacity)'
        %   '12-bit (high well capacity)'
        %   '11-bit (low noise)'
        %   '12-bit (low noise)'
        %   '16-bit (low noise & high well capacity)'
        SimplePreAmpGainControl;
        
        % Allows the user to configure the camera trigger mode at a 
        % high level. If the trigger mode is set to Advanced then the 
        % Trigger Selector and Trigger Source feature must also be 
        % set. 
        % Neo, Zyla and SimCam Options: 
        %   'Internal'
        %   'Software'
        % 	'External'
        % 	'External Start'
        %   'External Exposure'
        TriggerMode;
        
        % Vertically centres the AOI in the frame. With this enabled, 
        % AOITop will be disabled.
        VerticallyCenterAOI;
        
        %
        % Additional properties
        %
        
        % Number of images to acquire in 1 group (typically the number of
        % vertical slices times the number of colors per slice)
        ImageGroupSize = 1;
        
        % Number of groups to store in memory (circular buffer).
        GroupBufferSize = 10;
        
        % The actual buffer.  The i'th group is cam.GroupBuffer(:,:,:,i)
        GroupBuffer;

        % If images are being added to groups in a Rastered fashion, the
        % even-numbered groups must be filled in an inverted order for Z.
        Raster = false;
        
        % Number of frames to throw out at the beginning of each group.
        % This was added to allow the piezo to settle when the camera is
        % running continuously.
        DeadFrames = 0;

    end
    
    properties (SetAccess = private)
        
        % Returns whether or not the camera is acquiring (SDK call). 
        CameraAcquiring;
        
        % Indicates whether a run is currently in progress.
        SoftwareAcquiring;
        
        % Returns the camera model.
        CameraModel;
        
        % Returns the buffer size in bytes required to store the data for 
        % one frame. This will be affected by the Area of Interest size, 
        % binning and whether metadata is appended to the data 
        % stream.
        ImageSizeBytes;
        
        % Returns the height of each pixel in micrometers.
        PixelHeight;
        
        % Returns the width of each pixel in micrometers.
        PixelWidth;
        
        % Returns the height of the sensor in pixels. 
        SensorHeight;
        
        % Returns the width of the sensor in pixels. 
        SensorWidth;
        
        % Read the current temperature of the sensor. 
        SensorTemperature;
        
        % Reports the current value of the camera’s internal timestamp 
        % clock. This same clock is used to timestamp images as they 
        % are acquired when the MetadataTimestamp feature is 
        % enabled. The clock is reset to zero when the camera is 
        % powered on and then runs continuously at the frequency 
        % indicated by the TimestampClockFrequency feature. The 
        % clock is 64-bits wide.
        TimestampClock;
        
        % Reports the frequency of the camera’s internal timestamp 
        % clock in Hz
        TimestampClockFrequency;
        
        % The handle to the camera provided by Andor's SDK
        Hndl;
        
        % Index to most recently updated stack in obj.GroupBuffer
        GroupBufferIndex;
        
        % Handle for group complete listener.
        GroupCompleteListener;
        
    end
    
    events
        
        GroupComplete;
        
    end
    
    methods
        function obj = AndorZyla(varargin)
        % Constructor. Usage:
        %   cam = AndorZyla();
        
            if nargin > 0
                if strcmp(varargin{1},'null')
                    return;
                else
                    camera_number = varargin{1};
                end
            else
                camera_number = 0;
            end
            
            disp('Opening SDK');
            [rc] = AT_InitialiseLibrary();
            AT_CheckError(rc);
            
            disp('Initializing Camera');
            [rc, hndl] = AT_Open(camera_number);
            AT_CheckError(rc);
            obj.Hndl = hndl;
            
            obj.SensorCooling = 1;
            disp(['Turning on Cooler: current temperature is ' ...
                    num2str(obj.SensorTemperature)]);

        end
  
        
        function delete(obj)
        % destructor
            % Turn off cooling.
            obj.SensorCooling = 0;
            
            % Close camera.
            [rc] = AT_Close(obj.Hndl);
            AT_CheckWarning(rc);
            
            % Unload SDK.
            [rc] = AT_FinaliseLibrary();
            AT_CheckWarning(rc);
            
            disp('Camera shutdown complete.');
        end
        
        function prepare_fixed(obj, n)
        % Prepare to acquire a fixed number of frames
        
            if nargin == 1
                n = obj.ImageGroupSize;
            end
            
            obj.CycleMode = 'Fixed';
            obj.TriggerMode = 'Internal';
            obj.SimplePreAmpGainControl = ...
                    '12-bit (low noise)';
            obj.FrameCount = n;
            
            % Initialize the group buffer.            
            H = obj.AOIHeight;
            W = obj.AOIWidth;
            Z = obj.ImageGroupSize;
            obj.GroupBuffer = zeros(W, H, Z, obj.GroupBufferSize, ...
                                    'uint16');
            obj.GroupBufferIndex = 0;
            
            for i = 1:10
                obj.queueBuffer();
            end
        end
        
        function images = snap(obj, n)
        % obj.snap() 
        %   Take a single image.
        %
        % obj.snap(6)
        %   Take 6 images.
            
            if nargin==1
                n = 1;
            end
            
            obj.prepare_fixed(n);
            
            % Exposure time
            T = obj.ExposureTime;
            
            obj.startAcquisition;
            
            images = zeros(obj.AOIWidth, obj.AOIHeight, n, 'uint16');
            for i =1:n
                array = obj.waitBuffer(1000*T + 500);
                obj.queueBuffer();
                image = obj.convertMono12PackedToMatrix(array, ...
                                                  obj.AOIHeight, ...
                                                  obj.AOIWidth, ...
                                                  obj.AOIStride);
                images(:,:,i) = image;
            end
                                           
            obj.stopAcquisition;
            
            % The camera returns data with X, Y instead of row, column.
            % This ensures the output has a height of AOIHeight and a width
            % of AOIWidth.
            %images = flip(permute(images, [2,1,3]), 2);
            %images = permute(images, [2, 1, 3]);
            
            
            obj.flushBuffer;
        end
        
        function snap_group(obj)
        % Similar to snap, but does no preparation (call prepare_fixed()
        % first) and returns nothing.  The acquired stack is added to the
        % group buffer, and a 'GroupComplete' event is fired.
        
            % Collect the relevant run parameters to avoid calls to object
            % getters.
            D = obj.DeadFrames;
            Z = obj.ImageGroupSize;
            
            H = obj.AOIHeight;
            W = obj.AOIWidth;
            S = obj.AOIStride;
            
            % Timeout to wait for frame buffer on camera to get filled, in
            % milliseconds.
            wait_time = 1000 / obj.FrameRate + 50;

            % Next buffer spot to fill:
            g = mod(obj.GroupBufferIndex + 1, ...
                    obj.GroupBufferSize) + 1;
            
            % Initialize camera buffer    
            for i = 1:10
                obj.queueBuffer();
            end
            
            obj.startAcquisition;
                    
            % First grab the dead frames and destroy them.
            for z = 1:D
                obj.waitBuffer(wait_time);
                obj.queueBuffer();
            end
                    
            % Next fill up the current group
            for z = 1:Z
                array = obj.waitBuffer(wait_time);

                image = obj.convertMono12PackedToMatrix(array, ...
                                          H, W, S);

                obj.GroupBuffer(:,:,z,g) = image; 
                obj.queueBuffer();

            end
            
            obj.stopAcquisition();
            obj.flushBuffer();
                    
            if obj.SoftwareAcquiring
                notify(obj, 'GroupComplete');
            end

            drawnow();
                
        end

        function prepare_continuous(obj)
        % Prepare for continuous acquisition
        
            obj.CycleMode = 'Continuous';
            obj.TriggerMode = 'Internal';
            obj.SimplePreAmpGainControl = '12-bit (low noise)';
            
            % Collect the relevant run parameters to avoid calls to object
            % getters.
            Z = obj.ImageGroupSize;
            H = obj.AOIHeight;
            W = obj.AOIWidth;
            
            % Initialize the group buffer.
            obj.GroupBuffer = zeros(W, H, Z, obj.GroupBufferSize, ...
                                    'uint16');
            obj.GroupBufferIndex = obj.GroupBufferSize;
            
            % Initialize the cam buffer with 50 frames.  We'll add a frame
            % every time we take a frame, so there should always be 50
            % queued frames.
            obj.stopAcquisition();
            obj.flushBuffer();
            for i = 1:50
                obj.queueBuffer();
            end

        end
        
        function run_continuously(obj)
        % Runs continuously, filling the group buffer and emiting
        % GroupComplete events.
        
            
            % Collect the relevant run parameters to avoid calls to object
            % getters.
            D = obj.DeadFrames;
            Z = obj.ImageGroupSize;
            
            H = obj.AOIHeight;
            W = obj.AOIWidth;
            S = obj.AOIStride;

            raster = obj.Raster;
            
            % Timeout to wait for frame buffer on camera to get filled, in
            % milliseconds.
            wait_time = 1000 / obj.FrameRate + 50;


            obj.SoftwareAcquiring = true;
            
            obj.startAcquisition();
            
            groups_complete = 0;
            
            % Temporarily gain access to DAQ.
            global scope;
            
            while obj.SoftwareAcquiring
                for g = 1:obj.GroupBufferSize
                    
                    % First grab the dead frames and destroy them.
                    for z = 1:D
                        obj.waitBuffer(wait_time);
                        obj.queueBuffer();
                    end
                    
                    % Next fill up the current group
                    z_indices = 1:Z;
                    if raster && ~mod(g,2) % flip the even groups
                        z_indices = fliplr(z_indices);
                    end
                    for z = z_indices
                        array = obj.waitBuffer(wait_time);
                        
                        image = obj.convertMono12PackedToMatrix(array, ...
                                                  H, W, S);
                        
                        obj.GroupBuffer(:,:,z,g) = image; 
                        obj.queueBuffer();
                        
                    end
                    
                    groups_complete = groups_complete + 1;
                    
                    scans_queued = scope.DAQ.DAQSession.ScansQueued;
                    if scope.DAQ.DAQSession.ScansQueued< 100 / (1+raster)
                        scope.DAQ.queueData();
                        scope.DAQ.queueData();
                        warning('Manually queueing DAQ');
                    end
                    
                    disp([num2str(groups_complete) ...
                          ' groups complete and ' ...
                          num2str(scope.DAQ.DAQSession.ScansQueued) ...
                          ' scans queued.']);
                    
                    obj.GroupBufferIndex = g;
                    
                    if obj.SoftwareAcquiring
                        notify(obj, 'GroupComplete');
                    end
                    
                    drawnow();
                end
            end
            
            obj.stopAcquisition();
            obj.flushBuffer();

        end
        
        function vol = get_buffer(obj)
        % return the most recent volume from the buffer.
            vol = obj.GroupBuffer(:,:,:,obj.GroupBufferIndex);
            %vol = permute(vol, [2 1 3]);
        end
       
        
        function stop_continuous(obj)
            disp('Stop signal received');
            obj.SoftwareAcquiring = false;
        end
        
        
        %
        % Wrapped SDK3 commands
        %
        
        function startAcquisition(obj)
        % start acquiring
            obj.command('AcquisitionStart');
        end
        
        function stopAcquisition(obj)
        % stop acquiring
            obj.command('AcquisitionStop');
        end
        
        function trigger(obj)
        % send software trigger
            obj.command('SoftwareTrigger');
        end
        
        function resetClock(obj)
        % reset the clock on the FPGA to 0
            obj.command('TimestampClockReset');
        end
        
        %
        % Wrapped SDK3 methods
        %
        
        function queueBuffer(obj)
        % request another frame
            [rc] = AT_QueueBuffer(obj.Hndl, obj.ImageSizeBytes);
            AT_CheckWarning(rc);
        end
        
        function buf = waitBuffer(obj, timeout)
        % wait for frame
            [rc, buf] = AT_WaitBuffer(obj.Hndl, timeout);
            AT_CheckWarning(rc);
            
            % Handle Timeout (error code 13)
            if rc == 13
                disp('Handling buffer timeout');
                obj.stopAcquisition();
                obj.flushBuffer();
                for i = 1:50
                    obj.queueBuffer();
                end
                obj.startAcquisition();
                
                [rc, buf] = AT_WaitBuffer(obj.Hndl, timeout);
                AT_CheckWarning(rc);
            end
        end
        
        function flushBuffer(obj)
        % flush the buffer.
            [rc] = AT_Flush(obj.Hndl);
            AT_CheckWarning(rc);
        end
       
        % 
        % All the setters and getters for property values.
        %

        % Gettable and settable:
        function obj = set.AccumulateCount(obj, val)
            obj.setIntegerProperty('AccumulateCount', val);
        end
        function val = get.AccumulateCount(obj)
            val = obj.getIntegerProperty('AccumulateCount');
        end
        
        function obj = set.AOIHeight(obj, val)
            obj.setIntegerProperty('AOIHeight', val);
        end
        function val = get.AOIHeight(obj)
            val = obj.getIntegerProperty('AOIHeight');
        end
        
        function obj = set.AOIWidth(obj, val)
            obj.setIntegerProperty('AOIWidth', val);
        end
        function val = get.AOIWidth(obj)
            val = obj.getIntegerProperty('AOIWidth');
        end

        function obj = set.AOILeft(obj, val)
            obj.setIntegerProperty('AOILeft', val);
        end
        function val = get.AOILeft(obj)
            val = obj.getIntegerProperty('AOILeft');
        end

        function obj = set.AOITop(obj, val)
            obj.setIntegerProperty('AOITop', val);
        end
        function val = get.AOITop(obj)
            val = obj.getIntegerProperty('AOITop');
        end
        
        function obj = set.AOIBinning(obj, val)
            obj.setEnumProperty('AOIBinning', val);
        end
        function val = get.AOIBinning(obj)
            val = obj.getEnumProperty('AOIBinning');
        end
        
        function obj = set.AOIStride(obj, val)
            obj.setIntegerProperty('AOIStride', val);
        end
        function val = get.AOIStride(obj)
            val = obj.getIntegerProperty('AOIStride');
        end
        
        function obj = set.CycleMode(obj, val)
            obj.setEnumProperty('CycleMode', val);
        end
        function val = get.CycleMode(obj)
            val = obj.getEnumProperty('CycleMode');
        end
        
        function obj = set.ElectronicShutteringMode(obj, val)
            obj.setEnumProperty('ElectronicShutteringMode', val);
        end
        function val = get.ElectronicShutteringMode(obj)
            val = obj.getEnumProperty('ElectronicShutteringMode');
        end
        
        function obj = set.ExposureTime(obj, val)
            obj.setFloatProperty('ExposureTime', val);
        end
        function val = get.ExposureTime(obj)
            val = obj.getFloatProperty('ExposureTime');
        end
        
        function obj = set.FanSpeed(obj, val)
            obj.setEnumProperty('FanSpeed', val);
        end
        function val = get.FanSpeed(obj)
            val = obj.getEnumProperty('FanSpeed');
        end
        
        function obj = set.FrameCount(obj, val)
            obj.setIntegerProperty('FrameCount', val);
        end
        function val = get.FrameCount(obj)
            val = obj.getIntegerProperty('FrameCount');
        end
        
        function obj = set.FrameRate(obj, val)
            obj.setFloatProperty('FrameRate', val);
        end
        function val = get.FrameRate(obj)
            val = obj.getFloatProperty('FrameRate');
        end
        
        function obj = set.PixelEncoding(obj, val)
            obj.setEnumProperty('PixelEncoding', val);
        end
        function val = get.PixelEncoding(obj)
            val = obj.getEnumProperty('PixelEncoding');
        end
        
        function obj = set.SensorCooling(obj, val)
            obj.setBoolProperty('SensorCooling', val);
        end
        function val = get.SensorCooling(obj)
            val = obj.getBoolProperty('SensorCooling');
        end
        
        function obj = set.SimplePreAmpGainControl(obj, val)
            obj.setEnumProperty('SimplePreAmpGainControl', val);
        end
        function val = get.SimplePreAmpGainControl(obj)
            val = obj.getEnumProperty('SimplePreAmpGainControl');
        end
        
        function obj = set.TriggerMode(obj, val)
            obj.setEnumProperty('TriggerMode', val);
        end
        function val = get.TriggerMode(obj)
            val = obj.getEnumProperty('TriggerMode');
        end
        
        function obj = set.VerticallyCenterAOI(obj, val)
            obj.setBoolProperty('VerticallyCenterAOI', val);
        end
        function val = get.VerticallyCenterAOI(obj)
            val = obj.getBoolProperty('VerticallyCenterAOI');
        end
        
        % Gettable-only properties:
        function val = get.CameraAcquiring(obj)
            val = obj.getBoolProperty('CameraAcquiring');
        end
        
        function val = get.CameraModel(obj)
            val = obj.getEnumProperty('CameraModel');
        end
        
        function val = get.ImageSizeBytes(obj)
            val = obj.getIntegerProperty('ImageSizeBytes');
        end
        
        function val = get.PixelHeight(obj)
            val = obj.getIntegerProperty('PixelHeight');
        end
        
        function val = get.PixelWidth(obj)
            val = obj.getIntegerProperty('PixelWidth');
        end
        
        function val = get.SensorHeight(obj)
            val = obj.getIntegerProperty('SensorHeight');
        end
        
        function val = get.SensorWidth(obj)
            val = obj.getIntegerProperty('SensorWidth');
        end
        
        function val = get.SensorTemperature(obj)
            val = obj.getFloatProperty('SensorTemperature');
        end
        
       function val = get.TimestampClock(obj)
            val = obj.getIntegerProperty('TimestampClock');
        end
        
        function val = get.TimestampClockFrequency(obj)
            val = obj.getIntegerProperty('TimestampClockFrequency');
        end
        
    end
    
    methods (Static)
        
        %
        % Wrapped SDK3 methods 
        %
        
        function out = convertMono16ToMatrix(in, height, width, stride)
            [rc, out] = AT_ConvertMono16ToMatrix(in,height,width,stride);
            AT_CheckWarning(rc);
        end
        
        function out = convertMono12PackedToMatrix(in, height, ...
                                                   width, stride)
            [rc, out] = AT_ConvertMono12PackedToMatrix(in, height, ...
                                                       width, stride);
            AT_CheckWarning(rc);
        end
        
        function out = convertMono12ToMatrix(in, height, ...
                                             width, stride)
            [rc, out] = AT_ConvertMono12ToMatrix(in, height, ...
                                                 width, stride);
            AT_CheckWarning(rc);
        end
        
    end
    
    methods (Access = private)
        %
        % Easier interface to use every get/set property in the SDK, though
        % still a bit clunky (you have to know the type of the property)
        %

        % Integer properties
        function obj = setIntegerProperty(obj, feature_string, val)
            [rc] = AT_SetInt(obj.Hndl, feature_string, val);
            AT_CheckError(rc);
        end
        
        function new_val = getIntegerProperty(obj, feature_string)
            [rc, new_val] = AT_GetInt(obj.Hndl, feature_string);
            AT_CheckError(rc);
        end
        
        % Float properties
        function obj = setFloatProperty(obj, feature_string, val)
            [rc] = AT_SetFloat(obj.Hndl, feature_string, val);
            AT_CheckError(rc);
        end
        
        function [new_val, obj] = getFloatProperty(obj, feature_string)
            [rc, new_val] = AT_GetFloat(obj.Hndl, feature_string);
            AT_CheckError(rc);
        end
        
        % Boolean properties
        function obj = setBoolProperty(obj, feature_string, val)
            [rc] = AT_SetBool(obj.Hndl, feature_string, val);
            AT_CheckError(rc);
        end
        
        function [new_val, obj] = getBoolProperty(obj, feature_string)
            [rc, new_val] = AT_GetBool(obj.Hndl, feature_string);
            AT_CheckError(rc);
        end
        
        % Enumerated properties
        function obj = setEnumProperty(obj, feature_string, val)
            [rc] = AT_SetEnumString(obj.Hndl, feature_string, val);
            AT_CheckError(rc);
        end
        
        function [new_val, obj] = getEnumProperty(obj, feature_string)
            [rc, idx] = AT_GetEnumIndex(obj.Hndl, feature_string);
            AT_CheckError(rc);
            
            [rc, new_val] = AT_GetEnumStringByIndex( ...
                                obj.Hndl, ...
                                feature_string, ...
                                idx, ...
                                256); % (last arg: max string length)
            AT_CheckError(rc);
        end
        
        % Commands
        function command(obj, command_string)
            [rc] = AT_Command(obj.Hndl,command_string);
            AT_CheckWarning(rc);
        end
    end
end