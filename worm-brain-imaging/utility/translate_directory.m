function translate_directory(path, d, varargin)
% translate_directory(path, d)
%
%    translates the time series of duration T in path by the TxD offsets
%    specified in d.
%
% translate_directory(path, d, 'output_directory', 'outdir')
%
%     places the output in outdir


default_options = struct(...
                        'output_directory', fullfile(path,'translated') ...
                        );
input_options = varargin2struct(varargin{:}); 
options = mergestruct(default_options, input_options);

size_T = length(dir(fullfile(path,'T_*')));

assert(size_T == size(d,1));

for t = 1:size(d,1)
    
    x = load_tiff_stack(path, t);
    y = subpixel_translate(x, d(t,:));
    
    save_tiff_stack(y, options.output_directory, t);
end