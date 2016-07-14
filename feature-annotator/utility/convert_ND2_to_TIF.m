function convert_ND2_to_TIF(nd2_file, varargin)
% convert_ND2_to_TIF(nd2_file, 'tif_directory', tif_directory)
%   nd2_file and tif_directory should be complete paths
%  
% convert_ND2_to_TIF('volume.nd2', 'overwrite', true)
%   overwrites existing files

[path, name, ~] = fileparts(nd2_file);

default_options = struct(...
    'tif_directory', ...
        fullfile(path, name, 'unprocessed_TIFs'), ...
    'overwrite', true, ...
    'size_Z', [], ...
    'separate_colors', true, ...
    'colors', {{'green', 'red', 'blue'}}, ...
    'start_time', [], ...
    'swap_CT', false, ...
    'load_fn', @(x) x ...
);

global_option_file = fullfile(path, 'globals.yaml');
option_file = fullfile(path, name, '.yaml');

if exist(global_option_file)
    global_file_options = ReadYaml(global_option_file);
else
    global_file_options = struct();
end
default_options = mergestruct(default_options, global_file_options);

if exist(option_file)
    file_options = ReadYaml(option_file);
else
    file_options = struct();
end
default_options = mergestruct(default_options, file_options);

input_options = varargin2struct(varargin{:}); 
options = mergestruct(default_options, input_options);

tif_directory = options.tif_directory;
overwrite = options.overwrite;
colors = options.colors;
% 
% bf_reader = bfGetReader(nd2_file);
% metadata = bf_reader.getSeriesMetadata();
% omeMeta = bf_reader.getMetadataStore();


bio_formats_data = bfopen(nd2_file);
metadata = bio_formats_data{2};
omeMeta = bio_formats_data{4};

size_X = omeMeta.getPixelsSizeX(0).getValue; % 512
size_Y = omeMeta.getPixelsSizeY(0).getValue; % 512
size_Z = omeMeta.getPixelsSizeZ(0).getValue; % 31
size_T = omeMeta.getPixelsSizeT(0).getValue; % 615
size_C = omeMeta.getPixelsSizeC(0).getValue; % 2

if ~isempty(options.size_Z) && ...
        size_Z ~= options.size_Z && ...
        ~isnan(options.size_Z)
    size_Z = options.size_Z;
    size_T = size_T/size_Z;
end

if metadata.containsKey('timestamp #0001')
    timestamp_format = '%04d';
elseif metadata.containsKey('timestamp #00001')
    timestamp_format = '%05d';
else
    timestamp_format = [];
end

if options.separate_colors
    for c = 1:size_C
        mkdir(fullfile(tif_directory, colors{c}));
    end
end

image_times = zeros(size_T,1);
for j = 1:size_T
    index = j*size_Z - 1;
    
    if ~isempty(timestamp_format)
        image_times(j) = metadata.get(['timestamp #' ...
                                   sprintf(timestamp_format,index)]);
    end
    
	if options.separate_colors
        for c = 1:size_C
            output_file{c} = fullfile(tif_directory, options.colors{c}, ...
                                      sprintf('T_%05d.tif',j));
            if exist(output_file{c},'file')
                file_info = imfinfo(output_file{c});
                if length(file_info) ~= size_Z
                    delete(output_file{c});
                elseif ~overwrite
                    continue
                end
            end
        end
    else
        output_file = fullfile(tif_directory, sprintf('T_%05d.tif',j));
        if exist(output_file, 'file')
            file_info = imfinfo(output_file);
            if length(file_info) ~= size_Z
                delete(output_file);
            elseif ~overwrite
                continue
            end
        end
    end
                                
    vol = zeros(size_Y,size_X,size_Z,size_C,'uint16');
    
    for z = 1:size_Z
        for c = 1:size_C
            idx = (j-1)*size_Z*size_C + (z-1)*size_C + c;
            vol(:,:,z,c) =  bio_formats_data{1}{idx,1};
            if options.separate_colors
                file_to_write = output_file{c};
            else
                file_to_write = output_file;
            end
            imwrite(options.load_fn(vol(:,:,z,c)),...
                file_to_write,...
                'WriteMode', 'append',...
                'Compression', 'none');
        end
    end
    clear vol;
end

clear bio_formats_data;

if ~isempty(options.start_time)
    offset_time = 60*60*24*(datenum(otpions.start_time) - ...
                            datenum(2013,1,1,0,0,0));
	offset_time = round(offset_time);
else

    nd2_file_info = dir(nd2_file);

    % reference start of 2013
    offset_time = nd2_file_info.datenum - datenum(2013,1,1,0,0,0); 
    offset_time = offset_time*60*60*24; %convert from days to seconds
    offset_time = offset_time - image_times(end); % convert to start time
end

if ~isempty(timestamp_format)
    times = struct('offset',offset_time,'times',image_times);

    savejson('',times,fullfile(tif_directory,'times.json'));
end