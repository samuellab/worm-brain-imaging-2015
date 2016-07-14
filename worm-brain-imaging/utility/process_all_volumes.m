function process_all_volumes(tif_directory, output_directory, fn)
% process_all_volumes(tif_directory, fn)
%
%   Applies the given function to all volumes in a directory of image
%   stacks indexed T_#####.tif

size_T = get_size_T(tif_directory);

for t = 1:size_T
    
    vol = load_image(tif_directory, 't', t);
    vol = fn(vol);
    
    save_tiff_stack(vol, output_directory, t);
    
end