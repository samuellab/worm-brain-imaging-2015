function generate_filtered_images(target, source, varargin)
% Applies the current filter to each image in a time series to create a
% filtered version which is stored in the directory target.
%
% This will also normalize the values in the image to compensate for drift.
% The image is first filtered, then thresholded.  The remaining values are
% then scaled so the specified quantile falls at the specified reference
% value. (default threshold: 500, default quantile: 0.99, default reference
% value: 2048)

if nargin == 1
    global feature_annotator_data;
    source = feature_annotator_data.image_location;
end

default_options = struct(...
                    'filter', @feature_annotator_filter, ...
                    'intensity_compensation', true, ...
                    'threshold', 500, ...
                    'quantile', 0.9, ...
                    'reference_value', 2048, ...
                    'threshold_high', Inf, ...
                    'apply_threshold', true, ...
                    'reference_feature', [] ...
                    );

input_options = varargin2struct(varargin{:}); 
options = mergestruct(default_options, input_options);

size_T = get_size_T(source);

if ~exist(target, 'dir')
    mkdir(target);
    try
    copyfile(fullfile(source, 'features.mat'), ...
             fullfile(target, 'features.mat'));
    catch
        disp('No features copied.');
    end
end

if isempty(options.reference_feature)
    
    load_im = @(t) clamp_intensity(load_image(source,'t',t), ...
        options.threshold_high);
    
else
    
    refs = options.reference_features;
    
    if isnumeric(refs)
        
        global feature_annotator_data;
        refs = feature_annotator_data.features(refs);
        
    end
    
    load_im = @(t) clamp_intensity(get_feature_image(t, ...
        options.reference_feature, source), ...
        options.threshold_high);
    
end


load_filtered = @(t) options.filter(load_im(t));
get_ref_intensity = @(im) ...
    quantile(double(row(im(im>options.threshold))), options.quantile);

if options.intensity_compensation
    if ~isempty(options.reference_value)
        ref0 = options.reference_value;
    else
        im0 = load_filtered(1);
        ref0 = get_ref_intensity(im0);
    end
end

for t = 1:size_T
    
    im = load_filtered(t);
    
    if options.intensity_compensation
        ref = get_ref_intensity(im); 
        
        if options.apply_threshold
            im(im<options.threshold) = 0;
        end
        
        im = uint16(double(im) .* ref0/ref);
    end
    
    save_tiff_stack(im, target, t);
    
end

