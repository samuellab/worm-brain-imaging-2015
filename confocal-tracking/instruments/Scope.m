%% Controls the Micrscope

classdef Scope < hgsetget
    
    properties %(SetAccess = immutable)
        
        % Camera object
        Cam;
        
        % DAQLaserPiezo object controlling laser and piezo via analog
        % outputs on a DAQ board
        DAQ;
        
        % Controls the stage
        Stage;
        
        % Sutter filter wheel
        FilterWheel;
        
        % Yokogawa Spinning Disc
        SpinningDisc;
              
    end
    
    properties 
                
        % Displays Data
        Displayer;
        
        % Logs Data
        Logger;
        
        % Tracks objects on the scope.
        Tracker;
        
        % Framerate
        FrameRate;
        
        % Continuous or Single
        Mode;
        
        % Piezo height, in microns
        Z = 50;
        
        % GFP Laser, in percent
        GFP = 0;
        
        % RFP Laser, in percent
        RFP = 0;
        
        % Purple Laser, in percent
        Purple = 0;
        
        % Purple enabled?
        PurpleOn = true;
        
        % GFP enabled?
        GFPOn = true;
        
        % RFP enabled?
        RFPOn = true;
        
        % Column array of Z values to scan, in microns.
        ZScan;
        
        % Dead frames to add at the beginning of a Z scan, to allow the
        % piezo to settle
        DeadFrames = 0;

        % Raster the Z scan to avoid large piezo travel?
        ZRaster = false;

        % Compensate for hysteresis when doing Z Rasters
        ZRasterOffset = 5;

        % Cell array of cell arrays indicating colors to scan:
        %  To alternate between Purple and RFP+GFP:
        %  obj.Cscan = {{'Purple'}, {'RFP', 'GFP'}}
        CScan;
        
        % Binning for the camera.
        Binning = 4;
        
    end
    
    methods
        
        % Constructor
        function obj = Scope()
            
            obj.Cam = AndorZyla();
            obj.DAQ = DAQLaserPiezo();
            obj.SpinningDisc = YokogawaCSU22('COM16'); 
            obj.Stage = LudlXYStage('COM14');
            obj.FilterWheel = SutterLambda10B('COM15');
            
            % Both of these listen to the camera and handle the data
            % received from it.
            obj.Displayer = Displayer(obj.Cam);
            obj.Logger = Logger(obj.Cam);
            
            % Tracker needs to know about the camera and the stage.
            obj.Tracker = Tracker(obj.Cam, obj.Stage);
            
            % Set the FilterWheel on the Yokogawa to position 2 (it's the
            % most common)
            obj.SpinningDisc.FilterWheel = 2;
            
        end
        
        % Destructor
        function delete(obj)
            delete(obj.Cam);
            delete(obj.DAQ);
            delete(obj.SpinningDisc);
            delete(obj.Stage);
            delete(obj.FilterWheel);
        end
        
        function obj = set.FrameRate(obj, val)
            obj.FrameRate = val;
            obj.Cam.ExposureTime = 0.0098 / (val/100);
            obj.DAQ.DAQSession.Rate = 1/obj.Cam.ExposureTime;
        end
        
        function vol = snap_group(obj)
            
            N = size(obj.DAQ.ScanVoltages, 1);
            
            obj.DAQ.prepare_single();
            vol = obj.Cam.snap(N);
            obj.DAQ.complete_single();

            if obj.ZRaster
                vol = vol(:,:,1:end/2);
            end
        end
        
        function prepare_continuous(obj)
        % Prepare for continuous acquisition.
            obj.Logger.initialize();
            obj.Cam.prepare_continuous();
            obj.DAQ.prepare_continuous();
        end
        
        function camera_on(obj)
        % Turn on continuous acquisition for the camera.
      
%             % Add a callback to add scans to the DAQ when less than 0.25
%             % seconds of data are available.
%             
%             data_queue_listener = obj.Cam.addlistener('GroupComplete', ...
%                 @obj.cam_callback);
            obj.Z = 50;
            obj.DAQ.start_continuous();
            obj.Cam.run_continuously();
            
        end
        
        function run_continuously(obj)
        % Run continuously, using the DAQ if ZScan or CScan is longer than
        % length 1
            
            obj.DAQ.start_continuous();
            
        end
        
        function camera_off(obj)
        % Turn off continuous acquisition for the camera.
            obj.DAQ.stop_continuous();
            obj.Cam.stop_continuous();
        end
        
        function recorder_on(obj)
        % Begin logging.
            obj.Logger.start();
        end
        
        function recorder_off(obj)
        % Stop logging.
            obj.Logger.finish();
        end
        
        function tracker_on(obj)
        % Begin tracking.
            obj.Tracker.start();
        end
        
        function tracker_off(obj)
        % Stop tracking.
            obj.Tracker.stop();
        end
        
        function obj = set.GFP(obj, val)
            obj.DAQ.GFP = val;
            obj.GFP = val;
        end
        
        function obj = set.RFP(obj, val)
            obj.DAQ.RFP = val;
            obj.RFP = val;
        end
        
        function obj = set.Purple(obj, val)
            obj.DAQ.Purple = val;
            obj.Purple = val;
        end
        
        function obj = set.GFPOn(obj, val)
            obj.DAQ.GFPOn = val;
            obj.GFPOn = val;
        end
        
        function obj = set.RFPOn(obj, val)
            obj.DAQ.RFPOn = val;
            obj.RFPOn = val;
        end
        
        function obj = set.PurpleOn(obj, val)
            obj.DAQ.PurpleOn = val;
            obj.PurpleOn = val;
        end
        
        function obj = set.Z(obj, val)
            obj.DAQ.Z = val;
            obj.Z = val;
        end
        
        function obj = set.ZScan(obj, val)
            obj.ZScan = val;
            obj.Tracker.ZRange = [val(1) val(end)];
            obj.configure_z_scan();
        end

        function obj = set.DeadFrames(obj, val)
            obj.DeadFrames = val;
            obj.configure_z_scan();
        end

        function obj = set.ZRaster(obj, val)
            obj.ZRaster = val;
            obj.configure_z_scan();
        end

        function obj = set.ZRasterOffset(obj, val)
            obj.ZRasterOffset = val;
            obj.configure_z_scan();
        end
        
        function obj = set.CScan(obj, val)
            obj.DAQ.CScan = val;
            obj.CScan = val;
        end
        
        function obj = set.Binning(obj, val)
            assert(val==1 || val==2 || val==4 || val==8, ...
                'Error: Binning value should be 1, 2, 4, or 8');
            
            obj.Cam.AOIBinning = [num2str(val) 'x' ...
                        num2str(val)];
                    
            obj.Tracker.Binning = val;
            
            obj.Binning = val;
        end
        
        function configure_z_scan(obj)
            
            D = obj.DeadFrames;
            V = obj.ZScan;

            obj.Cam.ImageGroupSize = length(V);
            obj.Cam.DeadFrames = D;

            offset = obj.ZRasterOffset;
            
            V_up = V;
            V_down = fliplr(V) - offset;

            if obj.ZRaster
                obj.DAQ.ZScan = [...
                    linspace(V_down(end), V_up(1), D) ...
                    V_up ...
                    linspace(V_up(end), V_down(1), D) ...
                    V_down];
                obj.DAQ.DeadFrames = 0;
                obj.Cam.Raster = true;
            else
                obj.DAQ.ZScan = V;
                obj.DAQ.DeadFrames = D;
                obj.Cam.Raster = false;
            end

        end
        
    end
    
end