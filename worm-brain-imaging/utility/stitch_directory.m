function c = stitch_directory(tif_directory, stitch_sites, varargin)
%

default_options = struct(...
                    ...
                    );
input_options = varargin2struct(varargin{:}); 
options = mergestruct(default_options, input_options);


a = load_tiff_stack(fullfile(tif_directory, stitch_sites{1}.image_A));
b = load_tiff_stack(fullfile(tif_directory, stitch_sites{1}.image_B));

[c, ~, b_offset] = stitch_pair(a, b, 'a_ref', stitch_sites{1}.a_ref, ...
                                     'b_ref', stitch_sites{1}.b_ref, ...
                                     options);

for i = 2:length(stitch_sites)
    
    b = load_tiff_stack(fullfile(tif_directory, stitch_sites{i}.image_B));

    a_ref = stitch_sites{i}.a_ref + b_offset;
    b_ref = stitch_sites{i}.b_ref;
    
    [c,~, b_offset] = stitch_pair(c, b,'a_ref', a_ref, ...
                                       'b_ref', b_ref, ...
                                       options);
    
end