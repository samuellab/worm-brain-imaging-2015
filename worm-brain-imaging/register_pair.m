function [v2_registered, varargout] = register_pair(v1, v2, varargin)
% v2_registered = register_pair(v1, v2, options)
%   Warps the volume v2 to align with volume v1.
%
% [v2_registered, u] = register_pair(v1, v2, options)
%   Additionally returns the deformation field used to make v2_registered
%
% options:
%
%   'averaging_function' : function used to smooth image.
%       default : @(x) imfilter(x, ones(4,4,1)/16)
%
%   'weighting_function' : determines how much to weight a calculated
%       displacement a distance of sqrt(x) away from the current point
%       default : @(x) 1/(1+x)
%
%   'metric' : 3x3 matrix that specifies how to calculate distances between
%       points in the image.
%       default : diag([1 1 4])

default_options = struct( ...
    'metric', diag([1 1 4]), ...
    'averaging_function', @(x) imfilter(x, ones(4,4,1)/16, 'symmetric'),...
    'weighting_function', @(x) 1/(1+x));

input_options = varargin2struct(varargin{:}); 
options = mergestruct(default_options, input_options);

avg = options.averaging_function;
avg = @feature_annotator_filter;
w = options.weighting_function;
g = options.metric;

% noise rejection
v1_raw = double(v1);
v2_raw = double(v2);

v1_filtered = avg(v1_raw);
v2_filtered = avg(v2_raw);

v1 = v1_raw.*(v1_filtered > quantile(row(v1_filtered),.95));
v2 = v2_raw.*(v2_filtered > quantile(row(v2_filtered),.95));

v1 = normalize_array(v1,round(size(v1)/8), 2);
v2 = normalize_array(v2,round(size(v2)/8), 2);

% configure fit
if isfield(options, 'u_initial')
    u = options.u_initial;
else
    u = cell(numel(v1),1);
end

iter = 2 ;
target{1} = v2;
section_size = [16 16 16]/g;
d_idx = 1;

k_max = 1;
for k = 1:k_max
    dv = avg((target{iter-1} - v1).^2);
    
    for j = 1:5
        [y, x, z] = ind2sub(size(dv), find(dv==max_all(dv)));
        d{d_idx, 1} = [y x z];
        feature = get_image_section([y x z] - round(section_size/2), ...
                                    section_size, ...
                                    v1);
        [indices, feature, fit, all_fits] =  ...
            locate_feature_ND_corrcoef(feature, v2, [y x z], section_size);
        d{d_idx,2} = indices;
        
        dv = set_image_section(dv, ...
                               [y x z] - round(section_size/2),...
                               zeros(section_size));
        d_idx = d_idx + 1;
    end
    
    parfor i = 1:numel(v1)
        [y x z] = ind2sub(size(v1), i);
        total_weight = 0;
        u_new = [0 0 0];
        for j = 1:size(d,1)
            distance = (d{j,1}-[y x z])*g*(d{j,1}-[y x z])';
            weight = w(distance);
            total_weight = total_weight + weight;
            u_new = u_new + weight * (d{j,2}-d{j,1});
        end
        u{i} = u_new / total_weight;
    end
    u = reshape(u,size(v1));
    
    if k < k_max
        target{iter} = field_deform(v2,u,'direction',-1);
    end
    iter = iter + 1;
end

v2_registered = field_deform(v2_raw,u,'direction',-1);

if nargout == 2
    varargout{1} = u;
end
