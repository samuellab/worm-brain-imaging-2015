classdef WormPosture
    
    properties
        
        % Length of the worm, typically in microns
        Length;
        
        % Time resolution, in seconds
        DT;
        
        % Postural trajectory (2 x 100 x size_T). First dimension is (x,y)
        % and second dimension is ordered head to tail.
        Posture;
        
        % Forward unit vector (2 x size_T)
        Xhat;
        
        % Head (typically corresponds to segment 8 of Posture, 2 x size_T)
        Head;
        
        % Handedness (1 -> ventral side CCW from xhat within the 'image
        % convention' of a reversed y-axis)
        Handedness = 1;
        
    end
    
    methods
        
        function obj = WormPosture(posture)
        % worm_posture = WormPosture(posture)
        %   
        %   Takes in a posture (2 x N x size_T) and extrapolates nans (in
        %   the time direction). It is then resampled to create a canonical
        %   2 x 100 x size_T postural trajectory.

            size_P = size(posture, 2);

            for i = 1:size_P

                posture(1,i,:) = interp_nans(squeeze(posture(1,i,:)), ...
                    'linear');
                posture(2,i,:) = interp_nans(squeeze(posture(2,i,:)), ...
                    'linear');

            end
            
            size_T = size(posture, 3);
            size_P = size(posture, 2);
            
            obj.Posture = NaN(2, 100, size_T);
            
            % Resample so posture is 100 points long
            for i = 1:size_T
                
                if ~all(isnan(row(posture(:,:,i))))
                
                    % x
                    obj.Posture(1, :, i) = interp1(...
                        linspace(1, 100, size_P), ...
                        posture(1, :, i), ...
                        1:100);

                    % y
                    obj.Posture(2, :, i) = interp1(...
                        linspace(1, 100, size_P), ...
                        posture(2, :, i), ...
                        1:100);
                    
                end
                
            end
            
        end
        
        function obj = xhat_from_posture(obj, segment_2, segment_1)
        % obj = obj.xhat_from_posture(segment_2)
        %
        %   Generates the forward unit vector by normalizing the vector
        %   from segment_2 to the animals nose (obj.Posture(:,1,:))
        %
        % obj = obj.xhat_from_posture(segment_2, segment_1)
        %
        %   Generates the forward unit vector by normalizing the vector
        %   from segment_2 to segment_1.

            if nargin < 3
                segment_1 = 15;
            end

            if nargin < 2
                segment_2 = 20;
            end

            x = obj.Posture(:, segment_1, :) - ...
                obj.Posture(:, segment_2, :);
            x = squeeze(x);

            for i = 1:size(x, 2)

                xhat(:,i) = x(:,i) ./ norm(x(:,i));

            end

            obj.Xhat = xhat;

        end

        function obj = head_from_posture(obj, head_segment)
        % obj = obj.head_from_posture(head_segment)
        %
        %   Generates a head trajectory (2 x size_T) from the specified
        %   WormPosture segment (default 15).

            if nargin < 2
                head_segment = 15;
            end

            obj.Head = squeeze(obj.Posture(:, head_segment, :));

        end
        
        function obj = length_from_posture(obj)
        % obj = obj.length_from_posture()
        %
        %   Populates obj.Length with the median length from the postural
        %   history.
            
            L = nan(1, obj.size_T());
            for i = 1:obj.size_T()
                
                L(i) = arclength(...
                    squeeze(obj.Posture(1,:,i)), ...
                    squeeze(obj.Posture(2,:,i)));
                
            end
            
            obj.Length = median(L);
            
        end
        
        function size_T = size_T(obj)
        % size_T = obj.size_T()
        %
        %   Returns the number of time points in the worm's postural
        %   trajectory.
        
            size_T = size(obj.Posture, 3);
        
        end
        
        function plot_frame(obj, times, fig)
        % obj.plot_frame(t, fig)
        %
        %   Plots the posture at the given time points in the specified
        %   figure.
        
            figure(fig);
            x = squeeze(obj.Posture(1,:,times));
            y = squeeze(obj.Posture(2,:,times));
            plot(x, y);
            set(gca, 'Ydir', 'reverse');
            axis equal;
        
        end
        
        function show_movie(obj, fig, start_time)
        % obj.show_movie(fig=1, start_time=1)
        %
        %   Shows a movie of the posture if the specified figure.
        
            if nargin < 3
                start_time = 1;
            end
            
            if nargin < 2
                fig = 1;
            end
            
            size_T = obj.size_T();
            figure(fig);
            for t = start_time:obj.size_T()
               
                obj.plot_frame(t, fig);
                title(sprintf('Time %d, ~%.2f / %.2f seconds', ...
                    t, t*obj.DT, obj.DT*size_T));
                pause(obj.DT);
                
            end
            
        end
        
        function angles = angles(obj)
        % angles = obj.angles()
        %
        %   Oriented angle between segment i and segment i+1. Positive
        %   angles correspond to ventral bending. Order is head to tail,
        %   units are radians. Contains NaNs if obj.Posture contains NaNs.
        %   (98 x size_T)
            
            for t = 1:obj.size_T()
                
                posture = squeeze(obj.Posture(:,:,t));
                dposture = diff(posture, 1, 2); % (2x99)
                
                for i = 1:98
                    
                    x = ...
                        atan2(dposture(2,i+1), dposture(1,i+1)) - ...
                        atan2(dposture(2,  i), dposture(1,  i));
                    
                    if x > pi
                        x = x - 2*pi;
                    elseif x < -pi
                        x = x + 2*pi;
                    end
                    
                    if abs(x) > 0.2
                        
                        x = NaN;
                        
                    end
                    
                    angles(i,t) = x;
                    
                end
                
            end

            angles = - angles * obj.Handedness;
        
        end
        
        function obj = trim_nans(obj)
        % obj = obj.trim_nans()
        %
        %   Removes frames with exclusively nans from the beginning and
        %   end of obj.Posture.
        
            start_idx = NaN;
            for i = 1:size(obj.Posture, 3)
                
                if any(~isnan(row(obj.Posture(:,:,i))))
                    start_idx = i;
                    break
                end
                
            end
            
            end_idx = NaN;
            for i = size(obj.Posture, 3):-1:1
                
                if any(~isnan(row(obj.Posture(:,:,i))))
                    end_idx = i;
                    break
                end
                
            end
            
            obj.Posture = obj.Posture(:,:,start_idx:end_idx);
        
        end
        
        function components = principal_components(obj)
        % components = obj.eigenworms()
        %
        %   Returns the principal components of obj, in the angle
        %   representation. (98 x size_T)
        
            components = pca(obj.angles()', 'Centered', false);
        
        end
        
        function angles = principal_angles(obj, N, C)
        % angles = obj.principal_angles(N)
        %
        %   Calculates the angles associated with a WormPosture object and
        %   returns the specified number of principal components.

            if nargin < 3
                C = obj.principal_components();
            end

            proj = C * diag([ones(1,N), zeros(1,98-N)]) * C';

            angles = obj.angles();
            angles(isnan(angles)) = 0;
            angles = proj * angles;

        end
        
    end
    
    methods (Static)
        
        function obj = from_mrc_matfile(filename)
        % obj = WormPosture.from_mrc_matfile(filename)
        %
        %   Factory method to create a WormPosture from an MRC dataset (see
        %   http://wormbehavior.mrc-lmb.cam.ac.uk/) downloaded as a .mat
        %   file.
            
            S = load(filename);

            posture(1, :, :) = S.worm.posture.skeleton.x;
            posture(2, :, :) = S.worm.posture.skeleton.y;
            
            obj = WormPosture(posture);
            obj = obj.trim_nans();
          
            obj.DT = 1/S.info.video.resolution.fps;
            obj = obj.length_from_posture();
            obj = obj.xhat_from_posture();
            obj = obj.head_from_posture();
            
            switch S.info.experiment.worm.agarSide
                
                case 'right'
                    
                    obj.Handedness = +1;
                    
                case 'left'
                    
                    obj.Handedness = -1;
                    
                otherwise
                        
                    obj.Handedness = NaN;
                    
            end
            
        end
        
        function obj = from_head_trajectory(head_trajectory, xhat, L, varargin)
        % obj = WormPosture.from_head_trajectory(head_trajectory, xhat, L)
        %
        %   Factory method to create a WormPosture from the trajectories of
        %   the head and forward unit vector.
        %
        %   By default, the first 14 components of posture (roughly
        %   corresponding to the animal's nose) will be set to NaN, and it
        %   is assumed that the trajectory provided corresponds to
        %   component 15.
        
            default_options = struct(...
                'head_location', 15 ...
            );
            input_options = varargin2struct(varargin{:}); 
            options = mergestruct(default_options, input_options);
            options.segments = length(options.head_location:100);
        
            if isa(head_trajectory, 'WormPosture')
                ref_posture = head_trajectory;
                head_trajectory = ref_posture.Head;
                xhat = ref_posture.Xhat;
                L = ref_posture.Length;
            else
                ref_posture = [];
            end
            
            partial_length = (options.segments-1)/(100-1) * L;
            posture = posture_from_head(head_trajectory, xhat, ...
                partial_length, options);
            size_T = size(posture, 3);
            
            full_posture = NaN(2, 100, size_T);
            full_posture(:,options.head_location:end,:) = posture;
            
            obj = WormPosture(full_posture);
            
            % If we were given a posture object, copy it and replace the
            % fields Posture, Xhat, and Head.
            if ~isempty(ref_posture)
                ref_posture.Posture = obj.Posture;
                ref_posture.Head = [];
                ref_posture.Xhat = [];
                obj = ref_posture;
            end
        
        end
        
        function compare(posture1, posture2, times, fig)
        % WormPosture.compare(posture1, posture2)
        %
        %   Compare two WormPosture objects by plotting them on the same
        %   figure. To see a movie, use WormPosture.compare_movie.
        
            if nargin < 4
                fig = 1;
            end
            
            figure(fig); clf;
            posture1.plot_frame(times, fig);
            hold on;
            posture2.plot_frame(times, fig);
        
        end
        
        function compare_movie(posture1, posture2, varargin)
        % WormPosture.compare_movie(posture1, posture2)
        %
        %   Compare two WormPosture objects by plotting them frame after
        %   frame in the specified figure.
        
            default_options = struct(...
                'fig', 1, ...
                'components', [] ...
            );
            input_options = varargin2struct(varargin{:}); 
            options = mergestruct(default_options, input_options);
        
            fig = options.fig;
            
            if ~isempty(options.components)
                
                C = options.components;
                angles1 = posture1.principal_angles(5, C);
                angles2 = posture2.principal_angles(5, C);
                
            else
            
                angles1 = posture1.angles();
                angles2 = posture2.angles();
            
            end
            
            size_T = posture1.size_T();
            for t = 1:size_T
                WormPosture.compare(posture1, posture2, t, fig);
                title(sprintf('Time %d, ~%.2f / %.2f seconds', ...
                    t, t*posture1.DT, posture1.DT*size_T));
                pause(posture1.DT);
                
                figure(fig+1); clf;
                plot(angles1(:,t));
                hold on;
                plot(angles2(:,t));
            end
            
        end
        
    end
    
end