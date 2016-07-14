function create_filtered_images(target, source, varargin)
% Applies the current filter to each image in a time series to create a
% filtered version which is stored in the directory target.

if nargin == 1
    global feature_annotator_data;
    source = feature_annotator_data.image_location;
end

default_options = struct(...
                    'filter', feature_annotator_filter, ...
                    'intensity_compensation', false ...
                    );

input_options = varargin2struct(varargin{:}); 
options = mergestruct(default_options, input_options);

size_T = get_size_T(source);

if ~exist(target, 'dir')
    mkdir(target);
end

load_filtered = @(t) options.filter(load_image(source,'t',t));
get_ref_intensity = @(im) ...
    mean_all(im(im > options.intensity_compensation));

if options.intensity_compensation
    im0 = load_filtered(1);
    ref0 = get_ref_intensity(im0);
end

for t = 1:size_T
    
    im = load_filtered(t);
    
    if options.intensity_compensation
        ref = get_ref_intensity(im);
        im = im .* ref0/ref;
    end
    
    save_tiff_stack(im, target, t);
    
end

