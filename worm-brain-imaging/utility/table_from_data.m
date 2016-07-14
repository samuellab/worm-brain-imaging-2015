function tab = table_from_data(data)
% tab = table_from_data(d)
%
%   Takes old-style data and creates a column-oriented table for easier
%   analysis.

tab = table('RowNames', data.name');

for i = 1:size(tab, 1)
    
    id_string = tab.Properties.RowNames{i};
    c = textscan(id_string, '%*s%d%s');
    
    if ~isempty(c{1})
        
        neuron(i) = c{1};
        
    else
        
        neuron(i) = NaN;
        
    end
    
    if ~isempty(c{2})
        
        channel{i} = lower(c{2}{1}(2:end-1));
        
    elseif any(cell2mat(regexp(id_string, {'NaCl', 'alcohol'})))
        
        channel{i} = 'odor';
        
    else
        
        channel{i} = '';
        
    end
    
    timeseries_data(i) = timeseries(data.val(:,i), data.times, ...
        'Name', data.name{i});
    timeseries_data(i).TimeInfo.StartDate = ...
        datevec(data.time_offset/(24*60*60) + datenum([2013 1 1 0 0 0]));
    
end

tab.Channel = categorical(column(channel));
tab.Neuron = categorical(column(neuron));
tab.TimeSeries = timeseries_data';