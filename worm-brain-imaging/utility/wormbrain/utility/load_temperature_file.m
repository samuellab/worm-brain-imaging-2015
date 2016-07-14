function ts = load_temperature_file(filename, varargin)
% ts = LOAD_TEMPERATURE_FILE(filename)
%
%   Returns the temperature data stored in a given filename as a matlab
%   timeseries object. Only the measured temperature is returned.
%
% ts = LOAD_TEMPERATURE_FILE(filename, 'all')
%
%   Returns all the temperatures stored in a file (typically a control
%   temperature, the actual temperature used for feedback, and possibly a
%   third temperature at the location of interest).

% Open file to get the data
fileID = fopen(filename,'r');

% First line is start time information 'Mon, Nov 17, 18:14:08.49\r\n'
start_time_string = fgets(fileID);

delimiter = '\t';
startRow = 1;
formatSpec = '%f%f%f%f%[^\n\r]';

dataArray = textscan(fileID, formatSpec, ...
    'Delimiter', delimiter, 'EmptyValue' ,NaN, ...
    'HeaderLines' ,startRow-1, 'ReturnOnError', false);
fclose(fileID);

% Done with file

[~, filename, ~] = fileparts(filename);

year = str2num(filename(1:4));
month = str2num(filename(5:6));
day = str2num(filename(7:8));

colon_locs = findstr(start_time_string, ':');
hour = str2num(start_time_string(colon_locs(1) - 2 : colon_locs(1) - 1));
minute = str2num(start_time_string(colon_locs(1) + 1 : colon_locs(1) + 2));
second = str2num(start_time_string(colon_locs(2) + 1: end-2));

second_whole = floor(second);
second_part = mod(second, 1);

offset = datestr([year month day hour minute second_whole]);

dataArray{1} = dataArray{1} - dataArray{1}(1) + second_part;

names = {'T set', 'T control', 'T'};
for i = 2:length(dataArray)-1
    
    ts{i-1} = timeseries(dataArray{i}, dataArray{1}, 'Name', names{i-1});
    ts{i-1}.TimeInfo.StartDate = offset;
    
end

if nargin == 1
    ts = ts{3};
else
    ts = tscollection(ts);
end