function data = get_recent_data(folder, get_all)
% data = get_recent_data(folder)
%
%  Returns the most recent file (as listed by the 'dir' command) in folder.
%
% data = get_recent_data(8)
%
%   Loads the most recent data for worm 8.
%
% all_data = get_recent_data(8, true)
%
%   all_data.data -> data
%   all_data.data_gcamp -> data from gcamp channel
%   all_data.data_rfp -> data from rfp channel 


if nargin == 0
    folder = '\\LABNAS3\Data\vivek\141204 QW1217 freely moving\worm_11\data';
elseif isnumeric(folder)
    worm = folder;
    folder = sprintf(...
        '\\\\LABNAS3\\Data\\vivek\\141204 QW1217 freely moving\\worm_%02d\\data', ...
        worm);
end

files = dir(fullfile(folder, 'data*.mat'));
S = load(fullfile(folder, files(end).name));

if nargin == 2 && get_all
    data = S;
else
    data = S.data;
end

%data = table_from_data(data);