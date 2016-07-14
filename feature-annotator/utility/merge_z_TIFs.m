function merge_z_TIFs(input_TIF_directory, output_TIF_directory, varargin)
% If the files in TIF_directory are labeled *t###z##.tif, this will
% rearrange the into TIF stacks labeled T#####.tif (bringing all the
% z-slices together).
%
% This is useful if tifs are generated and named using NIS elements

opts = varargin2struct(varargin{:});

  

files = dir(fullfile(input_TIF_directory,'*.tif'));

[path name ext] = fileparts(files(1).name);
t_ind = strfind(name,'t');
t_ind = t_ind(end); % last location of t
z_ind = strfind(name,'z');
z_ind = z_ind(end); % last location of z

t_ind = (t_ind+1):(z_ind-1);
z_ind = (z_ind+1):length(name);

size_T = str2num(files(end).name(t_ind));
size_Z = str2num(files(end).name(z_ind));

for t = 1:size_T
    output_file = fullfile(output_TIF_directory,sprintf('T_%05d.tif',t));
    for z = 1:size_Z
        input_file = fullfile(input_TIF_directory,...
                              files(((t-1)*size_Z+z)).name);
        im = imread(input_file);
        imwrite(im,...
            output_file,...
            'WriteMode', 'append',...
            'Compression', 'none');
        %delete(input_file);
    end
end

if isfield(opts,'duration')
    times.offset = 0; % should be the start time of the stack
    times.times = linspace(0,opts.duration,size_T)';
    savejson('',times,fullfile(output_TIF_directory,'times.json'));
end