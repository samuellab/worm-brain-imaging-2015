% run this to get lots of worm tracking data
% 
% wget -r ftp://anonymous@ftp.mrc-lmb.cam.ac.uk/pub/tjucikas/wormdatabase/results-12-06-08/Laura%20Grundy/gene_NA/allele_NA/N2/on_food/XX/30m_wait/L/


data_path = 'ftp.mrc-lmb.cam.ac.uk/pub/tjucikas/wormdatabase/results-12-06-08/Laura Grundy/gene_NA/allele_NA/N2/on_food/XX/30m_wait/L';
tracker = 'tracker_1';
run = 90;

folders1 = dir(fullfile(data_path, tracker, '20*'));
folders2 = dir(fullfile(data_path, tracker, folders1(run).name,'*.mat'));

data = load(fullfile(data_path,tracker,folders1(run).name,folders2.name));
% data.info:
% {
% 	"wt2": {
% 		"tracker": "2.0.4",
% 		"hardware": "2.0",
% 		"analysis": "2.0",
% 		"annotations": null
% 	},
% 	"video": {
% 		"length": {
% 			"frames": 23548,
% 			"time": 899.5336
% 		},
% 		"resolution": {
% 			"fps": 26.17801047,
% 			"height": 480,
% 			"width": 640,
% 			"micronsPerPixels": {
% 				"x": -4.69076374,
% 				"y": 4.69076374
% 			},
% 			"fourcc": "mjpg"
% 		},
% 		"annotations": {
% 			"frames": [108,108,1,...,
%           "reference: 

n_frames = data.info.video.length.frames;
total_time = data.info.video.length.time;

 worm_1 = fixgaps(data.worm.posture.eigenProjection(1,:));
 worm_2 = fixgaps(data.worm.posture.eigenProjection(2,:));
 worm_3 = fixgaps(data.worm.posture.eigenProjection(3,:));
 worm_4 = fixgaps(data.worm.posture.eigenProjection(4,:));
 worm_5 = fixgaps(data.worm.posture.eigenProjection(5,:));
 worm_6 = fixgaps(data.worm.posture.eigenProjection(6,:));
 worm_1 = data.worm.posture.eigenProjection(1,:);
 worm_2 = data.worm.posture.eigenProjection(2,:);
 worm_3 = data.worm.posture.eigenProjection(3,:);
 worm_4 = data.worm.posture.eigenProjection(4,:);
 worm_5 = data.worm.posture.eigenProjection(5,:);
 worm_6 = data.worm.posture.eigenProjection(6,:);
 
 
 data = [worm_1; worm_2; worm_3; worm_4; worm_5; worm_6];
 for i=1:n_frames
     data_cell{i} = data(:,i);
 end