function intensities = get_intensity(features, image_location, varargin)
% takes in a cell array of features with fields size and coordinates and 
% returns an array with the brightness of the features as columns.
%
% using the 10 brightest points:
% intensities = get_intensity(features, tif_directory, 'npoints', 10)
%
% using the 10% brightest points (default):
% intensities = get_intensity(features, tif_directory, 'fraction', 0.1)
%
% use the 10 brighest points of the entire image (not using a subregion)
% intensities = get_intensity(features,tif_directory,'npoints',10)
%
% to use the data currently in the global feature_annotator_data,
%   intensities = get_intensity();
%
% to plot to figure N,
%   intensities = get_intensity([], [], 'plot', N)
%
% to supress plotting,
%   intensities = get_intensity([], [], 'plot', []);

input_options = varargin2struct(varargin{:}); 

if nargin < 2 || isempty(image_location)
    global feature_annotator_data;
    image_location = feature_annotator_data.image_location;
    if nargin < 1 || isempty(features)
        features = feature_annotator_data.features;
    end
    if isnumeric(features)
        features = feature_annotator_data.features(features);
    end
end

size_T = get_size_T(image_location);

default_options = struct( ...
    'plot', 1, ...
    'fraction', 0.1, ...
    'npoints', 1, ...
    'filter', [], ...
    'times', [1:size_T], ...
    'debug_timing', false ...
);

options = mergestruct(default_options, input_options);

size_T = length(options.times);
L = length(features);

intensities = NaN(size_T, L);

parfor k = 1:size_T
    t = options.times(k);
    
    im = load_image(image_location, 't', t, input_options);

    if ~isempty(options.filter)
        im = imfilter(im, options.filter);
    end

    for i = 1:L
        feature = features{i};
        
        if ~isfield(feature, 'is_bad_frame') || ...
           ~feature.is_bad_frame(t)
            
            try
                total_points = prod(feature.size+1);

                npoints = ceil(max(options.npoints, ...
                    options.fraction * total_points));

                if isempty(feature)
                    section = im;
                else
                    section = get_feature_image(t, feature, im);
                end

                vals = row(section);
                vals = sort(vals, 'descend');
                intensities(k, i) = round(mean(vals(1:npoints)));
                
            catch 
                
                warning(['Error occured getting the intensity for ' ...
                    'feature ' num2str(i) ' in frame ' num2str(t) ...
                    ' Replacing with NaN.']);
                
            end
            
        end
        
    end
    
    if options.debug_timing
        
        disp(['Frame ' num2str(t) ' completed.']);
        
    end
    
end

if ~isempty(options.plot)
    figure(options.plot); clf;
    plot(intensities);
    labels = cellfun(@(x) x.name, features, 'UniformOutput', false);
    legend(labels);
end