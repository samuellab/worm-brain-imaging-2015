function rigidly_align_time_series_150124(tif_directory, reference, varargin)
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

size_T = length(dir(fullfile(tif_directory,'T_*')));

default_options = struct(...
    'output_directory',fullfile(tif_directory, 'rigidly_aligned'), ...
    'reference_directory', [], ...
    'times_to_register', 1:size_T ...
);

input_options = varargin2struct(varargin{:}); 
options = mergestruct(default_options, input_options);

load_vol = @(i) load_tiff_stack(tif_directory, i);
load_image = @(i) max_intensity_z(...
                    feature_annotator_filter(...
                       load_vol(i)));

get_tform = @(src, target, guess) ...
                imregtform(src, target, 'rigid', ...
                  registration.optimizer.RegularStepGradientDescent, ...
                  registration.metric.MeanSquares, ...
                  'InitialTransform', guess);

if isempty(options.reference_directory)
    tform_dir = options.output_directory;
else
    tform_dir = options.reference_directory;
end

tform_filename = @(t) fullfile(tform_dir, sprintf('u_%05d.mat', t));
tform_from_file = @(t) load(tform_filename(t));

if isempty(options.reference_directory)
    
    % If reference is a single frame, make the parent pointer tree
    if length(reference) == 1
        root_idx = reference;
        reference = [];
        reference(root_idx) = 0;
        for i = root_idx-1:-1:1
            reference(i) = i + 1;
        end
        for i = root_idx+1:size_T
            reference(i) = i - 1;
        end
    end

    % topologically sort nodes to get an image order
    u = [];
    v = [];

    idx = 1;
    for i = 1:size_T
        if reference(i)
            u(idx) = reference(i);
            v(idx) = i;
            idx = idx + 1;
        end
    end

    dag = sparse(u, v, true, size_T, size_T, size_T);
    image_order = graphtopoorder(dag);

    % go through images and determine transforms to use.

    % first up: the root node
    idx = image_order(1);

    z0 = load_image(idx);
    identity = fitgeotrans([0, 0, 1; 0, 1, 0]', ...
                           [0, 0, 1; 0, 1, 0]', 'affine');
    [~, R{idx}] = imwarp(z0, identity);
    global_XWorldLimits = R{idx}.XWorldLimits;
    global_YWorldLimits = R{idx}.YWorldLimits;

    tform{idx} = identity;

    S.tform = tform{idx};
    S.R = R{idx};

    save(tform_filename(idx), '-struct', 'S');

    % now the rest
    for i = 2:length(image_order)
        
        idx = image_order(i);
        
        if exist(tform_filename(idx), 'file') && ...
           ~ismember(idx, options.times_to_register)
       
            S = tform_from_file(idx);
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

        save(tform_filename(idx), '-struct', 'S');
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
    
    save(fullfile(tform_dir, 'WorldLimits'), 'global_XWorldLimits', ...
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