function temperature = get_stage_temperature(feature, stage_calibration)
% function temperature = get_stage_temperature(feature, stage_calibration)
%  returns the temperature associated with the feature based on calibration
%  data provided in stage_calibration

global microns_per_stage_coord; 
if isempty(microns_per_stage_coord)
    microns_per_stage_coord = 0.1; %one motor step in x is 0.1 micron
end

global microns_per_pixel_coord_4x;
if isempty(microns_per_pixel_coord_4x)
    microns_per_pixel_coord_4x = 3.33; % one pixel is 3.33 micron at 4x
end

coords = feature.stage_coordinates;
x = round(coords(:,2)+feature.size(2)/2);
y = round(coords(:,1)+feature.size(1)/2);

cold_x = stage_calibration.cold.x * microns_per_stage_coord;
hot_x = stage_calibration.hot.x * microns_per_stage_coord;

cold_T = stage_calibration.cold.T;
hot_T = stage_calibration.hot.T;

% assumes the gradient is in the x-direction
temperature = interp1([cold_x hot_x], [cold_T hot_T], x);
