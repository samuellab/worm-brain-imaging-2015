classdef RawDataLoader
    %RAWDATALOADER Load images directly from camera data stored to disk
    %   This class handles transforming data loaded to disk into simple
    %   5-dimensional arrays that can be used for analysis.

    properties

        % Original filename containing raw data.
        Filename

        % Number of channels per volume.
        NChannels = 2;

        % Initial slice permutation. This can change over time.
        PermuteSlice = @(x) flip(x, 1);

        % Access raw data corresponding to each channel. This can change
        % over time.
        GetRawChannel = {...
            @(x) x(1:256, :, :), ...
            @(x) x(257:512, :, :) ...
        };

        % Functions to rotate the channels
        RotateChannel

    end

    methods

        function this = RawDataLoader(filename)

            this.Filename = filename;
            this.RotateChannel = {[], []};

        end

        function this = MakeChannelRotator(this, src, tgt, cal_file)
            % obj = MAKECHANNELROTATOR(obj, src, tgt, cal_file)
            %   
            %   Sets up channel 'src' to be rotated to align with channel
            %   'tgt', where the transformation is determined by data in
            %   the file 'cal_file'
            %
            % obj = MAKECHANNELROTATOR(obj, src, tgt)
            %   
            %   If no calibration file is specified, this method will
            %   attempt to find a file named 'calibration.mat' in the same
            %   directory as obj.Filename.

            % Default calibration file is 
            if nargin < 4
                [path, ~, ~] = fileparts(this.Filename);
                cal_file = fullfile(path, 'calibration.mat');
            end

            % Load the first field from the calibration file
            s = load(cal_file);
            f = fieldnames(s);
            raw_vol = s.(f{1});

            oriented_vol = this.PermuteSlice(raw_vol);

            chans = {};
            for i = 1:this.NChannels
                v = this.GetRawChannel{i}(oriented_vol);
                chans{i} = max(v, [], 3);
            end

            moving = chans{src};
            fixed = chans{tgt};
            [optimizer, metric] = imregconfig('monomodal');
            tform = imregtform(moving, fixed, 'rigid', optimizer, metric);

            target_size = size(fixed);

            this.RotateChannel{src} = @(x) ...
                imwarp(x, tform, 'OutputView', imref2d(target_size));

        end

        function z = GetChannel(this, channel)
            % z = GETCHANNEL(obj, channel)
            %   Returns a read-only CachedArray corresponding to the
            %   specified channel.

            if ~isempty(this.RotateChannel{channel})
                f = @(x) this.RotateChannel{channel}(...
                        this.GetRawChannel{channel}(...
                            this.PermuteSlice(x)));
            else
                f = @(x) this.GetRawChannel{channel}(this.PermuteSlice(x));
            end

            x = arraytools.MatfileArray(this.Filename, 'images');
            y = arraytools.LambdaArray(x, f);
            z = arraytools.CachedArray(y);

        end

    end

end

