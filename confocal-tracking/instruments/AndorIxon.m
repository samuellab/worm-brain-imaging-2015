%% Andor Ixon Camera
%
% This provides a limited interface to Andor EMCCD cameras.  It mostly
% wraps the downloadable SDK provided by Andor to provide a leaner and
% cleaner interface to which we can attach callbacks.

classdef (ConstructOnLoad = true) AndorIxon < hgsetget
    
    properties 
        Binning = 1;
        ExposureTime;
        EMCCDGain;
        Cooler;
        AcquisitionMode;
        KineticCycleTime;
        TriggerMode;
        Shutter;
        OverlapMode;
    end
    
    properties (SetAccess = private)
        XPixels;
        YPixels;
    end
    
    methods
        function obj = AndorIxon(varargin)
            
            if nargin > 0
                if strcmp(varargin{1},'null')
                    return;
                end
            end
            
            disp('Initialising Camera');
            ret = AndorInitialize('');
            CheckError(ret);

            disp('Turning on cooler');
            obj.Cooler = 'On';
            
            [ret,XPixels, YPixels]=GetDetector;  
            obj.XPixels = XPixels;
            obj.YPixels = YPixels;
            
            ret = SetReadMode(4); % read mode 4 -> Image
            CheckWarning(ret);

            obj.AcquisitionMode = 'RunTillAbort';

            obj.EMCCDGain = 300;
            
            obj.ExposureTime = 1/30;
            
            obj.Binning = 1;
            
            obj.OverlapMode = 1; % pipeline frame acquisition
            
            obj.TriggerMode = 'software';
            
        end
        
        function obj = set.Binning(obj, val)
            ret = SetImage(val, val, 1, obj.XPixels, 1, obj.YPixels);
            CheckWarning(ret);
            
            if ret == atmcd.DRV_SUCCESS
                obj.ExposureTime = obj.ExposureTime * obj.Binning / val;
                obj.Binning = val;
            end
        end
        
        function obj = set.ExposureTime(obj,val)
            ret = SetExposureTime(val);
            CheckWarning(ret);
            
            [ret, exposure, accumulate, kinetic] = GetAcquisitionTimings();
            CheckWarning(ret);
            if ret == atmcd.DRV_SUCCESS
                obj.ExposureTime = exposure;
                obj.KineticCycleTime = kinetic;
            end
        end
                
        function obj = set.EMCCDGain(obj, val)
            ret = SetEMCCDGain(val);
            CheckWarning(ret);
            if ret == atmcd.DRV_SUCCESS
                obj.EMCCDGain = val;
            end
        end
        
        function obj = set.Cooler(obj, val)
            switch lower(val)
                case {'on', true}
                    ret = CoolerON;
                    CheckWarning(ret);
                    if ret == atmcd.DRV_SUCCESS
                        obj.Cooler = true;
                    end
                case {'off', false}
                    ret = CoolerOFF;
                    CheckWarning(ret);
                    if ret == atmcd.DRV_SUCCESS
                        obj.Cooler = false;
                    end
            end
        end
        
        function obj = set.AcquisitionMode(obj,val)
            switch val
                case 'SingleScan'
                    mode = 1;
                case 'Accumulate'
                    mode = 2;
                case 'KineticSeries' % use for z/c stacks
                    mode = 3;
                case 'RunTillAbort'
                    mode = 5;
                otherwise
                    error([val ' is not a valid acquisition mode']);
            end
            ret = SetAcquisitionMode(mode);
            CheckWarning(ret);
            if ret == atmcd.DRV_SUCCESS
                obj.AcquisitionMode = val;
            end
        end
        
        function obj = set.KineticCycleTime(obj, val)
            ret = SetKineticCycleTime(val);
            CheckWarning(ret);
            
            [ret, exposure, accumulate, kinetic] = GetAcquisitionTimings();
            CheckWarning(ret);
            if ret == atmcd.DRV_SUCCESS
                obj.KineticCycleTime = kinetic;
            end
        end
        
        function obj = set.TriggerMode(obj, val)
            val = lower(val);
            switch val
                case {'internal', 0}
                    mode = 0;
                case {'software', 10}
                    mode = 10;
                otherwise
                    mode = val;
            end
            ret = SetTriggerMode(mode);
            CheckWarning(ret);
            if ret == atmcd.DRV_SUCCESS
                obj.TriggerMode = val;
            end
        end
        
        function obj = set.Shutter(obj, val)
            val = lower(val);
            switch val
                case {'open', true}
                    mode = 1;
                case {'closed', false}
                    mode = 2;
            end
            ret = SetShutter(1, mode, 0, 0);
            CheckWarning(ret);
            if ret == atmcd.DRV_SUCCESS
                obj.Shutter = mode;
            end
        end
        
        function obj = set.OverlapMode(obj, val)
            ret = SetOverlapMode(val);
            CheckWarning(ret);
            if ret == atmcd.DRV_SUCCESS
                obj.OverlapMode = val;
            end
        end
        
        % destructor
        function delete(obj)
            ret = AndorShutDown;
            CheckWarning(ret);
        end
        
    end
end