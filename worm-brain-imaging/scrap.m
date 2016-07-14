global feature_annotator_data;

mcherry_dir = ...
    'C:\Users\vivekv\workspace\worm-brain-imaging\local\test_data\ADS1+mCherry\run_015\unprocessed_TIFs\cropped_mCherry';

gcamp_dir = ...
    'C:\Users\vivekv\workspace\worm-brain-imaging\local\test_data\ADS1+mCherry\run_015\unprocessed_TIFs\cropped_GCaMP';

times_file = ...
    'C:\Users\vivekv\workspace\worm-brain-imaging\local\test_data\ADS1+mCherry\run_015\unprocessed_TIFs\times.json';

mcherry_reg_dir = fullfile(mcherry_dir, 'registered');
gcamp_reg_dir = fullfile(gcamp_dir, 'registered');


flow_features(feature_annotator_data.features, ...
              mcherry_dir, ...
              'reference_time', 1, ...
              'times_to_register', 2:200);
          
flow_features(feature_annotator_data.features, ...
              gcamp_dir, ...
              'reference_time', 1, ...
              'times_to_register', 2:200, ...
              'deformations_directory', mcherry_reg_dir);
          

%% load all the image data

vrpre = load_tiff_stack(mcherry_dir);
vgpre = load_tiff_stack(gcamp_dir);
vrpost = load_tiff_stack(mcherry_reg_dir);
vgpost = load_tiff_stack(gcamp_reg_dir);

%%
times = loadjson(times_file);
t = times.times(1:size(vgpost,4));

%% get volumes
t1 = 1;
t2 = 130;
clear v1 v2;

r_scale = 8;
g_scale = 12;

p = @(v,d) squeeze(max(v,[],d));

v1pre(:,:,:,1) = vrpre(:,:,:,t1)*r_scale;
v1pre(:,:,:,2) = vgpre(:,:,:,t1)*g_scale;

v2pre(:,:,:,1) = vrpre(:,:,:,t2)*r_scale;
v2pre(:,:,:,2) = vgpre(:,:,:,t2)*g_scale;

v1post(:,:,:,1) = vrpost(:,:,:,t1)*r_scale;
v1post(:,:,:,2) = vgpost(:,:,:,t1)*g_scale;

v2post(:,:,:,1) = vrpost(:,:,:,t2)*r_scale;
v2post(:,:,:,2) = vgpost(:,:,:,t2)*g_scale;


clear v;
v(:,:,:,2) = vgpre(:,:,:,t1)*g_scale;
v(:,:,:,3) = vgpre(:,:,:,t2)*g_scale;
vz = p(v,3);
figure(1); subplot(231); imshow(vz)

clear v;
v(:,:,:,1) = (vrpre(:,:,:,t1)+vrpre(:,:,:,t2))*r_scale;
v(:,:,:,2) = vgpre(:,:,:,t1)*g_scale;
v(:,:,:,3) = vgpre(:,:,:,t2)*g_scale;
vz = p(v,3);
figure(1); subplot(232); imshow(vz)

clear v;
v(:,:,:,1) = (vrpost(:,:,:,t1)+vrpost(:,:,:,t2))*r_scale/1.5;
v(:,:,:,2) = vgpost(:,:,:,t1)*g_scale;
v(:,:,:,3) = vgpost(:,:,:,t2)*g_scale;
vz = p(v,3);
figure(1); subplot(233);imshow(vz)

clear v;

%%
vgpost_filtered = imfilter(vgpost, ones([3 3 1 3])/27, 'replicate');


%%
pts = {...
       [52 104 9] ...
       [63 78 13] ... % afd
       [58 32 13] ...
       [26 86 13] ...
      };

N = length(pts);
clear s;
for i = 1:N
    pt = pts{i};
    coord = {pt(1) pt(2) pt(3) 1:size(vgpost,4)};
    x = double(squeeze(vgpost_filtered(coord{:})));
    s{i} = x/mean(x);
    figure(2); 
    plot(s{i})
end


%%

siz = size(vgpost_filtered);

parfor i = 3:4
    fs{i} = zeros(siz(1:3));
    for j = 1:prod(siz(1:3));
        [y, x, z] = ind2sub(siz(1:3), j);
        pix = squeeze(vgpost_filtered(y,x,z,:));
        fs{i}(y,x,z) = row(normalize_array(double(s{i}))) * ...
                       column(normalize_array(double(pix))) / siz(4);
    end
end

%%
fs{2}(:,:,1) = 0;

%%
afd = vgpost_filtered(:,:,:,1);
afd(fs{2}<0.7) = 0;

afd2d(:,:,2) = p(afd,3)*g_scale;
afd2d(:,:,3) = 0;
figure(1); subplot(235); imshow(afd2d)

%%
muscle = vgpost_filtered(:,:,:,1);
muscle(fs{3}<0.9) = 0;

muscle2d(:,:,2) = p(muscle,3)*g_scale*1.5;
figure(1); subplot(236); imshow(muscle2d)

%%
afd_sig = smooth(s{2});
afd_sig = afd_sig/mean(afd_sig);
figure(2); clf; plot(t, smooth(s{2}), 'LineWidth',3, 'Color', [0 .6 0]); hold on;

muscle_sig = smooth(s{3});
muscle_sig = muscle_sig/mean(muscle_sig)/8;
figure(2); plot(t, muscle_sig, 'LineWidth',3, 'Color', [0 0 0.6])

xlabel('Time (seconds)');
ylabel('Fluorescence (AU)');