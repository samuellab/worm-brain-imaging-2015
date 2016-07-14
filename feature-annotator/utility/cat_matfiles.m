function cat_matfiles(files, output_file, varargin)
% cat_matfiles({file1, file2, ...}, output_file, options)
%
%   file1, file2, ... should matfiles with the same variables stored.  This
%   will combine them into a single matfile.
%
% Currently, this only works if non-image data is 0-D or 1-D (time is
% second dimension) and image data is 4-D (time is 4th dimension).  The
% image data has to be stored in the 'images' field of the matfie.

default_options = struct(...
    'image_loaders', struct('name', 'images', ...
                            'fn', @zyla_vol), ...
    'frame_chunk_size', 1 ... % 2 -> take pairs of frames
);
input_options = varargin2struct(varargin{:}); 
options = mergestruct(default_options, input_options);

dt = options.frame_chunk_size;

outfile = matfile(output_file, 'Writable', true);

if ~iscell(files)
    files = {files};
end

N_files = length(files);

timer = tic;
N_frames = 0;
N_completed = 0;
for i = 1:N_files
    infile = matfile(files{i});
    Nf = size(infile, 'times', 2);
    N_frames = N_frames + Nf;
end
    
infile = matfile(files{1});
fields = whos(infile); 

t = 0; % current time index

size_T = size(infile, 'times', 2);
size_T = floor(size_T/dt) * dt;

% Copy the first file in.
for i = 1:length(fields)
    if ~strcmp(fields(i).name, 'images')
        field_size = size(infile, fields(i).name, 2);
        copy_size = min(size_T, field_size);
        outfile.(fields(i).name) = ...
            infile.(fields(i).name)(:, 1:copy_size);
    else
        for loader = options.image_loaders
            
            image_size =  size(infile, 'images');
            transformed_image = loader.fn(infile.images(:,:,:,1));
            image_size(1:3) = size(transformed_image);
            img = zeros(image_size, class(transformed_image));
                                      
            for j = 1:size_T
                img(:,:,:,j) = loader.fn(infile.images(:,:,:,j));
                N_completed = N_completed + 1;
                log_status(1);
            end
            
            outfile.(loader.name) = img;
            
        end
    end     
end
t = t + size_T;

for i = 2:N_files
    
    infile = matfile(files{i});
    size_T = size(infile, 'times', 2);
    size_T = floor(size_T/dt) * dt;
    
    for j = 1:length(fields)
        
        if ~strcmp(fields(j).name, 'images')
            field_size = size(infile, fields(j).name, 2);
            copy_size = min(size_T, field_size);
            outfile.(fields(j).name)(:, t+1:t+copy_size) = ...
                                 infile.(fields(j).name)(:, 1:copy_size);
        else
            for loader = options.image_loaders
                
                image_size(end) = size_T;
                img = zeros(image_size, class(transformed_image));
                for k = 1:size_T
                    img(:,:,:,k) = loader.fn(infile.images(:,:,:, k));
                    N_completed = N_completed + 1;
                    log_status(i);
                end
                
                outfile.(loader.name)(:,:,:,t+1:t+size_T) = img;
                
            end
        end
    end
    
    t = t + size_T;
end

function log_status(file_idx)

    disp(sprintf(...
        ['Completed frame %d of %d, currently on file %d of %d , ', ...
         '%d minutes elapsed'], ...
        N_completed, N_frames, file_idx, N_files, round(toc(timer)/60)));
    
end

end