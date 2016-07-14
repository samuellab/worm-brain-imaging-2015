function output_feature = ...
    track_correlation(input_feature, tif_directory, varargin)
% allows you to choose a feature in the key frames of a time series, then
% track the feature from frame to frame.

global feature_annotator_data;

size_T = length(dir(fullfile(tif_directory,'T_*')));
im1 = load_tiff_stack(fullfile(tif_directory,sprintf('T_%05d.tif',1)));

if nargin == 3
    options = varargin2struct(varargin{:});
    
    if isfield(options,'xy_filter')
        xy_filter = options.xy_filter;
    else
        xy_filter = 1;
    end
    
    if isfield(options,'t_filter')
        t_filter = options.t_filter;
    else
        t_filter = 1;
    end
    
    if isfield(options,'threshold')
        threshold = options.threshold;
    else
        threshold = nan;
    end
    
    % search radius (elastic penalty)
    if isfield(options, 'drift')
        drift = options.drift;
    else
        drift = size(im1)/10; %pixels
    end
    
    % limit the time spent on this computation
    if isfield(options, 'timeout')
        timeout = options.timeout;
    else
        timeout = Inf; %seconds
    end
    
    % plot the fit function in figure 3040
    fit_figure = 3040;
    if isfield(options, 'plot_fit')
        plot_fit = options.plot_fit;
    else
        plot_fit = false;
    end
    
    % learning rate for feature rotation/reshaping
    % this is the frequency at which the feature will change beyond what
    % can be compensated with translations (simple IIR filter)
    if isfield(options,'learning_rate')
        learning_rate = options.learning_rate;
    else
        learning_rate = 0; % between 0 and 1
    end
    
    if isfield(options,'debug_timing')
        debug_timing = options.debug_timing;
    else
        debug_timing = true;
    end
    
end
    
size_T = length(dir(fullfile(tif_directory,'T_*')));

im1 = load_tiff_stack(fullfile(tif_directory,sprintf('T_%05d.tif',1)));


feature_size = input_feature.size; % this is one less than the actual size
offset_to_center = round(0.5*feature_size);

% modified (or control) points
m = input_feature.modified_coordinates;
[i, j] = ind2sub(size(m), find(~isnan(m)));
input_times = unique(i);
input_times(end+1) = size_T+1;

output_feature = input_feature;

runtime = tic;
for i = 1:length(input_times)-1
    start_time = input_times(i);
    end_time = input_times(i+1)-1;
    
    output_feature.coordinates(start_time,:) = m(start_time,:);
    
    feature_location = m(start_time,:);
    
    % determine the initial feature for matching
    im = load_tiff_stack(fullfile(...
                            tif_directory, ...
                            sprintf('T_%05d.tif',start_time)));
    feature_image = double(get_image_section( ...
                    feature_location, feature_size, im));
    f_1d = reshape(feature_image, 1, numel(feature_image));
    f = (feature_image - mean(f_1d))./std(f_1d);
    
    for t = start_time+1:end_time
        
        if debug_timing
            disp(['Analyzing frame ' num2str(t) ...
                  ',  processing time: ' num2str(toc(runtime))]);
        end
        
        % determine f, the nomalized feature to use for matching, using the
        % image from the previous time step
        im = load_tiff_stack(fullfile(...
                                tif_directory, ...
                                sprintf('T_%05d.tif',t-1)));
        feature_image = (1-learning_rate) * feature_image + ...
                        learning_rate * double(get_image_section( ...
                                     feature_location, feature_size, im));
        f_1d = reshape(feature_image, 1, numel(feature_image));
        f = (feature_image - mean(f_1d))./std(f_1d);
        
       
        
        % get the image for the current step
        im = double(load_tiff_stack(fullfile(...
                            tif_directory, ...
                            sprintf('T_%05d.tif',t))));
        if xy_filter ~= 1
            im = imfilter(im,xy_filter);
        end
        if t_filter ~= 1
            warning('t filtering not implemented yet');
        end
        if ~isnan(threshold)
            warning('threshold is not used for intensity tracking');
        end
        
         if debug_timing
            disp(['starting normalization. frame ' num2str(t) ...
                  ',  processing time: ' num2str(toc(runtime))]);
        end
        
        % do local normalization of the image
        [mu, s] = local_mean(im, feature_size+1);
        im = (im-mu)./s; 
        
        if debug_timing
            disp(['Starting imfilter ' num2str(t) ...
                  ',  processing time: ' num2str(toc(runtime))]);
        end

        
        % correlate feature with image
        im = imfilter(im,f,'corr','same');
        
        if debug_timing
            disp(['Finished imfilter ' num2str(t) ...
                  ',  processing time: ' num2str(toc(runtime))]);
        end
        
        
        % make a circular gaussian mask to penalize large drifts
        guess = feature_location + offset_to_center;
        mask = ones(size(im));
        XN = cell(1,ndims(im));
        for j=1:ndims(im)
            gv{j} = 1:size(mask,j);
        end
        [XN{:}] = ndgrid(gv{:});
        for j=1:ndims(im)
            mask = mask.*exp(-((XN{j} - guess(j)).^2/(2*drift(j)^2)));
        end 
        im = double(im).*mask;
        
        if plot_fit
            figure(fit_figure); imagesc(im)
        end
        

        % choose the brightest point
        k = cell(1,ndims(im));
        [k{:}] = ind2sub(size(im),find(im==max_all(im),1));
        new_feature_location = cell2mat(k) - offset_to_center;
        output_feature.coordinates(t,:) = new_feature_location;
        
        % plot to feature_annotator
        if isstruct(feature_annotator_data)
            feature_annotator_data.t = t;
            feature_annotator_callbacks('Update_Image');
            
            rectangle('Position', ...
                        [ output_feature.coordinates(t,2) ... % x
                          output_feature.coordinates(t,1) ... % y
                          feature_size(2)+1 ... % width
                          feature_size(1)+1 ... % height
                        ], ...
                      'LineWidth', 2,...
                      'EdgeColor', [1 0 1], ...
                      'Parent', feature_annotator_data.gui.axes1);
        end
        
        % if we've been running too long, return
        if toc(runtime) > timeout
            return;
        end
        
        % update feature location for next iteration
        feature_location = new_feature_location;        
        
    end
end
