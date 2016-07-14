classdef PointFeature < Feature
    %POINTFEATURE Feature characterized by a point in a volume.

    properties (SetAccess = immutable)

        Coordinates

        Time

    end

    methods

        function obj = PointFeature(coordinates, time, varargin)
            % obj = POINTFEATURE(location, time, image, creator, name)

            obj = obj@Feature(varargin{:});
            obj.Coordinates = coordinates;
            obj.Time = time;

        end

        function x = get_center(this)
            % x = obj.GET_CENTER()
            %
            %   Returns the center of this feature.

            x = this.Coordinates;

        end

        function t = get_time(this)
            % t = obj.GET_TIME()
            %
            %   Returns the time coordinaten of this feature.

            t = this.Time;

        end

        function A = get_slice(this)
            % A = obj.GET_SLICE()
            %
            %   Returns the full slice of obj.Image corresponding to time
            %   obj.Time.

            A = get_slice(this.Image, this.Time);

        end

        function y = get_image(this, s)
            % y = obj.GET_IMAGE(s)
            %
            %   Return a volume of size s centered around the feature
            %   location.

            slice = this.get_slice();
            coords = this.Coordinates;

            y = get_centered_section(coords, s, slice);

        end

        function c = get_color(this)
            % c = obj.GET_COLOR()
            %
            %   Returns a color associated to this feature. By default, it
            %   is determined by the feature's name.

            c = random_color('seed', this.Name);

        end

        function im = draw_on_x_slice(this, im)
            % image_x = obj.DRAW_ON_X_SLICE(image_x)
            %
            %   Place an annotation on an image corresponding to a slice in
            %   the x-direction through the original volume.

            coords = this.get_center();

            color = this.get_color();
            color = set_color_class(color, element_class(im));

            im = insertMarker(im, ...
                [coords(3), coords(1)], ...
                'o', ...
                'Color', color);

        end

        function im = draw_on_y_slice(this, im)
            % image_y = obj.DRAW_ON_Y_SLICE(image_y)
            %
            %   Place an annotation on an image corresponding to a slice in
            %   the y-direction through the original volume.

            coords = this.get_center();

            color = this.get_color();
            color = set_color_class(color, element_class(im));

            im = insertMarker(im, ...
                [coords(2), coords(3)], ...
                'o', ...
                'Color', color);

        end

        function im = draw_on_z_slice(this, im)
            % image_z = obj.DRAW_ON_Z_SLICE(image_z)
            %
            %   Place an annotation on an image corresponding to a slice in
            %   the z-direction through the original volume.

            coords = this.get_center();

            color = this.get_color();
            color = set_color_class(color, element_class(im));

            im = insertMarker(im, ...
                [coords(2), coords(1)], ...
                'o', ...
                'Color', color);

        end

        function obj = clone_feature(this, varargin)
            % obj = PointFeature.from_feature('Name', 'AFD')
            %
            %   This copies a feature, allowing properites be modified in
            %   the process.

            input_options = varargin2struct(varargin{:}); 

            default_creator = struct(...
                'Method', 'Clone', ...
                'Parent', this, ...
                'Options', input_options);

            default_options = struct(...
                'Coordinates', this.Coordinates, ...
                'Time', this.Time, ...
                'Image', this.Image, ...
                'Name', this.Name, ...
                'Creator', default_creator ...
            );

            options = mergestruct(default_options, input_options);

            obj = PointFeature(...
                options.Coordinates, ...
                options.Time, ...
                options.Image, ...
                optiosn.Creator, ...
                options.Name);

        end

    end

end

