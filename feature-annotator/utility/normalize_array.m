function output = normalize_array(array, window, smoothing)
% array_output = normalize_array(array)
%   returns the array with mean subtracted and scaled by the standard
%   deviation, so sum_all(output.^2) == numel(array) - 1
%
% array_output = normalize_array(array,window)
%   returns an array that has been offset by local means and scaled by
%   local standard deviations so elements tend to fall between -1 and 1.
%
% array_output = normalize_array(array, window, smoothing)
%   output = (input - local means)/(local stds + smoothing * abs(global
%   mean))
%     Use this to keep the output small in regions where there is no
%     signal.

if ~isa(array,'double')
    array = double(array);
end

if ndims1(array) == 1
    array = interpolate_nans(array);
end

if nargin == 1
    array = double(array);
    output = (array - mean_all(array)) / std_all(array);
else
    [local_means, local_stds] = local_mean(array,window);

    
    if nargin == 3
        output = (array-local_means)./ ...
                 (local_stds + smoothing * abs(mean_all(array)));
    else
        output = (array-local_means)./local_stds;
    end
end