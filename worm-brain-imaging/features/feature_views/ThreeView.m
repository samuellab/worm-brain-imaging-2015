classdef ThreeView < matlab.mixin.SetGet
    %THREEVIEW Creates a view of three orthogonal projections from a
    %volume.

    properties

        % unscaled X image
        ImageX

        % unscaled Y image
        ImageY

        % unscaled Z image
        ImageZ

        % Lookup table.
        LUT

        % Sets pixel aspect ratio.
        PixelSize = [1, 1, 2]

    end

    properties (Access = protected)

        % Parent node.
        Root

        % Axes to draw image on.
        Axes
        
        Initialized = false

    end

    methods

        function obj = ThreeView(image_x, image_y, image_z, parent, LUT)
            % obj = THREEVIEW(image_x, image_y, image_z, parent, LUT)
            %
            %   Creates a view of three orthogonal slices and displays it.

            if nargin < 4
                parent = figure();
            end

            if nargin < 5
                LUT = [0, max_all(image_x, image_y, image_z)];
            end

            obj.Root = parent;

            obj.ImageX = image_x;
            obj.ImageY = image_y;
            obj.ImageZ = image_z; 

            obj.LUT = LUT;

            obj.Axes = axes('Visible','on', ...
                'Units', 'normalized', ...
                'Position', [0, 0, 1, 1], ...
                'Parent', obj.Root);

            obj.Initialized = true;
            obj.update();

        end

        function this = set.LUT(this, new_LUT)
            this.LUT = new_LUT;
            this.update();
        end
        
        function this = set.PixelSize(this, new_pixelsize)
            this.PixelSize = new_pixelsize;
            this.update();
        end

    end

    methods (Access = protected)

        function this = setLUT(this, new_LUT)
            this.LUT = new_LUT;
        end

        function update(this)
            
            if ~this.Initialized
                return
            end

            combined = orthoview_from_slices(...
                this.ImageX, ...
                this.ImageY, ...
                this.ImageZ, ...
                this.PixelSize);

            imshow(combined, this.LUT, 'Parent', this.Axes, ...
                'Border', 'tight');

        end

    end

    methods (Static)

        function obj = show_MIPs(A, varargin)
            % obj = THREEVIEW.SHOW_MIPS(A, parent, ...)
            %
            %   Use maximum intensity projections to create the view.

            image_x = max_intensity_x(A);
            image_y = max_intensity_y(A);
            image_z = max_intensity_z(A);

            obj = ThreeView(image_x, image_y, image_z, varargin{:});

        end

    end

end