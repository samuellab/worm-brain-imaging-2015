function [output, summary] = separate_trials(data, times, varargin)
% Takes in a list of trial times and corresponding measurements and
% separates the data based on which trial it comes from.  The output is a
% struct array with fields 'times' and 'data' corresponding to the data
% from the n'th trial.
%
%   [output, summary] = separate_trials(data, times)
%
%       The stimulus onsets are determined by looking for jumps in recorded
%       times.  
%
%       data: T x N array of observations, where T is the number of time 
%           points for which observations were made.
%
%       times: T x 1 array of times at which observations were made.
%
%   [output, summary] = separate_trials(data, times, 'stimulus_times', S)
%
%       Optionally provide a list of times at which stimuli start (each
%       bout is assumed to last until the next one starts.
%
%   [output, summary] = separate_trials(data, times, 'plot', 3)
%
%       Plot to figure 3.
%
%   [output, summary] = separate_trials(data, times, 'labels', labels)
%
%       labels: cell array of strings labeling the columns of data
%           collected
%
%   [output, summary] = separate_trials(data, times, 'plot', [])
%
%       Suppress plotting.
%
%   [output, summary] = separate_trials(data, times, 'normalize_each', true)
%
%       Normalize each trial's data to span the range [0, 1].  This is
%       useful when conditions change between repititions (e.g. bleaching).


input_options = varargin2struct(varargin{:}); 

default_options = struct( ...
    'plot', 1, ...
    'stimulus_times', [], ...
    'npoints', 1, ...
    'labels', [], ...
    'normalize_each', false ...
    );

options = mergestruct(default_options, input_options);

if isempty(options.stimulus_times)
    dt = diff(times);
    t0 = min(dt);
    t1 = max(dt);
    dt_thresh = t0 + 0.5*(t1-t0);
    
    stimulus_indices = [1; find(dt > dt_thresh)+1];
    stimulus_times = times(stimulus_indices);
else
    stimulus_times = options.stimulus_times;
end

stimulus_times(end+1) = Inf;
min_duration = Inf;

all_sample_times = [];

for i = 1:length(stimulus_times)-1
    
    indices = (times >= stimulus_times(i)) & ...
              (times < stimulus_times(i+1));
    output(i).times = times(indices);
    output(i).data = data(indices, :);
    
    % Keep track of the shortest common duration for response alignment
    duration = output(i).times(end) - output(i).times(1);
    if  duration < min_duration
        min_duration = duration;
    end
    
    all_sample_times = [all_sample_times; diff(output(i).times)];
    
end

if nargout == 2
    
    N_trials = length(output);
    
    mean_sample_time = mean(all_sample_times);
    reference_times = linspace(0, min_duration, ...
                               round(min_duration/mean_sample_time));
    
    resampled_data = nan(length(reference_times), size(data, 2), N_trials);
    
    for i = 1:N_trials
        trial_time = output(i).times - output(i).times(1);
        
        x = interp1(trial_time, output(i).data, reference_times);
        
        if options.normalize_each
            for j = 1:size(x,2)
                x(:,j) = x(:,j) - min(x(:,j)); % now min = 0
                x(:,j) = x(:,j) / max(x(:,j)); % now max = 1
            end
        end
        
        resampled_data(:,:,i) = x;
    end
    
    summary.times = reference_times;
    summary.resampled_data = resampled_data;
    summary.average_data = mean(resampled_data, 3);
    
end

if ~isempty(options.plot)
    
    N_trials = length(output);
    N_features = size(data,2);
    
    figure(options.plot); clf;
    t = summary.times;
    
    for i = 1:N_features
        subplot(N_features, 1, i); hold on;
        for j = 1:N_trials
            plot(t, summary.resampled_data(:,i,j), ...
                    'Color', 0.7 * [1 1 1]);
        end
        plot(t, summary.average_data(:,i), ...
                'LineWidth', 3);
            
        if ~isempty(options.labels)
            title(options.labels{i});
        end
            
        ylimits = [min(summary.average_data(:,i)) ...
                max(summary.average_data(:,i))];
        yrng = ylimits(2) - ylimits(1);
           
        ylim([ylimits(1) - 0.1*yrng, ylimits(2) + 0.1*yrng]);
    end
end

end