function decimate_tiff_directory(input_directory, N, varargin)
% decimate_tiff_directory(input_directory, N)
%
% decimates the time-separated images in input_directory by a factor of N.
% A square averaging filter is used, and the timestamp assigned to the new
% image (in output_directory/times.json) is the timestamp associated with
% the last frame of each averaged set.
%
% example:  input_directory has 13 frames (T_00001.tif to T_00013.tif).
% Downsampling by 5 would result in images 1 to 5 being averaged into
% T_00001.tif which would be given the timestamp of T_00005.tif in the
% original directory.  There would be two output images (11 through 13 get
% discarded)
%
% This works for volumes as well as 2D images
%
%
% decimate_tiff_directory(input_dir, [N_y N_x (N_z) N_t])
%
% Decimates using the same algorithm on all 4 dimensions of the image.

size_T = length(dir(fullfile(input_directory,'T_*')));
im  = load_tiff_stack(fullfile(input_directory,...
                        sprintf('T_%05d.tif',1)));
                
switch length(N)
    case 1
        N_t = N;
        N = ones(1,ndims(im));
        time_only = true;
    otherwise
        N_t = N(end);
        N = N(1:end-1);
        time_only = false;
end
                  

directory_string = 'decimated_';
for i = 1:length(N)
    directory_string = [directory_string sprintf('%02d',N(i))];
end
directory_string = [directory_string sprintf('%02d',N_t)];

default_output_directory = fullfile(input_directory, directory_string);

input_options = varargin2struct(varargin{:}); 

default_options = struct(...
                    'output_directory', default_output_directory);
                
options = mergestruct(default_options, input_options);


times_json_filename = fullfile(input_directory,'times.json');
if exist(times_json_filename,'file')
    input_times = loadjson(times_json_filename);
    output_times.offset = input_times.offset;
end


size_T_final = floor(size_T/N_t);

for i = 1:size_T_final
    
    % average N images together
    if time_only
        im  = load_tiff_stack(fullfile(input_directory,...
                    sprintf('T_%05d.tif',1+(i-1)*N_t)));
        for j = 2+(i-1)*N_t : i*N_t
            im = im + ...
                 load_tiff_stack(fullfile(input_directory,...
                    sprintf('T_%05d.tif',1+(i-1)*N_t)));
        end
            
    else
        im = imresize_ND( ...
                load_tiff_stack(fullfile(input_directory,...
                    sprintf('T_%05d.tif',1+(i-1)*N_t))), ...
                N);
        for j = 2+(i-1)*N_t : i*N_t
            im = im + ...
                 imresize_ND( ...
                    load_tiff_stack(fullfile(input_directory,...
                        sprintf('T_%05d.tif',1+(i-1)*N_t))), ...
                    N);
        end
    end
    
    
    im = im / N_t;
    
    output_file = fullfile(options.output_directory,...
                           sprintf('T_%05d.tif',i));
    save_tiff_stack(im, output_file);
    
    % determine timestamp
    if exist(times_json_filename,'file')
         output_times.times(i) = input_times.times(i*N_t);
    end
   
    
end

if exist(times_json_filename,'file')
     savejson('',column(output_times),...
         fullfile(options.output_directory,'times.json'));
end


% update features
features = load_features(input_directory);
if ~isempty(features)
    new_features = struct([]);
    for i = 1:length(features)
        new_features{i} = scale(features{i}, [1./N 1/N_t]);
    end
    save_features(new_features, ...
        fullfile(options.output_directory, 'features.json'));
end

