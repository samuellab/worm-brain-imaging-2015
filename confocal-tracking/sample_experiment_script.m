%% Open instruments
global scope;
scope = Scope();

%% Configure acquisition

scope.ZScan = linspace(-17, 17, 17);
scope.Tracker.TargetZ = 9; %Index, not value
scope.Tracker.ZBounds = [25 75];

scope.DeadFrames = 3; 
scope.ZRaster = true;
scope.ZRasterOffset = 13;

scope.FrameRate = 200;

scope.DAQ.DAQSession.IsContinuous = true;

binning_factor = 4;
scope.Binning = binning_factor;

% Landscape
scope.Cam.AOIHeight = 1024/binning_factor; 
scope.Cam.VerticallyCenterAOI = 1;

% Portrait
%scope.Cam.AOIHeight = 2048/binning_factor;
%scope.Cam.AOIWidth = 1024/binning_factor;
%scope.Cam.AOILeft = 1024/2;

scope.GFP = 100;
scope.RFP = 0;

%% Configure displays

test_image = scope.snap_group();

% red and green
test_green = test_image(:, 1:1024/binning_factor, :);
test_red = test_image(:, 1024/binning_factor+1:end, :);

min_red = min_all(test_red);
max_red = max_all(test_red);

% RFP XY
figure(1000);
h_xy = imshow(max_intensity_z_Zyla(test_image), [1 600]);

% RFP XZ
figure(1001);
h_xz = imshow(max_intensity_y_Zyla(test_image), [1 600]);

% RFP YZ
figure(1002);
h_yz = imshow(max_intensity_x_Zyla(test_image), [1 600]);

scope.Displayer.add_display(h_xy, @max_intensity_z_Zyla);
scope.Displayer.add_display(h_xz, @max_intensity_y_Zyla);
scope.Displayer.add_display(h_yz, @max_intensity_x_Zyla);

%% Configure logging
t = datevec(now);
directory_string = sprintf('%02d_%02d_%02d', t(1), t(2), t(3));
scope.Logger.Directory = fullfile('M:\Data\confocal_tracking', ...
                                  directory_string);
scope.Logger.Filename = 'test_101.mat';

%%  Tracking
scope.Tracker.DAQ = scope.DAQ;
scope.Tracker.GainXY = 8;
scope.Tracker.TrackingRadius = 50;
scope.Tracker.GainZ = 6;
scope.Tracker.UpdatePeriodZ = 3;
scope.Tracker.UpdatePeriodXY = 1;

set(scope.Displayer.Axes(1), 'ButtonDownFcn', ...
    @(x,y) scope.Tracker.display_callbackXY(x,y));

scope.Logger.add_aux_data('stage', @() scope.Stage.Position, 3);
scope.Logger.add_aux_data('Z', @() scope.DAQ.Z, 3);

%% Track Green

scope.Tracker.TargetXY = [256+128, 128];

%% Track Red

scope.Tracker.TargetXY = [128, 128];

%% Run
scope_controls;