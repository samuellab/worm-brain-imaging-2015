function [location, fit_quality, t_out] = lookup_feature_location(...
                                            feature, ...
                                            reference_features, ...
                                            t_ref, ...
                                            varargin)
% [location, fit] = lookup_feature_location(feature, references, t)
%
%   Guess the location of a feature based on where it was located in
%   previously registered frame.  The algorithm first finds a frame with
%   reference coordinates that match the current reference coordinates
%   (L1-distance based on pixel offsets).  The location of the feature to
%   fit along with the quality of fit are returned.
%
% [location, fit] = lookup_feature_location(... , 'metric', g)
%
%   Specify the metric.  Default is [1, 1, 4] corresponding to 4 times the
%   resolution in x,y compared to z.
%
% [location, fit] = lookup_feature_location(... , 'norm', @f)
%
%   Specify the norm given a matrix of reference displacements.  Default is
%   @(x) mean(sum(abs(metric*x))).

default_options = struct( ...
    'metric', diag([1, 1, 4]), ...
    'modified_only', false);

input_options = varargin2struct(varargin{:}); 
options = mergestruct(default_options, input_options);

if ~isfield(input_options, 'norm')
    options.norm = @(x) mean(sum(abs(options.metric*x)));
end

T = size(feature.coordinates, 1);
D = size(feature.coordinates, 2);
R = length(reference_features);

% Assume all the reference features are not registered and frames are not
% good.
for i = 1:length(reference_features)
    if ~isfield(reference_features{i}, 'is_registered')
        reference_features{i}.is_registered = zeros(1, T);
    end
    
    if ~isfield(reference_features{i}, 'is_bad_frame')
        reference_features{i}.is_bad_frame = zeros(1, T);
    end
end

% The feature must have the is_registered field to identify valid frames
% for lookup.
if ~isfield(feature, 'is_registered')
    location = nan(size(feature.coordinates(1,:)));
    fit_quality = 0;
    t_out = 0;
    return;
end

% Assume all frames are good for our feature.
if ~isfield(feature, 'is_bad_frame')
    feature.is_bad_frame = zeros(1, T);
end


% First determine the valid frames to use for lookup and store the relevant
% data in reference_coords and source_coords.
all_features = reference_features;
all_features{end+1} = feature;

ref_0 = get_all_feature_coordinates(reference_features, t_ref)';

reference_coords = zeros(D, R, 0);
source_coords = zeros(D, 1, 0);
t_idx = 1;

good_frames = [];
fit = [];
for t = 1:T
    frame_is_good = true;
    for i = 1:length(all_features)
        

        if ~all_features{i}.is_registered(t) || ...
            all_features{i}.is_bad_frame(t)
        
            frame_is_good = false;
            break
            
        end
        
    end
    
    if options.modified_only ...
       && isnan(feature.modified_coordinates(t,1))
        frame_is_good = false;
    end
    
    if frame_is_good
        good_frames = [good_frames t];
        
        c_ref = get_all_feature_coordinates(reference_features, t);
        reference_coords(:,:,t_idx) = c_ref';
        
        c_src = get_all_feature_coordinates({feature}, t);
        source_coords(:,1,t_idx) = c_src';
        
        fit(t_idx) = 1 ./ ...
            options.norm(ref_0 - squeeze(reference_coords(:,:,t_idx)));
        
        t_idx = t_idx + 1;
    end
end

[fit_quality, t_best] = max(fit);

if t_idx > 1
    location = reshape(source_coords(:,:, t_best), 1, D);
else
    location = [];
    fit_quality = 0;
end

if nargout > 2
    t_out = good_frames(t_best);
end