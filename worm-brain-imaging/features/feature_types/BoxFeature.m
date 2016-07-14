classdef BoxFeature < PointFeature
    %BOXFEATURE Rectangular features that have a defined spatial extent.

    properties (SetAccess = immutable)

        Size

    end

    methods

        function obj = BoxFeature(size, varargin)
            % obj = BOXFEATURE(size, location, time, image, creator, name)

            obj@PointFeature(varargin{:});
            obj.Size = size;

        end

        function y = get_image(this, s)
            % y = obj.GET_IMAGE()
            %
            %   Return a volume of size obj.Size centered around
            %   obj.Coordinates.

            if nargin < 2
                s = this.Size;
            end

            y = get_image@PointFeature(this, s);

        end

        function obj = clone_feature(this, varargin)
            % obj = BoxFeature.from_feature('Name', 'AFD')
            %
            %   This copies a feature, allowing properites be modified in
            %   the process.

            input_options = varargin2struct(varargin{:}); 

            default_creator = struct(...
                'Method', 'Clone', ...
                'Parent', this, ...
                'Options', input_options);

            default_options = struct(...
                'Size', this.Size, ...
                'Coordinates', this.Coordinates, ...
                'Time', this.Time, ...
                'Image', this.Image, ...
                'Creator', default_creator, ...
                'Name', this.Name ...
            );

            options = mergestruct(default_options, input_options);


            obj = BoxFeature(...
                options.Size, ...
                options.Coordinates, ...
                options.Time, ...
                options.Image, ...
                options.Creator, ...
                options.Name);

        end

    end

end

