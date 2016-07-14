%% Control of Z Piezo and Andor Laser Combiner through NI DAQ board
%
% This provides the interface to a Z Piezo and Laser Combiner through and
% NI DAQ board.
%
% To accomplish this, this interface communicates with both an NI DAQ board
% (PCI) and an Andor Laser Combiner via their provided SDK (USB).

classdef (ConstructOnLoad = true) DAQLaserPiezo < hgsetget
    
    properties 
        
        % Session object to communicate with
        DAQSession;
        
        % Current height in microns.  If a scan is running, this is the
        % reference height.
        Z = 50;
        
        % GFP Laser, in percent (0 to 100)
        GFP = 0;      
        
        % RFP Laser, in percent (0 to 100)
        RFP = 0;
        
        % 445 nm Laser, in percent (0 to 100)
        Purple = 0;
        
        % Purple enabled?
        PurpleOn = true;
        
        % GFP enabled?
        GFPOn = true;
        
        % RFP enabled?
        RFPOn = true;

        % Column array of Z values to scan, in microns.  These are always
        % relative to the reference height (Z).
        ZScan = linspace(-15, 15, 20);
        
        % Cell array of cell arrays indicating colors to scan:
        %  To alternate between Purple and RFP+GFP:
        %  obj.Cscan = {{'Purple'}, {'RFP', 'GFP'}}
        CScan = {{'Purple', 'RFP', 'GFP'}};
        
        % Current voltages output to each of the 4 analog outputs
        CurrentVoltages = [5 0 0 0];
        
        % Dead Frames to add to the beginning of each scan
        DeadFrames = 0;
        
        % N x 4 array of voltages to be continuously output as triggers
        % come from the camera. This gets updated when you change
        % ZScan or Cscan, and also when you change (Z|Purple|GFP|RFP).
        ScanVoltages;
        
    end
    
    properties (Hidden = true)
        
        DAQDevice = 'Dev1';
        
        PiezoDAQChannel = 'ao0';
        PiezoRange = [0 100]; % allowed range in microns
        PiezoVoltageBounds = [0 10]; % allowed piezo voltages
        
        PurpleDAQChannel = 'ao1';
        GFPDAQChannel = 'ao2';
        RFPDAQChannel = 'ao3';
        LaserVoltageBounds = [0 5]; % allowed laser voltages
        
        ALCPointer;
        
        QueueDataListener;
        
        % True when continuous acquisition is in progress.
        IsRunning;

    end
    
    methods
        
        % Constructor
        function obj = DAQLaserPiezo(daq_session)
            
            if nargin == 0
                daq_session = daq.createSession('ni');
            end
            
            obj.DAQSession = daq_session;
            
            % Analog output for the piezo.                              
            obj.DAQSession.addAnalogOutputChannel(obj.DAQDevice, ...
                                                  obj.PiezoDAQChannel, ...
                                                  'Voltage');

            % Analog output for each of the three lasers.                             
            obj.DAQSession.addAnalogOutputChannel(obj.DAQDevice, ...
                                                  obj.PurpleDAQChannel, ...
                                                  'Voltage');
            obj.DAQSession.addAnalogOutputChannel(obj.DAQDevice, ...
                                                  obj.GFPDAQChannel, ...
                                                  'Voltage');
            obj.DAQSession.addAnalogOutputChannel(obj.DAQDevice, ...
                                                  obj.RFPDAQChannel, ...
                                                  'Voltage');
                                              
            % Create a clock connection from the camera to trigger the
            % analog output.
            obj.DAQSession.addClockConnection(...
                'external','dev1/PFI5','ScanClock');
            
            % Also create a trigger connection, so data output doesn't
            % start until the camera starts acquiring:
            obj.DAQSession.addTriggerConnection(...
                'external','dev1/PFI5','StartTrigger');
            
            % Open the Andor ALC 2.4 library to enable lasers.  The header
            % file is a slightly modified version of the header file
            % from Andor (it removes extraneous compiler directives).
            loadlibrary('AB_ALC_REV64.dll', 'ALC_REV_C_MATLAB.h');
            
            ref_val = -1;
            obj.ALCPointer = libpointer('int32Ptr', ref_val);
            calllib('AB_ALC_REV64', ...
                'Create_ALC_REV_NoDAC_C', obj.ALCPointer);
            
            calllib('AB_ALC_REV64', ...
                'Initialize', obj.ALCPointer.Value);
            
        end
        
        % Destructor
        function delete(obj)
            % Call the ALC library's destructor
            calllib('AB_ALC_REV64', ...
                'Delete_ALC_REV_C', obj.ALCPointer.Value);
        end
        
        function obj = set.Z(obj, val)            
            
            new_voltage = obj.microns_to_volts(val);
            
            obj.Z = obj.volts_to_microns(new_voltage);
            
            if ~obj.IsRunning
                voltages = obj.CurrentVoltages;
                voltages(1) = new_voltage;
                obj.CurrentVoltages = voltages;
            end
            
            obj.updateScanVoltages();
            
        end
        
        function obj = set.Purple(obj, val)
            new_voltage = obj.percent_to_volts(val);
            
            obj.Purple = obj.volts_to_percent(new_voltage);
            
            if ~obj.IsRunning
                voltages = obj.CurrentVoltages;
                voltages(2) = new_voltage;
                obj.CurrentVoltages = voltages;
            end
            
            obj.updateScanVoltages();
        end
        
        function obj = set.GFP(obj, val)
            new_voltage = obj.percent_to_volts(val);
            obj.GFP = obj.volts_to_percent(new_voltage);
            
            if ~obj.IsRunning
                voltages = obj.CurrentVoltages;
                voltages(3) = new_voltage;
                obj.CurrentVoltages = voltages;
            end
            
            obj.updateScanVoltages();
        end
        
        function obj = set.RFP(obj, val)
            new_voltage = obj.percent_to_volts(val);
            obj.RFP = obj.volts_to_percent(new_voltage);
            
            if ~obj.IsRunning
                voltages = obj.CurrentVoltages;
                voltages(4) = new_voltage;
                obj.CurrentVoltages = voltages;
            end
            
            obj.updateScanVoltages();
        end
        
        function obj = set.RFPOn(obj, val)
            if val
                voltage = obj.percent_to_volts(obj.RFP);
            else
                voltage = 0;
            end
            
            if ~obj.IsRunning
                voltages = obj.CurrentVoltages;
                voltages(4) = voltage;
                obj.CurrentVoltages = voltages;
            end
            obj.RFPOn = val;
            obj.updateScanVoltages();
        end
        
        function obj = set.PurpleOn(obj, val)
            if val
                voltage = obj.percent_to_volts(obj.Purple);
            else
                voltage = 0;
            end
            
            if ~obj.IsRunning
                voltages = obj.CurrentVoltages;
                voltages(2) = voltage;
                obj.CurrentVoltages = voltages;
            end
            obj.PurpleOn = val;
            obj.updateScanVoltages();
        end
        
        function obj = set.GFPOn(obj, val)
            if val
                voltage = obj.percent_to_volts(obj.GFP);
            else
                voltage = 0;
            end
            
            if ~obj.IsRunning
                voltages = obj.CurrentVoltages;
                voltages(3) = voltage;
                obj.CurrentVoltages = voltages;
            end
            obj.GFPOn = val;
            obj.updateScanVoltages();
        end
        
        function obj = set.CScan(obj, val)
            obj.CScan = val;
            obj.updateScanVoltages();
        end
        
        function obj = set.ZScan(obj, val)
            obj.ZScan = val;
            obj.updateScanVoltages();
        end
        
        function obj = updateScanVoltages(obj)
        % Use the current value and scan settings to create a scan
        % schedule.
            z_microns = obj.Z + obj.ZScan;
            z_volts = obj.microns_to_volts(z_microns);
            
            colors = obj.CScan;
            loop_size = length(z_volts) * length(colors);
            
            scan = zeros(loop_size, ...
                         length(obj.DAQSession.Channels));
             
            i = 1;
            for z = 1:length(z_volts)
                for c = 1:length(colors)
                    
                    row = zeros(1, length(obj.DAQSession.Channels));
                    row(1) = z_volts(z);
                    
                    if strmatch('Purple', colors{c})
                        if obj.PurpleOn
                            row(2) = obj.percent_to_volts(obj.Purple);
                        else
                            row(2) = 0;
                        end
                    end
                    if strmatch('GFP', colors{c})
                        if obj.GFPOn
                            row(3) = obj.percent_to_volts(obj.GFP);
                        else
                            row(3) = 0;
                        end
                    end
                    if strmatch('RFP', colors{c})
                        if obj.RFPOn
                            row(4) = obj.percent_to_volts(obj.RFP);
                        else
                            row(4) = 0;
                        end
                    end
                    
                    scan(i,:) = row;
                    i = i + 1;
                    
                end
            end
            
            % Add dead frames to the beginning of obj.ScanVoltages
            scan1 = scan(1,:);
            obj.ScanVoltages = [repmat(scan1, [obj.DeadFrames, 1]);
                                scan];
        end
        
        function obj = set.CurrentVoltages(obj, val)
            obj.CurrentVoltages = val;
            obj.DAQSession.outputSingleScan(val);
        end
        
        function obj = set.ScanVoltages(obj, val)
            obj.ScanVoltages = val;
            
            % Replace the data queuing function.
            delete(obj.QueueDataListener);
            obj.QueueDataListener = obj.DAQSession.addlistener(...
                'DataRequired', @obj.queueData);

        end
        
        function obj = prepare_single(obj)
            obj.DAQSession.stop();
            
            obj.DAQSession.IsContinuous = false;
            
            obj.flushQueue();
            obj.queueData();
            
            obj.DAQSession.startBackground();
        end
        
        function obj = complete_single(obj)
            obj.DAQSession.stop();
        end
        
        function obj = prepare_continuous(obj)
        % Prepare for continuous acquisition.
            
            obj.DAQSession.stop();
            obj.DAQSession.IsContinuous = true;
            
            % Flush queued data.
            obj.flushQueue();
            
            % Queue at least 1 second of scans.
            for i = 1:ceil(obj.DAQSession.Rate/size(obj.ScanVoltages,1))
                
                obj.queueData();
                
            end
            
        end
        
        function obj = start_continuous(obj)
            obj.DAQSession.startBackground();
            obj.IsRunning = true;
        end
        
        function obj = stop_continuous(obj)
            obj.DAQSession.stop();
            obj.IsRunning = false;
        end
        
        function obj = flushQueue(obj)
        % Hack to flush the queued data: we'll add an analog output
        % channel, then immediately delete it.  There must be a better
        % way to accomplish this...
            obj.DAQSession.addAnalogOutputChannel(...
                obj.DAQDevice, 'ao7', 'Voltage');
            obj.DAQSession.removeChannel(length(obj.DAQSession.Channels));
        end
        
        function queueData(obj, src, event)
            obj.DAQSession.queueOutputData(obj.ScanVoltages);
        end
        
    end
    
    methods (Access = private)
        
        function v = microns_to_volts(obj, m)
            v = interp1(obj.PiezoRange, obj.PiezoVoltageBounds, m, ...
                        'linear', 'extrap');
            v = min(v, obj.PiezoVoltageBounds(2));
            v = max(v, obj.PiezoVoltageBounds(1));
        end
        
        function m = volts_to_microns(obj, v)
            m = interp1(obj.PiezoVoltageBounds, obj.PiezoRange, v);
        end
        
        function v = percent_to_volts(obj, p)
            v = interp1([0 100], obj.LaserVoltageBounds, p, ...
                        'linear', 'extrap');
            v = min(v, obj.LaserVoltageBounds(2));
            v = max(v, obj.LaserVoltageBounds(1));
        end
        
        function p = volts_to_percent(obj, v)
            p = interp1(obj.LaserVoltageBounds, [0 100], v);
        end
        
    end
    
end