classdef FeatureCollectionViewer < matlab.mixin.SetGet
    %FEATURECOLLECTIONVIEWER Snapshot a collection of feaures that share a
    %common image.

    properties

        % Feature to display.
        FeatureCollection = []

        % Lookup Table
        LUT
        
        % Time point to show
        Time = 1

    end

    properties (Access = protected)

        Figure

        MIPPanel
        MIPThreeView

        SlicePanel
        SliceThreeView

        Initialized = false

    end

    methods

        function obj = FeatureCollectionViewer(varargin)
            % obj = FEATURECOLLECTIONVIEWER(c)
            %
            %   Creates a feature viewer for a FeatureCollection.
            %
            % obj = FEATURECOLLECTIONVIEWER(c, LUT)
            %
            %   Optionally specify a lookup table for the display.

            switch nargin

                case 0
                    obj.FeatureCollection = [];
                    obj.LUT = [0, 1];

                case 1
                    c = varargin{1};
                    assert(isa(c, 'FeatureCollection'));
                    obj.FeatureCollection = c;

                    vol = obj.FeatureCollection.find_random().get_slice();
                    obj.LUT = [0, max_all(vol)];

                case 2
                    c = varargin{1};
                    LUT = varargin{2};

                    obj.FeatureCollection = c;
                    obj.LUT = LUT;

            end

            obj.Figure = figure('Visible','off',...
                'Units', 'normalized', ...
                'Position',[.1, .1, .8, .8]);

            obj.MIPPanel = uipanel('Title', 'MIPs', ...
                'Units', 'normalized', ...
                'Position', [0.005, 0.005, 0.49, 0.98], ...
                'Parent', obj.Figure);

            obj.SlicePanel = uipanel('Title', 'Slices', ...
                'Units', 'normalized', ...
                'Position', [0.505, 0.005, 0.49, 0.98], ...
                'Parent', obj.Figure);

            obj.Initialized = true;
            obj.update();

            obj.Figure.Visible = 'on';

        end

        function this = set.LUT(this, new_LUT)
            this.LUT = new_LUT;
            this.update();
        end

        function this = set.FeatureCollection(this, new_collection)
            this.FeatureCollection = new_collection;
            this.update();
        end

    end

    methods (Access = protected)

        function this = update(this)

            if ~this.Initialized
                return
            end

            vol = this.Feature.get_slice();
            coords = round(this.Feature.get_center());

            MIPx = max_intensity_x(vol);
            MIPy = max_intensity_y(vol);
            MIPz = max_intensity_z(vol);

            MIPx = double_from_uint(MIPx, this.LUT);
            MIPy = double_from_uint(MIPy, this.LUT);
            MIPz = double_from_uint(MIPz, this.LUT);

            MIPx = this.Feature.draw_on_x_slice(MIPx);
            MIPy = this.Feature.draw_on_y_slice(MIPy);
            MIPz = this.Feature.draw_on_z_slice(MIPz);

            this.MIPThreeView = ThreeView(MIPx, MIPy, MIPz, ...
                this.MIPPanel);

            slice_x = get_slice(vol, coords(2), 2);
            slice_y = get_slice(vol, coords(1), 1)';
            slice_z = get_slice(vol, coords(3), 3);

            slice_x = double_from_uint(slice_x, this.LUT);
            slice_y = double_from_uint(slice_y, this.LUT);
            slice_z = double_from_uint(slice_z, this.LUT);

            slice_x = this.Feature.draw_on_x_slice(slice_x);
            slice_y = this.Feature.draw_on_y_slice(slice_y);
            slice_z = this.Feature.draw_on_z_slice(slice_z);

            this.SliceThreeView = ThreeView(slice_x, slice_y, slice_z, ...
                this.SlicePanel);

        end

    end

end

