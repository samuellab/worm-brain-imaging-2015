function data = get_labview_temperature(filename)


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

offset = (datenum([year month day hour minute second]) - ...
          datenum([2013 1 1 0 0 0])) * 24*60*60;

dataArray{1} = dataArray{1} - dataArray{1}(1);      

names = {'T set', 'T control', 'T'};
for i = 2:length(dataArray)-1
    data(i-1).name = names{i-1};
    data(i-1).val = dataArray{i};
    data(i-1).times = dataArray{1};
    data(i-1).time_offset = offset;
end