function data_out = combine_data(data_cells, global_times, varargin)
% data_out = combine_data(data_cells, global_times)
%
%   Combines data in a cell array by resampling at a common global time

T = length(global_times);

N = 0;
data_in = struct('name', [], 'val',[], 'times',[], 'time_offset',[]);
for i = 1:length(data_cells)
    for j = 1:length(data_cells{i})
        
        data_in(N+1) = data_cells{i}(j);
        N = N+1;
        
    end
end

data_out.times = global_times - global_times(1);
data_out.time_offset = global_times(1);

for i = 1:N

    data_out.name{i} = data_in(i).name;

    vals_in = data_in(i).val;
    times_in = data_in(i).times + data_in(i).time_offset;
    vals_out = interp1(times_in, vals_in, global_times);

    data_out.val(:, i) = column(vals_out);

end