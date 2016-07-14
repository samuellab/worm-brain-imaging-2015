function filter_tiff_directory(fn, input_directory, output_directory)
% filter_tiff_directory(fn, input_directory, output_directory)
%
% loads each tiff file in input_directory, applies fn to the resulting
% array, then saves the output in output_directory
%
% if fn is an array of function handles, each is applied in sequence before
% saving to output_directory
%
% common example (works for 2D or 3D images):
% filter_tiff_directory(@(x) imresize(x,0.25), 'origin', 'destination')

if ~iscell(fn)
    fn = {fn};
end

in_files = dir(fullfile(input_directory, '*.tif*'));

for i = 1:length(in_files)
    im = load_tiff_stack(fullfile(input_directory,...
                                  in_files(i).name));
    for j = 1:length(fn)
        im = fn{j}(im);
    end
    
    save_tiff_stack(im, fullfile(output_directory,...
                             in_files(i).name));
end