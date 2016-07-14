%% Tracker

classdef (ConstructOnLoad = true) Tracker < hgsetget
    
    properties
        
        % Camera object generating data to be displayed.  It should provide
        % the following properties:
        %   GroupBuffer
        %   GroupBufferIndex
        % and it should broadcast the following events when plotting is to
        % take place:
        %   GroupComplete
        Cam;
        
        % Stage object
        Stage;
        
        % DAQ object
        DAQ;
        
        % Displayer object providing click events (DisplayClicked).
        Displayer;
        
        % Function applied to group retrieved from camera to generate an
        % image on which XY (stage) tracking can be performed.
        ImageFunctionXY = @max_intensity_z_Zyla;
        
        % Function applied to group retrieved from camera to generate an
        % image on which Z (piezo) tracking can be performed.
        ImageFunctionZ = @max_intensity_x_Zyla;
        
        % [Row, Column] pixel indices
        CurrentXY;
        
        CurrentZ;
        
        % [Row, Column] pixel indices
        TargetXY;
        
        TargetZ;

        % Tracking boundaries for Z
        ZBounds;
        
        % Proportional XY gain for stage feedback.
        GainXY = 1;
        
        % Z gain
        GainZ = 0.5;
        
        % Range of Z in image (in microns)
        ZRange;
        
        % Feedback is proportional, but attenuated for small displacements
        % when DampingXY is positive (amplified when negative).
        %   u(x) = - GainXY * (Error / MaxError) ^ (1 + DampingXY)
        DampingXY = 0;
        
        % Distance (in pixels) that our target can travel from frame to
        % frame.  Use this to avoid switching between targets from one
        % frame to the next.
        TrackingRadius;
        
        % Region near the target where tracking is disabled to limit
        % unecessary communication with the stage. (Pixels)
        TrackFreeRadius = 5;
                
        Binning = 1;
        
        UpdatePeriodXY = 1;
        
        UpdatePeriodZ = 5;
        
        BinaryThreshold = 500;
        
    end
    
    properties (SetAccess = private)
        
        CamListenerXY;
        
        CamListenerZ;
        
        % Counts the number of GroupComplete events to allow periodic
        % updating of stage.
        Counter = 0;
        
        % (40x objective, no binning pixel displacement) divided by
        % corresponding stage displacement.  X, Y (not row, column)
        ScopeToPixels = [-1.2900, -1.3817];
        
        % Raw Gain, determined by objective, binning, and the camera.  This
        % converts pixel displacement into stage velocity.
        RawGainXY;
        
    end
    
    methods
        
        function obj = Tracker(cam_obj, stage_obj)
        % Constructor
            obj.Cam = cam_obj;
            obj.Stage = stage_obj;
            %obj.DAQ = daq_obj;
            
            obj.CamListenerXY = obj.Cam.addlistener('GroupComplete', ...
                @obj.cam_callbackXY);
            obj.CamListenerZ = obj.Cam.addlistener('GroupComplete', ...
                @obj.cam_callbackZ);
            
            obj.CamListenerXY.Enabled = false;
            obj.CamListenerZ.Enabled = false;
            
