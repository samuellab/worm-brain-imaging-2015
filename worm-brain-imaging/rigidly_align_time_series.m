function rigidly_align_time_series(image_location, library, varargin)
% rigidly_align_time_series(tif_directory, reference_tree)
%
%   rigidly aligns the images in a tif directory, aligning image T to image
%   reference(T).  (reference(root) = 0).  the alignment only
%   uses max-intensity projections and rotates/translates in xy only.
%
% rigidly_align_time_series(tif_directory, reference_tree, ...
%                              'output_directory', D)
%
%   D specifies the location to store output images (default is
%   'rigidly_aligned')
%
% rigidly_align_time_series(tif_directory, reference_tree, ...
%                              'time_to_register', times)
%
%   Only register (and transform) the specified time indices.

size_T = get_size_T(image_location);
size_lib = get_size_T(library);

default_options = struct(...
    'output_directory',fullfile(image_location, ...
                                'rigidly_aligned'), ...
    'reference_directory', [], ...
    'times_to_register', 1:size_T ...
);

input_options = varargin2struct(varargin{:}); 
options = mergestruct(default_options, input_options);


if ~isempty(options.reference_directory)
    options.output_directory = options.reference_directory;
end

load_img = @(t) load_image(image_location, 't', t);
load_lib = @(t) load_image(library, 't', t);

load_img_z = @(t) max_intensity_z(load_img(t));
load_lib_z = @(t) max_intensity_z(load_lib(t));

optimizer = registration.optimizer.OnePlusOneEvolutionary();
optimizer.GrowthFactor = 1.0000000000001;
optimizer.InitialRadius = 6.25e-8;

get_tform = @(src, target) ...
    imregtform(src, target, 'rigid', ...
        registration.optimizer.RegularStepGradientDescent, ...
        registration.metric.MeanSquares, ...
        'PyramidLevels', 1);

if isempty(options.reference_directory)
    tform_dir = options.output_directory;
else
    tform_dir = options.reference_directory;
end
tform_from_file = @(i) load(fullfile(tform_dir, sprintf('u_%05d.mat', i)));


if isempty(options.reference_directory)
    
    % Prepare the referencing information
    ref_image = load_lib(1);
    S = size(ref_image);
    refdata = struct();
    refdata.global_YWorldLimits = [0.5 0.5+S(1)];
    refdata.global_XWorldLimits = [0.5 0.5+S(2)];
    R = imref2d(S, refdata.global_XWorldLimits, refdata.global_YWorldLimits);
    save(fullfile(tform_dir, 'WorldLimits.mat'), '-struct', 'refdata');

    % go through images and determine transforms to use.

    for i = 1:size_T

        im = load_img_z(i);
        fits = zeros(1, size_lib);
        
        for j = 1:size_lib
            
            im_lib = load_lib_z(j);
            
            
            
        end
    end
    identity = fitgeotrans([0, 0, 1; 0, 1, 0]', ...
                           [0, 0, 1; 0, 1, 0]', 'affine');
    [~, R{idx}] = imwarp(z0, identity);
    global_XWorldLimits = R{idx}.XWorldLimits;
    global_YWorldLimits = R{idx}.YWorldLimits;

    tform{idx} = identity;

    S.tform = tform{idx};
    S.R = R{idx};

    filename = fullfile(options.output_directory, ...
        sprintf('u_%05d.mat', idx));
    save(filename, '-struct', 'S');

    % now the rest
    for i = 2:length(image_order)

        idx = image_order(i);

        precomputed_tform = fullfile(...
           options.output_directory, sprintf('u_%05d.mat', idx));
        if exist(precomputed_tform, 'file') && ...
           ~ismember(idx, options.times_to_register)
       
            S = load(precomputed_tform);
            tform{idx} = S.tform;
            R{idx} = S.R;
            
            global_XWorldLimits(1) = min(global_XWorldLimits(1), ...
                                         R{idx}.XWorldLimits(1));
            global_XWorldLimits(2) = max(global_XWorldLimits(2), ...
                                         R{idx}.XWorldLimits(2));
            global_YWorldLimits(1) = min(global_YWorldLimits(1), ...
                                         R{idx}.YWorldLimits(1));
            global_YWorldLimits(2) = max(global_YWorldLimits(2), ...
                                         R{idx}.YWorldLimits(2));
            
            continue
        end
    
        src = load_image(idx);
        %target = load_image(reference(idx));
        target = z0;

        parent = reference(idx);
        guess = tform{parent};
        T = [];

        while parent && isempty(T)
            try
                T = get_tform(src, target, guess);
            catch
                T = [];
                parent = reference(parent);
                guess = tform{parent};
            end
        end
        %T.T = tform{reference(idx)}.T * T.T;
        tform{idx} = T;

        [~, R{idx}] = imwarp(src, tform{idx});

        global_XWorldLimits(1) = min(global_XWorldLimits(1), ...
                                     R{idx}.XWorldLimits(1));
        global_XWorldLimits(2) = max(global_XWorldLimits(2), ...
                                     R{idx}.XWorldLimits(2));
        global_YWorldLimits(1) = min(global_YWorldLimits(1), ...
                                     R{idx}.YWorldLimits(1));
        global_YWorldLimits(2) = max(global_YWorldLimits(2), ...
                                     R{idx}.YWorldLimits(2));

        S.tform = tform{idx};
        S.R = R{idx};

        filename = fullfile(image_location, sprintf('u%05d.mat', idx));
        save(filename, '-struct', 'S');
    end
else % we need the global world limits
    
    
    S = tform_from_file(1);
    global_XWorldLimits = S.R.XWorldLimits;
    global_YWorldLimits = S.R.YWorldLimits;
    
    for t = 2:size_T
        S = tform_from_file(t);
        R = S.R;
        global_XWorldLimits(1) = min(global_XWorldLimits(1), ...
                                     R.XWorldLimits(1));
        global_XWorldLimits(2) = max(global_XWorldLimits(2), ...
                                     R.XWorldLimits(2));
        global_YWorldLimits(1) = min(global_YWorldLimits(1), ...
                                     R.YWorldLimits(1));
        global_YWorldLimits(2) = max(global_YWorldLimits(2), ...
                                     R.YWorldLimits(2));
    end
    
    save(fullfile(image_location, 'WorldLimits'), 'global_XWorldLimits', ...
        'global_YWorldLimits');
end

% now apply the transforms, creating a sufficiently large target image

sample_vol = load_vol(1);
size_X = round(diff(global_XWorldLimits));
size_Y = round(diff(global_YWorldLimits));
size_Z = size(sample_vol, 3);
new_V = zeros(size_Y, size_X, size_Z, class(sample_vol));

for t = options.times_to_register
    
    S = tform_from_file(t);
    T = S.tform;
    r = S.R;
    
    r.XWorldLimits = global_XWorldLimits;
    r.YWorldLimits = global_YWorldLimits;
    r.ImageSize = [size_Y, size_X];
    
    V = load_vol(t);
    
    for z = 1:size(V, 3)
        im = imwarp(V(:,:,z), T, 'OutputView', r);
        new_V(:,:,z) = im;
    end
    save_tiff_stack(new_V, options.output_directory, t);
end