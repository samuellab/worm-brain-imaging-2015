function data = get_odor_data(filename, start_time)
% data = get_odor_data(filename)
%
%   Returns the data from an odor_data file in a standard format. The
%   output (data) will be a struct array with fields:
%
%       name: type of odor
%       val: boolean corresponding to when the odor is on
%       times: times at which we have samples
%       time_offset: reference time to allow combining with other data

if nargin < 2
    start_time = 0;
end

% Open file to get the data
fileID = fopen(filename,'r');


delimiter = '\t';
startRow = 4;
formatSpec = '%s%f%[^\n\r]';

dataArray = textscan(fileID, formatSpec, ...
    'Delimiter', delimiter, 'EmptyValue' ,NaN, ...
    'HeaderLines' ,startRow-1, 'ReturnOnError', false);
fclose(fileID);

% Done with file

odors = dataArray{1};
durations = dataArray{2};

total_time = sum(durations);
cum_times = [0; cumsum(durations)];

% sampling time for output trace
dt = 0.1;

times = 0:dt:total_time;

% Determine the unique odors
unique_odors = {};
for i = 1:length(odors)
    if ~any(strcmp(odors{i}, unique_odors))
        unique_odors{end+1} = odors{i};
    end
end

% Create '0' traces for each odor
for i = 1:length(unique_odors)
    odor_traces{i} = zeros(length(times), 1);
end

% Assign the traces to each odor

for i = 1:length(odors)
    idx = find(strcmp(odors{i}, unique_odors));
    
    current_trace = zeros(length(times), 1);
    current_trace((round(cum_times(i)/dt)+1) : (round(cum_times(i+1)/dt))) = 1;
    
    odor_traces{idx} = odor_traces{idx} + current_trace;
end

% Create the output data
for i = 1:length(unique_odors)
    
    data(i).name = unique_odors{i}(2:end);
    data(i).val = odor_traces{i};
    data(i).times = times';
    data(i).time_offset = start_time;
    
end