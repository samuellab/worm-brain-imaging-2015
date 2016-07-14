classdef BlobFeature < PointFeature
    %BLOBFEATURE Ellipsoid-like features with nonzero spatial extent.

    properties

        Size

    end

    methods

        function obj = BlobFeature(size, varargin)

            obj@PointFeature(varargin{:});
            obj.Size = size;

        end
        
        function vol = get_image(this)
            
            s = this.Size;
            c = this.Coordinates;
            
            for i = 1:length(this.Coordinates)
                idx{i} = (c(i) - s(i)/2):(c(i) + s(i)/2);
            end
            
            idx{end+1} = this.Time;
            
            vol = this.Image(idx{:});
            
        end

    end

end

