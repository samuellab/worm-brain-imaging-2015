function [best_tform, best_lib, green_out, red_out, R, refdata] = ...
    align_to_library(green, red, lib, varargin)
% [tform, img] = align_to_library(img, lib, varargin)
%
%   Takes an image and attempts to transform it to match one of the images
%   in the directory lib. All images in lib should have the same size. The
%   transformed image will have the size of a library image.

default_options = struct(...
    'N_rotations', 8, ...
    'decimate', 1, ...
    'show_fit', false, ...
    'initial_tform', [], ...
    'threshold', .97 ...
);

input_options = varargin2struct(varargin{:}); 
options = mergestruct(default_options, input_options);

if isempty(options.initial_tform) && options.N_rotations == 0
    options.N_rotations = 1;
end

if isempty(options.initial_tform)
    options.initial_tform = {};
else
    options.initial_tform = {options.initial_tform};
end

green_small = imresize(max_intensity_z(green), 1/options.decimate);
red_small = imresize(max_intensity_z(red), 1/options.decimate);

lib_red = fullfile(lib, 'red');
lib_green = fullfile(lib, 'green');

lib_green_big = @(t) max_intensity_z(load_image(lib_green, 't', t));
lib_green_small = @(t) imresize(lib_green_big(t), 1/options.decimate);

lib_red_big = @(t) max_intensity_z(load_image(lib_red, 't', t));

red_filter = @(x) imfilter(x, fspecial('gaussian', 10, 3));

lib_red_small = @(t) imresize(lib_red_big(t), 1/options.decimate);

optimizer = registration.optimizer.OnePlusOneEvolutionary;

get_tform_MeanSquares = @(src, target, guess) ...
    imregtform(src, target, 'rigid', ...
        optimizer, ...
        registration.metric.MeanSquares, ...
        'PyramidLevels', 1, ...
        'InitialTransformation', guess);
get_tform_MutualInformation = @(src, target, guess) ...
    imregtform(src, target, 'rigid', ...
        optimizer, ...
        registration.metric.MattesMutualInformation, ...
        'PyramidLevels', 1, ...
        'InitialTransformation', guess);

lib_size = get_size_T(lib_green);
lib_im0 = lib_green_big(1);
S = size(lib_im0);

S_img = size(green_small);
offset = (size(lib_green_small(1)) - S_img)/2;

refdata = struct();
refdata.global_YWorldLimits = [0.5 0.5+S(1)];
refdata.global_XWorldLimits = [0.5 0.5+S(2)];
R = imref2d(S, refdata.global_XWorldLimits, refdata.global_YWorldLimits);

tform_guesses = options.initial_tform;
rotations = (1:options.N_rotations)*(2*pi/options.N_rotations);
for i = 1:length(rotations)
    tform_guesses{end+1} = rotation_tform(rotations(i), ...
        [S_img(2)/2, S_img(1)/2], ...
        [offset(2) offset(1)]);
end

best_fit = 0;
best_lib = 0;
best_tform = [];
for i = 1:length(tform_guesses)
    guess = tform_guesses{i};

    for j = 1:lib_size

        tf = get_tform_MeanSquares(green, lib_green_small(j), guess);

        tf_big = tf;
        tf_big.T(3,1:2) = tf_big.T(3,1:2)*options.decimate;

        new_im = imwarp(green, tf_big, 'OutputView', R);
        new_fit = ssim(new_im, lib_green_big(j));
        if new_fit > best_fit
            green_out = new_im;
            best_fit = new_fit;
            best_tform = tf_big;
            best_lib = j;
        end

        if options.show_fit

            figure(1); clf; 
            subplot(121);
            imshowpair(new_im, lib_green_big(j));
            title(['Fit: ' num2str(new_fit)]);
            subplot(122);
            imshowpair(green_out, lib_green_big(best_lib));
            title(['Best fit: ' num2str(best_fit)]);
            pause(.2);

        end

    end
    
    if ~isempty(options.initial_tform) && i == 1 ...
            && best_fit > options.threshold
        break
    end
end

best_tform = clean_rigid_transform(best_tform);

if options.adjust_tform
    
    best_tform = check_tform(best_tform, red, lib_red_big(best_lib), R);
    
end

best_fit = 0;
for j = 1:lib_size

    tf = get_tform_MeanSquares(red_filter(red), ...
        red_filter(lib_red_small(j)), ...
        best_tform);
    
    tf_big = tf;
    tf_big.T(3,1:2) = tf_big.T(3,1:2)*options.decimate;

    new_im = imwarp(red, tf_big, 'OutputView', R);
    new_fit = ssim(new_im, lib_red_big(j));
    if new_fit > best_fit
        red_out = new_im;
        best_fit = new_fit;
        best_tform = tf_big;
        best_lib = j;
    end

    if options.show_fit

        figure(1); clf; 
        subplot(121);
        imshowpair(new_im, lib_red_big(j));
        title(['Fit: ' num2str(new_fit)]);
        subplot(122);
        imshowpair(red_out, lib_red_big(best_lib));
        title(['Best fit: ' num2str(best_fit)]);
        pause(.2);

    end

end

green_out = imwarp(green, best_tform, 'OutputView', R);
red_out = imwarp(red, best_tform, 'OutputView', R);
tform_out = best_tform;

if options.show_fit

    figure(1); clf; 
    subplot(121);
    imshowpair(red_out, lib_red_big(best_lib));
    title('Red');
    subplot(122);
    imshowpair(green_out, lib_green_big(best_lib));
    title('Green');
    pause;

end

