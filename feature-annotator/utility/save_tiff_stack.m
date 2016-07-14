function save_tiff_stack(volume, filename, idx)
% save_tiff_stack(volume, filename)
% takes a volume and saves it as a tiff stack
%
% save_tiff_stack(volume, directory, 34)
% filename is directory/T_00034.tif

[~, ~, E] = fileparts(filename);

if isempty(E)
    if ~exist(filename, 'dir')
        mkdir(filename);
    end
    filename = fullfile(filename, sprintf('T_%05d.tif', idx));
end

if exist(filename,'file')
    warning([filename ' exists.  Replacing!']);
    delete(filename);
end

% make the directory for our file if it doesn't exist
PATH = fileparts(filename);
if ~exist(fullfile(PATH),'dir')
    mkdir(fullfile(PATH));
end

switch ndims(volume)
    case 3
        for i=1:size(volume,3)
            imwrite(volume(:,:,i),filename,...
                'WriteMode', 'append',...
                'Compression', 'none');
        end
    otherwise
        imwrite(volume, filename, ...
                'Compression', 'none');
end

end