% Script to calibrate pixel size in units of stage coordinates
microns_per_stage_unit = 0.1;

initial_position = scope.Stage.Position;

offsets = [0, 0; ...
           300, 0; ...
           300, 300; ...
           0, 300];
       
for i = 1:size(offsets, 1)
    scope.Stage.Position = initial_position + offsets(i,:);
    pause(1);
    calib{i}.image = max_intensity_z(scope.snap_group());
    calib{i}.stage = scope.Stage.Position;
end
           
%%

for i = 1:length(calib)
    figure(100 + i);
    imagesc(calib{i}.image);
end

%% Manually enter coordinates

calib{1}.coords = [125 171];
calib{2}.coords = [71 173];
calib{3}.coords = [69 117];
calib{4}.coords = [123 116];

%% Evaluate

ratio(1) = norm(offsets(2,:) - offsets(1,:)) / ...
           norm(calib{2}.coords - calib{1}.coords);
ratio(2) = norm(offsets(3,:) - offsets(2,:)) / ...
           norm(calib{3}.coords - calib{2}.coords);
ratio(3) = norm(offsets(4,:) - offsets(3,:)) / ...
           norm(calib{4}.coords - calib{3}.coords);
ratio(4) = norm(offsets(1,:) - offsets(4,:)) / ...
           norm(calib{1}.coords - calib{4}.coords);
       
microns_per_pixel = mean(ratio) * microns_per_stage_unit;