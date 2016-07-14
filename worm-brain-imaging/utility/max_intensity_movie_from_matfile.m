function max_intensity_movie_from_matfile(mfile, reference_data, varargin)
% max_intensity_movie_from_matfile(mfile, reference_data)
%
%   Creates a max-intensity projection movie from the camera data in the
%   given matfile.  The file should have arrays named 'red' and 'green'
%   corresponding to the red and green channels for the movie.

if ~isa(mfile, 'matlab.io.MatFile')
    mfile = matfile(mfile);
end

if isa(reference_data, 'char')
    if exist(reference_data, 'file')
        reference_data = load(reference_data);
    end
end

default_options = struct(...
                        'output_file', 'summary/raw_movie.mp4', ...
                        'load_fn', @zyla_vol, ...
                        'filter', @(x) imfilter(x, ...
                                    fspecial('gaussian', 3, 3)), ...
                        'red_scale', 1.0, ...
                        'green_scale', 1.2, ...
                        'scale_Z', floor(2/0.54) ...
                    );
input_options = varargin2struct(varargin{:}); 
options = mergestruct(default_options, input_options);

scale_Z = options.scale_Z;

get_green = @(t) double(options.filter(squeeze(mfile.green(:,:,:,t))));
get_red = @(t) double(options.filter(squeeze(mfile.red(:,:,:,t))));

get_x = @(vol) max_intensity_x(vol);
get_y = @(vol) max_intensity_y(vol);
get_z = @(vol) max_intensity_z(vol);

sample_red = get_red(1);
sample_green = get_green(1);

red_scale = options.red_scale * max_all(sample_red);
green_scale = options.green_scale * max_all(sample_green);

% modified green and red getters, taking into account data scale from first
% frame.
get_green_scaled = @(t) get_green(t) / green_scale;
get_red_scaled = @(t) get_red(t) / red_scale;

S = size(mfile, 'green');

yx_images = zeros(S([1, 2, 4]));
yz_images = zeros(S([1, 3, 4]));
zx_images = zeros(S([3, 2, 4]));

% movie setup
[path, ~] = fileparts(options.output_file);
if ~exist(path,'dir');
    mkdir(path);
end
if exist(options.output_file,'file')
    delete(options.output_file);
end
writer = VideoWriter(options.output_file,'MPEG-4');
writer.Quality = 100;
writer.FrameRate = 18;
open(writer);

S(3) = scale_Z * S(3);

for t = 1:S(end)
    
    red = get_red_scaled(t);
    green = get_green_scaled(t);
    
    r_yx = get_z(red);
    r_yz = get_x(red);
    r_zx = get_y(red);
    g_yx = get_z(green);
    g_yz = get_x(green);
    g_zx = get_y(green);
    
    % Scale the z data based on pixel ratios
    r_yz = kron(r_yz, ones(1, scale_Z));
    r_zx = kron(r_zx, ones(scale_Z, 1));
    g_yz = kron(g_yz, ones(1, scale_Z));
    g_zx = kron(g_zx, ones(scale_Z, 1));
    
    r = ...
        [r_yx             zeros(S(1),1)      r_yz          ;...
         zeros(1,S(2))    0                  zeros(1,S(3)) ;...
         r_zx             zeros(S(3),1)      zeros(S(3),S(3))];

    g = ...
        [g_yx             zeros(S(1),1)      g_yz          ;...
         zeros(1,S(2))    0                  zeros(1,S(3)) ;...
         g_zx             zeros(S(3),1)      zeros(S(3),S(3))];
     
    im = cat(3, r, g, zeros(size(r)));
    im(im>1) = 1;
    writeVideo(writer, im);
    
end