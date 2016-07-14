classdef PointFeatureViewer < matlab.mixin.SetGet
    %POINTFEATUREVIEWER Snapshot of a PointFeature

    properties

        % PointFeature to display.
        Feature = []

        % Lookup Table
        LUT

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

        function obj = PointFeatureViewer(varargin)
            % obj = POINTFEATUREVIEWER(f)
            %
            %   Creates a point feature viewer for feature f.
            %
            % obj = POINTFEATUREVIEWER(f, LUT)
            %
            %   Optionally specify a lookup table for the display.

            switch nargin
                
                case 0
                    obj.Feature = [];
                    obj.LUT = [0, 1];
                
                case 1
                    f = varargin{1};
                    assert(isa(f, 'PointFeature'));
                    obj.Feature = f;
                    
                    vol = obj.Feature.get_slice();
                    obj.LUT = [0, max_all(vol)];
                    
                case 2
                    f = varargin{1};
                    LUT = varargin{2};
                    
                    obj.Feature = f;
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

        function this = set.Feature(this, new_feature)
            this.Feature = new_feature;
            this.update();
        end

    end

    methods (Access = protected)

        function this = update(this)

            if ~this.Initialized || ~isa(this.Feature, 'PointFeature')
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

