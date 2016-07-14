function convert_mat_to_TIF(mfile, varargin)
% Converts a matfile containing a variable called images into a directory
% with a tif stack for each slice of that variable (slicing in the last
% dimension).  Additional variables are stored as separate json objects,
% though they are accessible via the original matfile as well.

[directory, name, ext] = fileparts(mfile);

default_options = struct(...
                    'transformation_functions', {{@zyla_vol}}, ...
                    'output_names', {{'unprocessed_TIFs'}}, ...
                    'directory', directory ...
                    );
input_options = varargin2struct(varargin{:}); 
options = mergestruct(default_options, input_options);

f = matfile(mfile);
contents = whos(f);

times_idx = false;
for i = 1:length(contents)
    if strcmp(contents(i).name, 'times')
        times_idx = i;
    end
end

S = size(f.images);
N_outputs = length(options.transformation_functions);

mkdir(options.directory);

output_paths = {};
for i = 1:N_outputs
    output_paths{i} = fullfile(options.directory, options.output_names{i});
    mkdir(output_paths{i});
end

for t = 1:S(end)
    
    % Make a vector index to slice by the last dimension
    idx = {};
    for i = 1:length(S)-1
        idx{i} = ':';
    end
    idx{end+1} = t;
    vol = f.images(idx{:});
    
    for i = 1:N_outputs
        vol_to_write = options.transformation_functions{i}(vol);
        save_tiff_stack(vol_to_write, output_paths{i}, t);
    end
    
    if times_idx
        times_from_matfile(mfile, 'output_directory', output_paths{i});
    end
    
end