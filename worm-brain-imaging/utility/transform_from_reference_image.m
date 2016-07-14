function S = transform_from_reference_image(reference_image_filename, varargin)
% transform_from_reference_image(reference_image_filename)
%
%   Takes a reference image (stored as 2D array 'reference_image' within
%   the given matfile) and determines the transform to apply to the left
%   half to obtain the right half.  Each half is extended 10 pixels towards
%   the middle of the image.

default_options = struct(...
                    'save', false, ...
                    'output_file', reference_image_filename, ...
                    'overlap', 10 ...
                    );
input_options = varargin2struct(varargin{:}); 
options = mergestruct(default_options, input_options);

S = load(reference_image_filename);

if ~isfield(S, 'left_tform')
    R = S.reference_image;

    crop_size = [size(R,1), size(R,2)/2 + options.overlap];

    left = R(:, 1:crop_size(2));
    right = R(:, end-crop_size(2)+1:end);

    [optimizer, metric] = imregconfig('monomodal');
    left_tform = imregtform(left, right, 'rigid', optimizer, metric);
    right_tform = imregtform(right, right, 'rigid', optimizer, metric);

    S.crop_size = crop_size;
    S.output_view = imref2d(crop_size, ...
                            [0.5 crop_size(2)+0.5], ...
                            [0.5 crop_size(1)+0.5]);
    S.left_tform = left_tform;
    S.right_tform = right_tform; % should be identity

    if options.save
        save(options.output_file, '-struct', 'S', '-v7.3');
    end
end
