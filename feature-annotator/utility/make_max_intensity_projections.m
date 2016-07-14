function make_max_intensity_projections(tif_directory, output_file, varargin)
% if tif_directory contains 2D images, just make a movie
% otherwise, if tif_directory has stacks (presumably z), 
% create 3 uncompressed tif stacks in tif_directory and a compressed movie
% in output_directory


[path, name] = fileparts(tif_directory);

if nargin < 2
    output_file = fullfile(tif_directory, 'summary');
end

size_T = length(dir(fullfile(tif_directory,'T_*')));
vol = load_tiff_stack(fullfile(tif_directory,'T_00001.tif'));

switch ndims(vol)
case 3
    size_Y = size(vol,1);
    size_X = size(vol,2);
    size_Z = size(vol,3);

    % initialize projections
    clear x y z;
    z = zeros(size(vol,1), size(vol,2), size_T, class(vol));
    x = zeros(size(vol,1), size(vol,3), size_T, class(vol));
    y = zeros(size(vol,3), size(vol,2), size_T, class(vol));
    
    if ~exist(fullfile(tif_directory, 'xy_projections'),'dir')
        mkdir(fullfile(tif_directory, 'xy_projections'));
    else
        disp(['directory ' fullfile(tif_directory,'xy_projections') ...
              ' exists.  Skipping.']);
        return;
    end
    if ~exist(fullfile(tif_directory, 'yz_projections'),'dir')
        mkdir(fullfile(tif_directory, 'yz_projections'));
    end
    if ~exist(fullfile(tif_directory, 'xz_projections'),'dir')
        mkdir(fullfile(tif_directory, 'xz_projections'));
    end
    
    for t = 1:size_T
        vol = load_tiff_stack(tif_directory, t); 
        z(:,:,t) = max_intensity_z(vol);
        y(:,:,t) = max_intensity_y(vol);
        x(:,:,t) = max_intensity_x(vol);
        
        xy_file = fullfile(tif_directory, 'xy_projections', ...
                            sprintf('T_%05d.tif',t));
        save_tiff_stack(z(:,:,t), xy_file);
        yz_file = fullfile(tif_directory, 'yz_projections', ...
                            sprintf('T_%05d.tif',t));
        save_tiff_stack(x(:,:,t), yz_file);
        xz_file = fullfile(tif_directory, 'xz_projections', ...
                            sprintf('T_%05d.tif',t));
        save_tiff_stack(y(:,:,t), xz_file);
        
    end
    
    timefile = fullfile(tif_directory,'times.json');
    
    if exist(timefile, 'file')
        copyfile(timefile, fullfile(tif_directory, 'xy_projections', ...
                                    'times.json'));
        copyfile(timefile, fullfile(tif_directory, 'yz_projections', ...
                                    'times.json'));
        copyfile(timefile, fullfile(tif_directory, 'xz_projections', ...
                                    'times.json'));
    end
    
    save_tiff_stack(z, fullfile(tif_directory, ...
                                'xy_projections.tif'));
    save_tiff_stack(x, fullfile(tif_directory, ...
                                'yz_projections.tif'));
    save_tiff_stack(y, fullfile(tif_directory, ...
                                'xz_projections.tif'));


    % movie
    [path, name] = fileparts(output_file);
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
    map = colormap('hot');
    map_len = linspace(0,1,size(map,1));
    r = map(:,1);
    g = map(:,2);
    b = map(:,3);

    min_val = 0;
    max_val = double(max_all(z));

    for t = 1:size_T
        im_z = squeeze(z(:,:,t));
        im_x = squeeze(x(:,:,t));
        im_y = squeeze(y(:,:,t));

        im_combined = ...
            [im_z               zeros(size_Y,1)      im_x            ;...
             zeros(1,size_X)    0                    zeros(1,size_Z) ;...
             im_y               zeros(size_Z,1)      zeros(size_Z,size_Z)];

       % im_combined = im_z;  % hack to get rid of x and y projections
         
        im_combined = double(im_combined);
        im_combined = (im_combined - min_val)/(max_val-min_val);      
        im_combined = kron(im_combined,ones(2,2));
        im_combined = imfilter(im_combined, ones(2,2)/4, 'same');

        im_r = interp1(map_len,r,im_combined);
        im_g = interp1(map_len,g,im_combined);
        im_b = interp1(map_len,b,im_combined);
        im = cat(3,im_r,im_g,im_b);
        writeVideo(writer, im);
    end
    
    
case 2
    % movie
    [path, name] = fileparts(output_file);
    if ~exist(path,'dir');
        mkdir(path);
    end
    if exist(output_file,'file')
        delete(output_file);
    end
    writer = VideoWriter(output_file,'MPEG-4');
    writer.Quality = 10;
    writer.FrameRate = 30;
    open(writer);
    map = colormap('hot');
    map_len = linspace(0,1,size(map,1));
    r = map(:,2);
    g = map(:,1);
    b = map(:,3);
    
    im = imread(fullfile(tif_directory, sprintf('T_%05d.tif',1))); 
    min_val = 0;
    max_val = double(max_all(im));
    
    for t = 1:size_T
        % load
        im = double(imread(...
                fullfile(tif_directory, sprintf('T_%05d.tif',t))));
        % rescale
        im = (im - min_val)/(max_val-min_val);
        % color
        im_r = interp1(map_len,r,im);
        im_g = interp1(map_len,g,im);
        im_b = interp1(map_len,b,im);
        % combine colors
        im = cat(3,im_r,im_g,im_b);
        % save
        writeVideo(writer, im);
    end
end

end