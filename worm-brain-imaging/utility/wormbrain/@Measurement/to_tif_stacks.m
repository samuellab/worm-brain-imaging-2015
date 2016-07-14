function to_tif_stacks(this, varargin)
% obj.TO_TIF_STACKS()
%
%   Export each channel to a folder of tif stacks.
%
% obj.TO_TIF_STACKS('location', location)
%
%   Export each time slice to an individual tif file in the specified
%   directory.
%
% obj.TO_TIF_STACKS('channels', channels)
%
%   Only export the data in specified channels.

import structtools.*;

default_options = struct(...
    'location', this.Name, ...
    'channels', 1:this.size_C(), ...
    'overwrite', false ...
);
input_options = varargin_to_struct(varargin{:});
options = merge_struct(default_options, input_options);

FILENAME_FORMAT = 'T_%05d.tif';

for c = options.channels

    channel_name = this.get_channel_name(c);
    channel_dir = fullfile(options.location, channel_name);

    if ~exist(channel_dir, 'dir')  
        mkdir(channel_dir);
    end

    for t = 1:this.size_T()

        filename = fullfile(channel_dir, sprintf(FILENAME_FORMAT, t));

        if exist(filename, 'file') && ~options.overwrite
            warning(['File ' filename ' exists. Skipping.']);
            continue
        end

        vol = this.get_vol(c, t);

        for z = 1:size(vol, 3)
            imwrite(vol(:,:,z), filename, ...
                'WriteMode', 'append', ...
                'Compression', 'none');
        end

    end

end