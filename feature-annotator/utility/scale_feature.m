function output_feature = scale_feature(feature, N, varargin)
% output_feature = scale_feature(feature, [Ny, Nx, (Nz), Nt])
%
% Takes a feature and updates coordinates to match scaling by spatial
% factors of Ny along the rows, Nx along the columns, and Nt in the final
% direction (time).  Nz is necessary if it is a 3D feature.
%
% Decimation destroys information:
%
% x == scale_feature(scale_feature(x, [2 3 4 5]), [1/2 1/3 1/4 1/5]))
% x ?= scale_feature(scale_feature(x, [1/2 1/3 1/4 1/5]), [2 3 4 5]))


default_options = struct(...
                    'additional_time_points', 0);
input_options = varargin2struct(varargin{:}); 
options = mergestruct(default_options, input_options);

output_feature = feature;

N_t = N(end);
N = N(1:end-1);

if isfield(feature, 'size')
    output_feature.size = floor(feature.size .* N);
end

if isfield(feature, 'ref_offset')
    output_feature.ref_offset = floor(feature.ref_offset .* N);
end

% decimation in time
if N_t < 1
    
    N_t = 1/N_t; % *** N_t is now the decimation factor, an integer ***
    if mod(N_t, 1) ~= 0
        error('Decimation by non-integer time factors is not supported');
    end

    if isfield(feature, 'coordinates')
        size_T  = size(feature.coordinates,1);

        N2 = kron(N, ones(size_T, 1));

        % scale the coordinates
        c = feature.coordinates .* N2 - floor(N2./2);

        % decimate using a rectangular filter
        c = convn(c, ones(N_t,1));
        c = round(c(N_t:N_t:end-N_t+1,:)); 

        output_feature.coordinates = c;
    end

    if isfield(feature, 'modified_coordinates')
        size_T  = size(feature.modified_coordinates,1);

        N2 = kron(N, ones(size_T, 1));

        % scale the modified_coordinates
        c = feature.modified_coordinates .* N2;

        % decimate using a rectangular filter
        c = convn(c, ones(N_t,1));
        c = round(c(N_t:N_t:end-N_t+1,:)); 

        output_feature.modified_coordinates = c;
    end

% expansion in time
else
    
    if mod(N_t, 1) ~= 0
        error('Scaling by non-integer time factors is not supported');
    end
    
    if isfield(feature, 'coordinates')
        size_T  = size(feature.coordinates,1);

        N2 = kron(N, ones(size_T, 1));

        % scale the coordinates
        c = round(feature.coordinates .* N2 - floor(N2./2));

        % expand using a rectangular filter
        c = kron(c, ones(N_t,1));
        
        % add additional time points if needed
        for t = 1:options.additional_time_points
            c(end+1, :) = c(end, :);
        end

        output_feature.coordinates = c;
    end

    if isfield(feature, 'modified_coordinates')
        size_T  = size(feature.modified_coordinates,1);

        N2 = kron(N, ones(size_T, 1));

        % scale the modified_coordinates
        c = round(feature.modified_coordinates .* N2);

        % expand using a rectangular filter
        c = kron(c, ones(N_t,1));
        
        % add additional time points if needed
        for t = 1:options.additional_time_points
            c(end+1, :) = c(end, :);
        end

        output_feature.modified_coordinates = c;
    end
end
