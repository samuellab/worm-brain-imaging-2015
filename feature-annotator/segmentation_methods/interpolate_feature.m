function output_feature = interpolate_feature(input_feature, tif_directory, varargin)
% linearly interpolates keyframes 

if nargin == 3
    options = varargin{1};
    
    
    % limit the time spent on this computation
    if isfield(options, 'timeout')
        timeout = options.timeout;
    else
        timeout = Inf; %seconds
    end
    
end

size_T = length(dir(fullfile(tif_directory,'T_*')));

im1 = load_tiff_stack(fullfile(tif_directory,sprintf('T_%05d.tif',1)));

size_X = size(im1,2);
size_Y = size(im1,1);

if ndims(im1) == 3
    size_Z = size(im1,3);
else
    size_Z = 1;
end

feature_size = input_feature.size; % this is one less than the actual size
offset_to_center = round(0.5*feature_size);

% modified (control) points
m = input_feature.modified_coordinates;
[i, j] = ind2sub(size(m), find(~isnan(m)));
input_times = unique(i);

output_feature = input_feature;

runtime = tic;
for start_index = 1:length(input_times)-1
    start_time = input_times(start_index);
    end_time = input_times(start_index+1)-1;
    
    output_feature.coordinates(start_time,:) = m(start_time,:);
    output_feature.coordinates(end_time+1,:) = m(end_time+1,:);
    
    feature_location_start = m(start_time,:);
    feature_location_end = m(end_time+1,:);
    
    for t = start_time+1:end_time
        
        i = interp1([start_time end_time+1], [feature_location_start(1) ...
                                             feature_location_end(1)],t);
        j = interp1([start_time end_time+1], [feature_location_start(2) ...
                                             feature_location_end(2)],t);
        if size_Z > 1
            k = interp1([start_time end_time+1], ...
                        [feature_location_start(3) ...
                                feature_location_end(3)],...
                        t);
            new_feature_location = [i j k];
        else
            new_feature_location = [i j];
        end
        
        
        
        
        output_feature.coordinates(t,:) = round(new_feature_location);
        
        feature_location = new_feature_location;
        
        % if we've been running too long, return
        if toc(runtime) > timeout
            return;
        end
    end
end