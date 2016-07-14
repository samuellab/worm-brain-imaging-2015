function [indices, varargout] = locate_feature_ND_corrcoef(feature, vol, guess, drifts)
% Takes in a ND feature array of uint type and determines the location of
% the feature in the ND image vol.
%
% The output coordinates refer to the center of the feature's location in 
% 'vol'.
%
% 'vol' is padded with the mean value of its (N-1)D boundary to accomodate
% searching for features near boundaries
%
% [indices,new_feature] = locate_feature_ND(feature,vol) returns the subset
% of 'vol' containing the recognized feature.  The recognized feature can
% include pixels not present in 'vol' if the feature was found near a
% boundary.
%
% [indices,new_feature,fit] = locate_feature returns the correlation
% coefficient for the best fit
%
% [indices,new_feature,fit,all_fits] = locate_feature returns an image
% with the same size as vol containing fit values for each position.
%
% guess is an optional input that contains a guess for the initial location
% of the feature.  it should be the center point of the guess, and have the
% format [guess_y guess_x guess_z] for a 3D guess
%
% drifts is an optional input that will penalize large excursions.
% drifts = [drift_y drift_x drift_z] contains the largest expected
% frame-to-frame shift in each of the three directions.  They're used as
% widths in a Gaussian penalty applied to correlation coefficients, and
% will show up in the all_fits output (if requested)
    
size_vol = size(vol);
N = length(size_vol); 

if nargin > 3
    mask = ones(size_vol);
    XN = cell(1,N);
    for j=1:N
        gv{j} = 1:size(mask,j);
    end
    [XN{:}] = ndgrid(gv{:});
    for j=1:N
        mask = mask.*exp(-((XN{j} - guess(j))/(2*drifts(j)^2)).^2);
    end 
end
mask_1D = reshape(mask,1,numel(mask));

% Determine the average value of border pixels
border_pixels = [];
for i=1:N
    for j=1:N
        if j==i
            idx{j} = [1 size_vol(j)];
        else
            idx{j} = [1:size_vol(j)];
        end
    end
    border_pixels = [border_pixels ...
                     reshape(vol(idx{:}), 1, numel(vol(idx{:}))) ...
                    ];
end
background_intensity = mean(border_pixels);
clear border_pixels;


% create a larger version of vol to allow features near edges. pad with
% the average value on the border pixels 
start_indices = round(size(feature)/2);
end_indices = start_indices + size_vol - 1;

for i=1:N
    idx{i} = start_indices(i):end_indices(i);
end

vol_large_size = size(feature)+size(vol)-1;
%vol_large_gpu = gpuArray.ones(vol_large_size)*background_intensity;
vol_large = uint16(ones(vol_large_size)*background_intensity);
vol_large(idx{:})=vol;
clear idx vol; % don't need this anymore



% search through the vol for best overlap.
correlation_coefficients = zeros(size_vol);
feature_1D = double(reshape(feature,1,numel(feature)));

thresholds = [1:-.00025:0.98 0.97:-.01:0.90];
best_so_far = 0;

for k = 2:length(thresholds)
current_min = thresholds(k);
current_max = thresholds(k-1);
correlation_coefficients_temp = zeros(size_vol);

parfor i=1:prod(size_vol)
    if mask_1D(i) > current_min && mask_1D(i) <= current_max
        lower_corner = cell(1,length(size_vol));
        [lower_corner{:}] = ind2sub(size_vol,i);
        start_indices = cell2mat(lower_corner);
        end_indices = start_indices + size(feature) - 1;
        idx = cell(1,length(size_vol));
        for j=1:N
            idx{j} = start_indices(j):end_indices(j);
        end

        section = vol_large(idx{:});
        r = corrcoef(double(reshape(section,1,numel(section))),...
                      feature_1D);
        correlation_coefficients_temp(i) = r(1,2);
    end
end
correlation_coefficients = correlation_coefficients + ...
                            correlation_coefficients_temp;
best_so_far(k) = max_all(correlation_coefficients);

%plot3D(correlation_coefficients)
if best_so_far(end) > 0.97 || (best_so_far(k) == best_so_far(k-1))
    break
end
end

correlation_coefficients = correlation_coefficients.*mask;

max_correlation = max_all(correlation_coefficients);

indices = subpixel_max_ND(correlation_coefficients);

% [max_correlation, linear_index] =  max(reshape(correlation_coefficients,...
%                                     1,numel(correlation_coefficients)));
% 
% indices = cell(1,length(size_vol));
% [indices{:}] = ind2sub(size_vol,linear_index);

if nargout > 1
%    start_indices = cell2mat(indices);
    start_indices = round(indices);
    end_indices = start_indices + size(feature) - 1;
    idx = cell(1,N);
    for j=1:N
        idx{j} = start_indices(j):end_indices(j);
    end
    varargout{1} = vol_large(idx{:});
end

if nargout > 2
    varargout{2} = max_correlation;
end

if nargout > 3
    varargout{3} = correlation_coefficients;
end
