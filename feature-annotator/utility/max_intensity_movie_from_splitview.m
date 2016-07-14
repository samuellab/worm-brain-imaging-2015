function max_intensity_movie_from_splitview(green_tif_directory, ...
                                            red_tif_directory, ...
                                            output_file, ...
                                            varargin)
% Create a max intensity projection movie treating images in
% green_tif_directory as green and red_tif_directory


default_options = struct(...
                        'filter', 1 ...
                        );
                    
input_options = varargin2struct(varargin{:}); 
options = mergestruct(default_options, input_options);

green_xy = load_tiff_stack(fullfile(green_tif_directory, ...
    'xy_projections.tif'));
green_xz = load_tiff_stack(fullfile(green_tif_directory, ...
    'xz_projections.tif'));
green_yz = load_tiff_stack(fullfile(green_tif_directory, ...
    'yz_projections.tif'));

red_xy = load_tiff_stack(fullfile(red_tif_directory, ...
    'xy_projections.tif'));
red_xz = load_tiff_stack(fullfile(red_tif_directory, ...
    'xz_projections.tif'));
red_yz = load_tiff_stack(fullfile(red_tif_directory, ...
    'yz_projections.tif'));

green_xy = imfilter(double(green_xy), options.filter);
green_xz = imfilter(double(green_xz), options.filter);
green_yz = imfilter(double(green_yz), options.filter);

red_xy = imfilter(double(red_xy), options.filter);
red_xz = imfilter(double(red_xz), options.filter);
red_yz = imfilter(double(red_yz), options.filter);

if nargin < 2
    output_file = fullfile(tif_directory, 'summary');
end

size_T = length(dir(fullfile(green_tif_directory,'T_*')));
vol = load_tiff_stack(fullfile(green_tif_directory,'T_00001.tif'));

size_Y = size(vol,1);
size_X = size(vol,2);
size_Z = size(vol,3);


% movie
[path, ~] = fileparts(output_file);
if ~exist(path,'dir');
    mkdir(path);
end
if exist(output_file,'file')
    delete(output_file);
end
writer = VideoWriter(output_file,'MPEG-4');
writer.Quality = 100;
writer.FrameRate = 18;
open(writer);

min_val1 = 0;
max_val1 = quantile(reshape(green_xy, [1 numel(green_xy)]), 1-1e-4);

min_val2 = 0;
max_val2 = quantile(reshape(red_xy, [1 numel(red_xy)]), 1-1e-4);

scale_Z = 4;
size_Z = scale_Z * size_Z;

for t = 1:size_T
    im_z1 = squeeze(green_xy(:,:,t));
    im_x1 = squeeze(green_yz(:,:,t));
    im_y1 = squeeze(green_xz(:,:,t));

    im_z2 = squeeze(red_xy(:,:,t));
    im_x2 = squeeze(red_yz(:,:,t));
    im_y2 = squeeze(red_xz(:,:,t));

    
    im_x1 = kron(im_x1, ones(1,scale_Z));
    im_x2 = kron(im_x2, ones(1,scale_Z));
    
    im_y1 = kron(im_y1, ones(scale_Z,1));
    im_y2 = kron(im_y2, ones(scale_Z,1));
    
    im_combined1 = ...
        [im_z1              zeros(size_Y,1)      im_x1           ;...
         zeros(1,size_X)    0                    zeros(1,size_Z) ;...
         im_y1              zeros(size_Z,1)      zeros(size_Z,size_Z)];

    im_combined2 = ...
        [im_z2              zeros(size_Y,1)      im_x2           ;...
         zeros(1,size_X)    0                    zeros(1,size_Z) ;...
         im_y2              zeros(size_Z,1)      zeros(size_Z,size_Z)];

    im_combined1 = (im_combined1 - min_val1)/(max_val1-min_val1);  
    im_combined2 = (im_combined2 - min_val2)/(max_val2-min_val2); 

    im_combined1 = kron(im_combined1,ones(2,2));
    im_combined1 = imfilter(im_combined1, ones(2,2)/4, 'same');

    im_combined2 = kron(im_combined2,ones(2,2));
    im_combined2 = imfilter(im_combined2, ones(2,2)/4, 'same');

    im = cat(3, im_combined2, im_combined1, zeros(size(im_combined1)));
    
    im(im>1) = 1;
    writeVideo(writer, im);
end
    
