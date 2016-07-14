classdef TIFFArray
    %TIFFARRAY Provides array accessing for tiff files in a directory.

    properties (SetAccess = immutable)

        % Directory of TIFF files indicating where the data is on disk.
        % Each time should be stored in the form T_00345.tif
        Directory

        Size

        ElementClass
        
        % Always the last dimension
        SlicedDimension

    end

    methods

        function obj = TIFFArray(directory)
            % x = TIFFARRAY(directory)
            %
            %   Creates a read-only array that provides access to the data
            %   stored as TIF files in directory. The slices should be
            %   stored in separate files, with the format T_00034.tif.

            obj.Directory = directory;

            size_T = length(dir(fullfile(directory, 'T_*')));

            tiff_info = imfinfo(obj.get_tiff_filename(1));
            size_X = tiff_info(1).Width;
            size_Y = tiff_info(1).Height;
            size_Z = length(tiff_info);

            if size_Z == 1
                obj.Size = [size_Y, size_X, size_T];
                obj.SlicedDimension = 3;
            else
                obj.Size = [size_Y, size_X, size_Z, size_T];
                obj.SlicedDimension = 4;
            end

            obj.ElementClass = sprintf('uint%d', tiff_info(1).BitDepth);

        end

        function [varargout] = subsref(this, S)

            % Determine which slices we will need to transform
            requested = S.subs{this.SlicedDimension};

            data = zeros([this.Size(1:end-1) length(requested)], ...
                this.ElementClass);

            idx = num2cell(repmat(':', 1, length(this.Size)));
            for i = 1:length(requested)

                idx{end} = i;
                data(idx{:}) = this.get_slice(requested(i));

            end

            new_S = S;
            new_S.subs{this.SlicedDimension} = ':';
            varargout{1} = subsref(data, new_S);

        end

        function data = get_slice(this, t)

            assert(numel(t)==1, ...
                'get_slice can only be called on single slices');

            tif_file = this.get_tiff_filename(t);
            
            if length(this.Size) == 3
                data = imread(tif_file);
            else
                data = zeros(this.Size(1:3), this.ElementClass);
                for i = 1:this.Size(3)
                    data(:,:,i) = imread(tif_file,i);
                end
            end

        end

        function s = size(obj)
            s = obj.Size;
        end

        function n = numel(obj)
            n = prod(obj.Size);
        end
        
        function n = ndims(this)
            n = length(this.Size);
        end

        function t = element_class(this)
            t = this.ElementClass;
        end

        function filename = get_tiff_filename(this, idx)
            filename = fullfile(this.Directory, ...
                sprintf('T_%05d.tif', idx));
        end

    end

end