%             set(obj.Displayer.Axes(1), 'ButtonDownFcn', ...
%                 @obj.display_callbackXY);
%             
%             set(obj.Displayer.Axes(2), 'ButtonDownFcn', ...
%                 @obj.display_callbackZ);
          
        end
        
        function obj = set.Binning(obj, val)
            
            obj.Binning = val;
            
            obj.RawGainXY = 1000 / (512/val);
            
            obj.TargetXY = [512 (1024+512)]/val;
            
        end
        
        function obj = initialize(obj)
        end
        
        function obj = start(obj)
            obj.CamListenerXY.Enabled = true;
            obj.CamListenerZ.Enabled = true;
        end
        
        function obj = stop(obj)
            obj.CamListenerXY.Enabled = false;
            obj.CamListenerZ.Enabled = false;
            obj.Stage.Velocity = [0 0];
        end
        
        function obj = display_callbackXY(obj, src, evt)
            axes_handle = get(src, 'Parent');
            coordinates = get(axes_handle,'CurrentPoint');
            obj.CurrentXY = round(fliplr(coordinates(1, 1:2)));
        end
        
        function obj = display_callbackZ(obj, src, evt)
            axes_handle = get(src, 'Parent');
            coordinates = get(axes_handle,'CurrentPoint');
            obj.CurrentZ = round(coordinates(1,2));
        end
        

    end
    
    methods (Access = private)
        
        function obj = cam_callbackXY(obj, ~, ~)
            if ~mod(obj.Counter, obj.UpdatePeriodXY)
                vol = obj.Cam.get_buffer();
                
                xy_image = obj.ImageFunctionXY(vol);
                
                old_xy = obj.CurrentXY;
                
                image_start = old_xy - obj.TrackingRadius * [1, 1];
                image_size = 2 * obj.TrackingRadius * [1, 1];
                
                xy_section = get_image_section( ...
                                image_start, ...
                                image_size, ...
                                xy_image);
                            
                xy_section = imfilter(xy_section, ones(10,10)/100);
                old_center = obj.TrackingRadius * [1, 1];
                new_center = centroid(xy_section .* ...
                    uint16(xy_section > obj.BinaryThreshold));
                feature_displacement = new_center - old_center;
                
                new_xy = old_xy + feature_displacement;
                
                if isnan(new_xy(1))
                    
                    new_xy = old_xy;
                    
                end
                
                obj.CurrentXY = round(new_xy);
                
                feature_displacement = new_xy - obj.TargetXY;
                
                feature_distance = norm(feature_displacement);
                
                if feature_distance > obj.TrackFreeRadius
                    
                    % New velocity if we were to use purely proportional
                    % feedback (no damping);
                    new_velocity = obj.RawGainXY * ...
                                   obj.GainXY * ...
                                   fliplr(feature_displacement);
                               
                    % Determine the maximum raw speed we can expect for the
                    % given tracking conditions.
                    max_speed = obj.RawGainXY * ...
                                obj.GainXY * ...
                                min(size(xy_image));
                            
                    % Determine the damping factor we will use for our raw
                    % velocity
                    velocity_damping = (norm(new_velocity) / max_speed) ...
                                       ^ (1 + obj.DampingXY);
                    
                    % Send the damped velocity to the stage.
                    obj.Stage.Velocity = ceil(velocity_damping * ...
                                              new_velocity);
                    
                else
                    disp('Target wihin TrackFreeRadius.');
                end
                
            end
            
            obj.Counter = obj.Counter + 1;
        end
        
        function obj = cam_callbackZ(obj, ~, ~)
            if ~mod(obj.Counter, obj.UpdatePeriodZ)
                vol = obj.Cam.get_buffer();
                
                z_image = obj.ImageFunctionZ(vol);
                
                size_Z = size(z_image, 1);
                
                z_image = imfilter(z_image, ones(4,4)/16);
                
                new_center = centroid(z_image .* ...
                                uint16(z_image > obj.BinaryThreshold));
                obj.CurrentZ = round(new_center(2));
                
                displacement = obj.CurrentZ - obj.TargetZ;
                
                z_range = obj.ZRange(end) - obj.ZRange(1);
                displacement_microns = displacement * z_range/size_Z;
                
                current_DAQ_Z = obj.DAQ.Z;
                
                new_DAQ_Z = current_DAQ_Z + ...
                            obj.GainZ * displacement_microns;
                
                allowed_new_Z = min(new_DAQ_Z, obj.ZBounds(2));
                allowed_new_Z = max(allowed_new_Z, obj.ZBounds(1));
                        
                obj.DAQ.Z = allowed_new_Z;
                
            end
        end
        
    end
end