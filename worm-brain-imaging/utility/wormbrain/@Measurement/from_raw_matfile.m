function this = from_raw_matfile(filename, metadata_filename)
% obj = Measurement.FROM_RAW_MATFILE(filename)
%
%   Returns a Measurement object by loading the data from a single matfile.
%
% obj = Measurement.FROM_RAW_MATFILE(filename, metadata_filename)
%
%   Uses metadata from the specified yaml-formatted metadata file to
%   populate additional fields of the measurement thisect. The metadata
%   file may also specify image transformations to be applied prior to
%   display.

TIME_FORMAT = 'yyyy-mm-dd HH:MM:SS.FFF';

UUID = NaN;
Name = NaN;
Strain = NaN;

channel_names = {'channel 1', 'channel 2'};
channel_colors = {[1,0,0], [0,1,0]};
channel_rotate = { [], [] };

[~, short_filename, ext] = fileparts(filename);
short_input_filename = [short_filename, ext];

% Get settings from metadata file, if present:
if nargin == 2

    meta = structtools.load_yaml(metadata_filename, ...
        'append_directories', true);

    for i = 1:length(meta.datasets)

        for j = 1:length(meta.datasets{i}.image_files)

            full_name = meta.datasets{i}.image_files{j};
            [~, name, ext] = fileparts(full_name);
            short_name = [name, ext];

            if strcmp(short_name, short_input_filename)

                UUID = meta.datasets{i}.id;
                Name = meta.datasets{i}.animal;
                Strain = meta.datasets{i}.strain;

                if isfield(meta.datasets{i}, 'channels')

                    chans = meta.datasets{i}.channels;

                    for k = 1:length(chans)

                        channel_names{k} = chans{k}.name;
                        channel_colors{k} = chans{k}.c_vector;
                        
                        if isfield(chans{k}, 'rotate')
                            
                            channel_rotate{k} = chans{k}.rotate;
                            
                        end

                    end

                end

            end

        end

    end

end

m = matfile(filename);

all_fields = whos(m);

DataChannels = {};

all_times = m.times;

if mod(length(all_times), 2) == 1
    good_times_idx = 1:(length(all_times)-1);
else
    good_times_idx = 1:(length(all_times));
end
good_times = all_times(good_times_idx);

start_date = datestr(good_times(1), TIME_FORMAT);

time_offsets_days = good_times - good_times(1);
time_offsets = time_offsets_days*24*60*60;

for i = 1:length(all_fields)
    
    n = all_fields(i).name;
    
    if ~strcmp(n, 'images') && ~strcmp(n, 'times')

        data = m.(n);
        data = data(:, good_times_idx);
        
        row_1 = data(1, :);
        
        good_indices = find(row_1~=0);
        
        data = data(:, good_indices);
        t = time_offsets(:, good_indices);
        
        DataChannels{end+1} = timeseries(data, t, 'Name', n);
        DataChannels{end}.TimeInfo.StartDate = start_date;
        DataChannels{end}.TimeInfo.Format = TIME_FORMAT;
        
    end
    
end

loader = wormbrain.RawDataLoader(filename);

for i = 1:length(channel_names)

    if ~isempty(channel_rotate{i})

        reference_file = structtools.get_fullfile(channel_rotate{i}, ...
            'reference_data', ...
            'append_root', true);
        loader = loader.MakeChannelRotator(i, channel_rotate{i}.target, ...
            reference_file);

    end

end

ImageTimeSeries(1) = timeseries(good_times_idx, time_offsets, ...
    'Name', channel_names{1});
ImageTimeSeries(1).TimeInfo.StartDate = start_date;
ImageTimeSeries(1).TimeInfo.Format = TIME_FORMAT;

ImageTimeSeries(2) = timeseries(good_times_idx, time_offsets, ...
    'Name', channel_names{2});
ImageTimeSeries(2).TimeInfo.StartDate = start_date;
ImageTimeSeries(2).TimeInfo.Format = TIME_FORMAT;

ImageChannels{1} = loader.GetChannel(1);
ImageChannels{2} = loader.GetChannel(2);

this = wormbrain.Measurement(UUID, Name, Strain, ImageTimeSeries, ...
    ImageChannels, DataChannels);