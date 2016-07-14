classdef MoviePlayer < matlab.mixin.SetGet 
    
    properties
        Data
        T = 1
        LUT = [0 1]
        Size_T
    end
    
    properties (Access=protected)
        Figure
        TimeSlider
        LUTSlider
        Axes
    end
    
    methods
        
        function obj = MoviePlayer(x)
            % obj = MOVIEPLAYER(x)
            %
            %   Creates a movie player for array x.
            
            obj.Size_T = size(x, ndims(x));
            
            type = element_class(x);
            
            switch type
                
                case 'uint16'
                    LUT_bounds = [0 2^16-1];
                case 'uint8'
                    LUT_bounds = [0 2^8-1];
                case {'double' 'float'}
                    LUT_bounds = [0 1];
                otherwise
                    LUT_bounds = [0 1];
                
            end
            
            obj.Figure = figure('Visible','off',...
                'Position',[100,100,500,550]);
            
            obj.TimeSlider = uicontrol('Style','slider',...
                'Units', 'normalized', ...
                'Position',[0.05, 0.05, 0.9, 0.04], ...
                'Min', 1, ...
                'Max', obj.Size_T, ...
                'Value', 1, ...
                'SliderStep', [1 10]./obj.Size_T, ...
                'Callback', @(h,v) obj.time_slider_callback(h) ...
            );
        
            obj.LUTSlider = uicontrol('Style','slider',...
                'Units', 'normalized', ...
                'Position',[0.05, 0.0, 0.9, 0.04], ...
                'Min', LUT_bounds(1), ...
                'Max', LUT_bounds(2), ...
                'Value', LUT_bounds(2), ...
                'SliderStep', [.01 .1], ...
                'Callback', @(h,v) obj.LUT_callback(h) ...
            );
            
            obj.Axes = axes(...
                'Position', [.05, .15, .9, .8], ...
                'parent', obj.Figure ...
            );
        
            set(obj.Figure, 'visible', 'on');
            
            obj.Data = x;
            
            obj.T = 1;
            obj.LUT = LUT_bounds;

            
        end
        
        function this = set.T(this, val)
            
            this.T = val;
            this.update();
            
        end
        
        function this = set.LUT(this, val)
            
            this.LUT = val;
            this.update();
            
        end
        
    end
    
    methods (Access=protected)
        
        function time_slider_callback(this, slider)
            
            this.T = round(slider.Value);
            
        end
        
        function LUT_callback(this, slider)
            
            this.LUT(2) = round(slider.Value);
            
        end
        
        function update(this)
            
            imshow(this.Data(:,:,this.T), this.LUT, 'Parent', this.Axes);
            set(this.TimeSlider, 'Value', this.T);
            set(this.LUTSlider, 'Value', this.LUT(2));
            
        end
        
    end
    
end