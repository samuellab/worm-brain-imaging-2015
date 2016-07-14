function feature_annotator_callbacks(what,varargin)
% Handles all callbacks for feature annotation and exposes them for global
% access.  For example, to update the image in feature annotator, call from
% anywhere: 
%  feature_annotator_callbacks('Update_Image');
%
% To select a new tif directory, call from anywhere:
%  feature_annotator_callbacks('image_location', directory)
    switch nargin
        case 1
            eval(what);
        otherwise
            eval([what '(varargin{:});']);
    end
end

function open(h)
    global feature_annotator_data
    feature_annotator_data.gui=h;
    Update_GUI_Full;
end

function set_image_location(filename)
    global feature_annotator_data;
    
%     if nargin == 0
%         [filename, pathname] = uigetfile;
%     end
%     
%     
%     if filename == 0
%         directory_name = uigetdir;
%         if directory_name == 0
%             return
%         else
%             filename = directory_name;
%         end
%     else
%         filename = fullfile(pathname, filename);
%     end
    
    if nargin == 0
        directory_name = uigetdir;
    end
    
    if directory_name == 0
        [filename, pathname] = uigetfile;
        if filename == 0
            return
        else
            filename = fullfile(pathname, filename);
        end
    else
        filename = directory_name;
    end
    

    if exist(filename,'file')
        feature_annotator_data.image_location = filename;
        feature_annotator_data.projection_ok = false;
        Update_GUI_Full;
    else
        error([path ' is not a valid directory']);
    end
end

function time_slider
    global feature_annotator_data;
    new_t = round(get(feature_annotator_data.gui.time_slider,'Value'));
    feature_annotator_data.t = new_t;
    feature_annotator_data.projection_ok = false;
    
    Update_Image;
end

% configure this to make the keyboard behave however you would like
function keypress_handler(eventdata)
    global feature_annotator_data;
    
    if ~isfield(feature_annotator_data,'t')
        return;
    end
    
    t = feature_annotator_data.t;
    size_T = feature_annotator_data.size_T;
    dt = feature_annotator_data.dt;
    
    z = feature_annotator_data.z;
    size_Z = feature_annotator_data.size_Z;
    
    switch eventdata.Character
        case {'a'}
            auto_segment();
        case {'f' 'F'}
            if t+dt <= size_T
                t = t + dt;
                
                active_feature = get(...
                    feature_annotator_data.gui.active_feature, 'Value');
                
                active_feature_string = get(...
                    feature_annotator_data.gui.active_feature, 'String');
                
                if strcmp(active_feature_string, 'None Available')
                    active_feature = [];
                end
                
                if eventdata.Character == 'f' && ~isempty(active_feature)
                    f = feature_annotator_data.features{active_feature};
                    
                    new_z = round(f.coordinates(t,3) + f.ref_offset(3));
                    
                    if new_z >= 0 && new_z <= feature_annotator_data.size_Z
                        feature_annotator_data.z = new_z;
                    end
                end
                
                feature_annotator_data.t = t;
                feature_annotator_data.projection_ok = false;
                % temporarily unwire 'f'
                set(feature_annotator_data.gui.figure1,'KeyPressFcn',...
                    @(hObject,eventdata)feature_annotator_callbacks(...
                    'keypress_handler_disable',eventdata,{'f' 'F'}));
                Update_Image;
                % rewire 'f'
                set(feature_annotator_data.gui.figure1,'KeyPressFcn',...
                    @(hObject,eventdata)feature_annotator_callbacks(...
                    'keypress_handler',eventdata));
            end
        case {'d' 'D'}
            if t-dt >= 1
                t = t - dt;
                active_feature = get(...
                    feature_annotator_data.gui.active_feature, 'Value');
                
                active_feature_string = get(...
                    feature_annotator_data.gui.active_feature, 'String');
                
                if strcmp(active_feature_string, 'None Available')
                    active_feature = [];
                end
                
                if eventdata.Character == 'd' && ~isempty(active_feature)
                    f = feature_annotator_data.features{active_feature};
                    
                    new_z = round(f.coordinates(t,3) + f.ref_offset(3));
                    
                    if new_z >= 0 && new_z <= feature_annotator_data.size_Z
                        feature_annotator_data.z = new_z;
                    end
                end
                
                feature_annotator_data.t = t;
                feature_annotator_data.projection_ok = false;
                % temporarily unwire 'd'
                set(feature_annotator_data.gui.figure1,'KeyPressFcn',...
                    @(hObject,eventdata)feature_annotator_callbacks(...
                    'keypress_handler_disable',eventdata,{'d' 'D'}));
                Update_Image;
                % rewire 'd'
                set(feature_annotator_data.gui.figure1,'KeyPressFcn',...
                    @(hObject,eventdata)feature_annotator_callbacks(...
                    'keypress_handler',eventdata));
            end
        case {'w' 'W'} % go to next key frame
            if t+1 <= size_T
                
                active_feature = get(...
                    feature_annotator_data.gui.active_feature, 'Value');
                
                features_to_check = get(...
                    feature_annotator_data.gui.feature_list, 'Value');
                
                if isfield(feature_annotator_data, ...
                           'segmentation_options') ...
                   && isfield(...
                     feature_annotator_data.segmentation_options, ...
                     'reference_features')
                 
                    features_to_check = ...%[features_to_check ...
                        feature_annotator_data.segmentation_options...
                            .reference_features;
                end
                 
                while t < size_T
                    t = t + 1;
                    done = false;
                    for i = features_to_check
                        F = feature_annotator_data.features{i};
                        if ~all(isnan(F.modified_coordinates(t,:))) || ...
                           F.is_bad_frame(t)
                            done = true;
                            break
                        end
                    end
                    if done
                        break
                    end
                end
                    
                feature_annotator_data.t = t;
                feature_annotator_data.projection_ok = false;
                
                if eventdata.Character == 'w' && ~isempty(active_feature)
                    f = feature_annotator_data.features{active_feature};
                    feature_annotator_data.z = round(...
                        f.coordinates(t,3) + f.ref_offset(3));
                end
                
                % temporarily unwire 'd'
                set(feature_annotator_data.gui.figure1,'KeyPressFcn',...
                    @(hObject,eventdata)feature_annotator_callbacks(...
                    'keypress_handler_disable',eventdata,{'d' 'D'}));
                Update_Image;
                % rewire 'd'
                set(feature_annotator_data.gui.figure1,'KeyPressFcn',...
                    @(hObject,eventdata)feature_annotator_callbacks(...
                    'keypress_handler',eventdata));
            end
        case {'q' 'Q'} % go to previous key frame
            if t-1 >= 1
                
                active_feature = get(...
                    feature_annotator_data.gui.active_feature, 'Value');
                
                features_to_check = get(...
                    feature_annotator_data.gui.feature_list, 'Value');
                
                if isfield(feature_annotator_data, ...
                           'segmentation_options') ...
                   && isfield(...
                     feature_annotator_data.segmentation_options, ...
                     'reference_features')
                 
                    features_to_check = ...%[features_to_check ...
                        feature_annotator_data.segmentation_options...
                            .reference_features;
                end
                 
                while t > 1
                    t = t - 1;
                    done = false;
                    for i = features_to_check
                        F = feature_annotator_data.features{i};
                        if ~all(isnan(F.modified_coordinates(t,:))) || ...
                           F.is_bad_frame(t)
                            done = true;
                            break
                        end
                    end
                    if done
                        break
                    end
                end
                    
                feature_annotator_data.t = t;
                feature_annotator_data.projection_ok = false;
                
                if eventdata.Character == 'q' && ~isempty(active_feature)
                    f = feature_annotator_data.features{active_feature};
                    feature_annotator_data.z = round(...
                        f.coordinates(t,3) + f.ref_offset(3));
                end
                
                % temporarily unwire 'd'
                set(feature_annotator_data.gui.figure1,'KeyPressFcn',...
                    @(hObject,eventdata)feature_annotator_callbacks(...
                    'keypress_handler_disable',eventdata,{'d' 'D'}));
                Update_Image;
                % rewire 'd'
                set(feature_annotator_data.gui.figure1,'KeyPressFcn',...
                    @(hObject,eventdata)feature_annotator_callbacks(...
                    'keypress_handler',eventdata));
            end
        case {'r' 'R'}
            if dt < 1024
                dt = 2*dt;
                feature_annotator_data.dt = dt;
                Update_Image;
            end
        case {'e' 'E'}
            if dt > 1
                dt = dt/2;
                feature_annotator_data.dt = dt;
                Update_Image;
            end
        case {'v', 'V'}
            if z < size_Z
                z = z + 1;
                feature_annotator_data.z = z;
                Update_Image;
            end
        case {'c', 'C'}
            if z > 1
                z = z - 1;
                feature_annotator_data.z = z;
                Update_Image;
            end
        case {'s' 'S'}
            if ~ isempty(get(...
                    feature_annotator_data.gui.feature_list,'String'))
                
            % update the feature coordinates in memory, save the inputed
            % values in modified_coordinates
            
            [x, y, button] = ginput(1);
            feature_index = ...
                    get(feature_annotator_data.gui.active_feature,'Value');
                
            switch feature_annotator_data.size_Z
            case 1 % 2D
            if button == 1
                new_coords = round([y x] - feature_annotator_data. ...
                                            features{feature_index}. ...
                                             ref_offset);
                                           
                feature_annotator_data.features{feature_index}. ...
                    modified_coordinates(t,:) = new_coords;
            else 
                feature_annotator_data.features{feature_index}. ...
                    modified_coordinates(t,:) = [nan nan];
            end
            otherwise % 3D
            if button == 1
                z = feature_annotator_data.z;
               new_coords = round([y x z] - feature_annotator_data. ...
                                            features{feature_index}. ...
                                             ref_offset);
                                           
                feature_annotator_data.features{feature_index}. ...
                    modified_coordinates(t,:) = new_coords;
                
                auto_segment(0.01);
                
                feature_annotator_data.features{feature_index}. ...
                    is_registered(t) = true;
                
            else 
                feature_annotator_data.features{feature_index}. ...
                    modified_coordinates(t,:) = [nan nan nan];
                
                feature_annotator_data.features{feature_index}. ...
                    is_registered(t) = false;
            end
            end % switch
            Update_Image;
            end % if ~ isempty(...
            
        case {'t', 'T'} % mark the frame as bad
            feature_index = ...
                    get(feature_annotator_data.gui.active_feature,'Value');
            if ~isfield(feature_annotator_data.features{feature_index}, ...
                    'is_bad_frame')
                feature_annotator_data.features{feature_index}...
                    .is_bad_frame = zeros(size_T, 1);
            end
            feature_annotator_data.features{feature_index}...
                .is_bad_frame(t) = ...
               ~feature_annotator_data.features{feature_index}...
                .is_bad_frame(t);
            
            if feature_annotator_data.features{feature_index}...
                .is_bad_frame(t)
            
                feature_annotator_data.features{feature_index}...
                .is_registered(t) = false;
            
            end
            
            Update_Image;
%         case {'c', 'C'}
%             datacursormode(feature_annotator_data.gui.figure1);
    end % switch
    
end

% disable certain keys before passing through to keypress_handler
function keypress_handler_disable(eventdata, keys_to_disable)
    switch eventdata.Character
        case keys_to_disable
            return;
        otherwise
            keypress_handler(eventdata);
    end 
end

% configure this to make mouseclicks do whatever you want
function mouseclick_handler(hObject, eventdata)
    global feature_annotator_data;
    
    
    
end

function wheel_function(obj,input)
    global feature_annotator_data;
    
    z = feature_annotator_data.z;
    size_Z = feature_annotator_data.size_Z;
    
    z = z - input.VerticalScrollCount;
    if z<1
        z=1;
    elseif z>size_Z
        z = size_Z;
    end

    feature_annotator_data.z = z;

    Update_Image;
end

function LUT_low_slider(val)
    global feature_annotator_data;
    
    if nargin == 1
        val = max(val, 1);
        set(feature_annotator_data.gui.LUT_high,'Value',val);
    end
    
    feature_annotator_data.LUT(1) = ...
        round(get(feature_annotator_data.gui.LUT_low,'Value'));
    feature_annotator_data.projection_ok = false;
    Update_Image;
end

function LUT_high_slider(val)
    global feature_annotator_data;
    
    if nargin == 1
        val = min(val, 2^14);
        set(feature_annotator_data.gui.LUT_high,'Value',val);
    end
    
    feature_annotator_data.LUT(2) = ...
        round(get(feature_annotator_data.gui.LUT_high,'Value'));
    feature_annotator_data.projection_ok = false;
    Update_Image;
end

function update_filter
    global feature_annotator_data;
    feature_annotator_data.projection_ok = false;
    Update_Image;
end

function wait_for_selection(prompt)
global feature_annotator_data;

if nargin == 0
    prompt = 'Select an image using "s"';
end

    % temporarily unwire default selection with 's' key
    set(feature_annotator_data.gui.figure1,'KeyPressFcn',...
        @(hObject,eventdata)feature_annotator_callbacks(...
        'keypress_handler_disable',eventdata,{'s'}));
    
    %store the current select instructions string
    temp =  get(feature_annotator_data.gui.select_instructions, 'String');
    
    set(feature_annotator_data.gui.select_instructions, 'String',  ...
            prompt);
    waitfor(feature_annotator_data.gui.figure1, ...
            'CurrentCharacter', 's'); % 115 = 's' [decimal ASCII]
    set(feature_annotator_data.gui.figure1,'CurrentCharacter',char(1));
        
    % rewire default selection with 's' key
    set(feature_annotator_data.gui.figure1,'KeyPressFcn',...
        @(hObject,eventdata)feature_annotator_callbacks(...
        'keypress_handler',eventdata));
    
    % restore instructions
    set(feature_annotator_data.gui.select_instructions, 'String',  ...
            temp);
end

function r = get_rectangle(prompt)
global feature_annotator_data;
    
if nargin == 0 
    prompt = 'Draw a rectangle';
end
    wait_for_selection(...
        'Select an image to draw a rectangle, then hit "s"');
    
    %store the current select instructions string
    temp =  get(feature_annotator_data.gui.select_instructions, 'String');
    
    set(feature_annotator_data.gui.select_instructions, 'String',  ...
        prompt);
        
    r = round(getrect(feature_annotator_data.gui.axes1));
    
    % restore instructions
    set(feature_annotator_data.gui.select_instructions, 'String',  ...
            temp);
end

function p = get_point(prompt)
global feature_annotator_data;

if nargin == 0 
    prompt = 'Select a point';
end
    wait_for_selection([prompt ...
        ':  choose T and Z, then hit "s"']);
    
    %store the current select instructions string
    temp =  get(feature_annotator_data.gui.select_instructions, 'String');
    
    set(feature_annotator_data.gui.select_instructions, 'String',  ...
        []);
    
    figure(feature_annotator_data.gui.figure1);
    p = round(ginput(1));
    
    if isempty(p)
        return;
    end
    
    p = [p(2) p(1)];

    if feature_annotator_data.size_Z > 1
        p(3) = feature_annotator_data.z;
    end
    
    % restore instructions
    set(feature_annotator_data.gui.select_instructions, 'String',  ...
            temp);
end

function new_feature(feature_name)
    global feature_annotator_data;
    
    if nargin == 0
        feature_name = inputdlg({'Name of new feature'});
        feature_name = feature_name{1};
    end
    feature_annotator_data.features{end+1}.name = feature_name;
    
    % first get a rectangle corresponding to feature's xy-boundary 

    r = get_rectangle;
    
    % now we have to handle 2d and 3d features separately
    
    switch feature_annotator_data.size_Z
        case 1 %2D

        % sizes are one less than the actual matlab array sizes. sorry if
        % that pisses you off... it's for compatibility with old code.
        feature_annotator_data.features{end}.size = [r(4)-1 r(3)-1];

        % use the current location as our guess for all frames
        feature_annotator_data.features{end}.coordinates = ...
            kron(ones(feature_annotator_data.size_T,1),[r(2) r(1)]);
    
        otherwise %3D
            
        % next get the lower plane
        wait_for_selection(...
            ['Select a plane corresponding to the LOW z-value, ' ...
            'then hit "s"']);        
        low_Z = feature_annotator_data.z;
        
        % now get the higher plane
        wait_for_selection(...
            ['Select a plane corresponding to the HIGH z-value, ' ...
            'then hit "s"']);  
        high_Z = feature_annotator_data.z;
        
        % initialize the feature
        feature_annotator_data.features{end}.size = [...
            r(4)-1 ...
            r(3)-1 ...
            high_Z - low_Z ...
            ];
        feature_annotator_data.features{end}.coordinates = ...
            kron(ones(feature_annotator_data.size_T,1),...
                [r(2) r(1) low_Z]);
    end
    
    p = get_point('Reference point');
    if isempty(p)
        feature_annotator_data.features{end}.ref_offset = ...
            round(feature_annotator_data.features{end}.size/2);
    else
        feature_annotator_data.features{end}.ref_offset = ...
            p - feature_annotator_data.features{end}.coordinates(1,:);
    end
    
    feature_annotator_data.features{end}.is_bad_frame = ...
        false(feature_annotator_data.size_T,1);
    feature_annotator_data.features{end}.is_registered = ...
        false(feature_annotator_data.size_T,1);

    % cleanup:
    Configure_Feature_UI_Elements;
    Update_Image;
end

function active_feature
    Update_Image;
end

function feature_list
    Configure_Feature_UI_Elements;
    Update_Image;
end

function feature_list_keypress_handler(eventdata)
global feature_annotator_data;

switch eventdata.Key
    case {'delete'}
        selected_features = get(feature_annotator_data.gui.feature_list,...
                                'Value');
        for i = selected_features
            name = feature_annotator_data.features{i}.name;
            response = questdlg(['Delete feature ' name ' ?']);
            if strcmp(response, 'Yes')
                feature_annotator_data.features(i) = [];
                Configure_Feature_UI_Elements;
                Update_Image;
            end
        end
                            
end
end

function auto_segment(timeout)
    global feature_annotator_data;
    
    method_index = get(feature_annotator_data.gui.segmentation_method, ...
                        'Value');
                    
    active_feature = get(feature_annotator_data.gui.active_feature,...
            'Value');
        
    F = feature_annotator_data.features{active_feature};
    t = feature_annotator_data.t;
    loc = feature_annotator_data.image_location;
    
    if nargin == 1
        options.timeout = timeout;
    else
        options.timeout = str2double(get(...
            feature_annotator_data.gui.timeout,'String'));
    end
    
    if isnan(options.timeout)
        options.timeout = 2;
    end
    
    if isfield(feature_annotator_data, 'segmentation_options')
        opts = feature_annotator_data.segmentation_options;
    else
        opts = struct();
    end
%     if isfield(opts, 'reference_features')
%         opts.reference_features = feature_annotator_data.features(...
%             opts.reference_features);
%     end
    
    size_T = feature_annotator_data.size_T;
    timer = tic;
    while toc(timer) < options.timeout && t <= size_T
        
        F = register_feature_frame(F, loc, t, opts);
        
        feature_annotator_data.features{active_feature} = F;
        feature_annotator_data.t = t;
        center = get_feature_center(F, t);
        
        if ~isnan(center(3))
            feature_annotator_data.z = round(center(3));
        end
        
        feature_annotator_data.projection_ok = false;
        Update_Image();
        drawnow();
        
        t = t + 1;
    end
                                    
    
end

function save_updates
    global feature_annotator_data;
    
    features = feature_annotator_data.features;
    
%     % move modified_coordinates to coordinates on saving
%     for i = 1:length(features)
%         if isfield(features{i}, 'modified_coordinates')
%             for t = 1:size(features{i}.modified_coordinates,1)
%                 if ~isnan(features{i}.modified_coordinates(t,1))
%                     features{i}.coordinates(t,:) = ...
%                         features{i}.modified_coordinates(t,:);
%                 end
%             end
%         end
%     end
    
    save_features();
end


% this loads from a new directory, WIPING ALL CHANGES
function Update_GUI_Full
    global feature_annotator_data
    
    % to allow accessing the figure from outside routines as opposed to
    % only from callbacks.
    set(feature_annotator_data.gui.figure1,'HandleVisibility','on')
    
    % reset LUT values
    feature_annotator_data.LUT = [1 2^14-1];
    
    % configure axes with image
    feature_annotator_data.image = imshow([0 1; 1 0],...
            'Parent', feature_annotator_data.gui.axes1);
    
    imshow([0 1; 1 0], 'Parent', feature_annotator_data.gui.axes_xy);
    imshow([0 1; 1 0], 'Parent', feature_annotator_data.gui.axes_xz);
    imshow([0 1; 1 0], 'Parent', feature_annotator_data.gui.axes_zy);
    
    % stuff that should only be done if we have a valid image location
    if isfield(feature_annotator_data,'image_location') ...
              && isa(feature_annotator_data.image_location, 'char')
        
        feature_annotator_data.size_T = get_size_T( ...
                                feature_annotator_data.image_location);
        
        if ~exist(feature_annotator_data.image_location, 'dir')
            mfile = matfile(feature_annotator_data.image_location);
            file_fields = whos(mfile);
            for i = 1:length(file_fields)
                if length(size(mfile, file_fields(i).name)) > 2
                    feature_annotator_data.color = file_fields(i).name;
                    break
                end
            end
        end
            

        test_vol = load_image([], 't', 1);
        LUT_high = max_all(test_vol);
        
        % determine image size / dimensionality
        feature_annotator_data.size_X = size(test_vol, 2);
        feature_annotator_data.size_Y = size(test_vol, 1);
        feature_annotator_data.size_Z = size(test_vol, 3);
        feature_annotator_data.z = ...
                ceil(feature_annotator_data.size_Z/2);

        % initialize time and time increment
        if ~isfield(feature_annotator_data, 't') || ...
           feature_annotator_data.t > feature_annotator_data.size_T
            feature_annotator_data.t = 1;
        end
        if ~isfield(feature_annotator_data, 'dt') 
            feature_annotator_data.dt = 1;
        end
        
        % configure the time slider
        set(feature_annotator_data.gui.time_slider, 'Min', 1);
        set(feature_annotator_data.gui.time_slider, 'Max', ...
            feature_annotator_data.size_T);
        set(feature_annotator_data.gui.time_slider, 'Value', 1);
        set(feature_annotator_data.gui.time_slider, 'SliderStep',...
              [1/feature_annotator_data.size_T ...
               10/feature_annotator_data.size_T]...
            );
        
        % attach a mouse wheel handler to the figure window
        set(feature_annotator_data.gui.figure1, 'WindowScrollWheelFcn', ...
          @wheel_function);
        
        % configure LUT sliders
        set(feature_annotator_data.gui.LUT_low, 'Min', 1);
        set(feature_annotator_data.gui.LUT_low, 'Max', 2^14);
        set(feature_annotator_data.gui.LUT_low, 'Value', 1);
        set(feature_annotator_data.gui.LUT_low, 'SliderStep',...
              [32/2^14 ...
               1024/2^14]...
            );
        set(feature_annotator_data.gui.LUT_high, 'Min', 1);
        set(feature_annotator_data.gui.LUT_high, 'Max', 2^14);
        set(feature_annotator_data.gui.LUT_high, 'Value', LUT_high);
        set(feature_annotator_data.gui.LUT_high, 'SliderStep',...
              [32/2^14 ...
               1024/2^14]...
            );
        
        %
        % feature related stuff
        %
        
        [D, N, E] = fileparts(feature_annotator_data.image_location);
        if isempty(E)
            filename = fullfile(D,N,'features.mat');
        else
            filename = fullfile(D,'features.mat');
        end
        feature_annotator_data.features = load_features(filename);
        Configure_Feature_UI_Elements;
        
        %
        % schema-enforcement for features:
        %   - volume features should have a ref_offset field
        %
        for i = 1:length(feature_annotator_data.features)
            if isfield(feature_annotator_data.features{i}, ...
                       'coordinates') && ...
               isfield(feature_annotator_data.features{i}, ...
                       'size') && ...
               ~isfield(feature_annotator_data.features{i}, ...
                       'ref_offset')
                   
               feature_annotator_data.features{i}.ref_offset = ...
                   round(feature_annotator_data.features{i}.size/2);
            end
        end
        
        %
        % auto-segmentation configuration
        %
        feature_annotator_data.segmentation_methods(1).name = ...
            'intensity';
        feature_annotator_data.segmentation_methods(1).fcn = ...
            @track_intensity;
        
        feature_annotator_data.segmentation_methods(2).name = ...
            'interpolate';
        feature_annotator_data.segmentation_methods(2).fcn = ...
            @interpolate_feature;
        
        feature_annotator_data.segmentation_methods(3).name = ...
            'correlation';
        feature_annotator_data.segmentation_methods(3).fcn = ...
            @track_correlation_2;
        
        feature_annotator_data.segmentation_methods(4).name = ...
            'centroid';
        feature_annotator_data.segmentation_methods(4).fcn = ...
            @track_centroid;
        
        feature_annotator_data.segmentation_methods(5).name = ...
            'cross interpolate';
        feature_annotator_data.segmentation_methods(5).fcn = ...
            @cross_interpolate;
        
        feature_annotator_data.segmentation_methods(6).name = ...
            'local_rotation';
        feature_annotator_data.segmentation_methods(6).fcn = ...
            @track_local_imwarp;
        
        seg_methods = {};
        for i = 1:length(feature_annotator_data.segmentation_methods)
            seg_methods{i} = ...
                feature_annotator_data.segmentation_methods(i).name;
        end
        
        set(feature_annotator_data.gui.segmentation_method, 'String', ...
            seg_methods);
        set(feature_annotator_data.gui.segmentation_method, 'Value', 1);
        set(feature_annotator_data.gui.timeout,'String','Inf');
        
        LUT_high_slider(LUT_high);
        Update_Image;
    end

end

function Configure_Feature_UI_Elements
        global feature_annotator_data;

        feature_names = {};
        for i = 1:length(feature_annotator_data.features)
          % get a list of names to use for populating the UI elements
          feature_names{end+1} = ...
                        feature_annotator_data.features{i}.name;
          if all(isfield(feature_annotator_data.features{i},...
                  {'coordinates', 'size'})) 
            if ~isfield(feature_annotator_data.features{i}, ...
                        'modified_coordinates') ...
               || ...                   
                size(feature_annotator_data.features{i}. ...
                            modified_coordinates,1) ...
                    ~= feature_annotator_data.size_T
                % initialize a vector to keep track of modifications 
                % that are made
              feature_annotator_data.features{i}. ...
                modified_coordinates = nan(...
                  size(feature_annotator_data.features{i}.coordinates));
            end
          end
        end

        % populate feature list with names of the features
        set(feature_annotator_data.gui.feature_list,'String',...
            feature_names);
        
        % ensure feature list value is valid
        if max(get(feature_annotator_data.gui.feature_list,'Value')) > ...
            length(get(feature_annotator_data.gui.feature_list,'String'))
        
           set(feature_annotator_data.gui.feature_list,'Value',[]);
        end


        % only one feature can be active and edited.  the default
        % feature is just the first one on the list

         if isempty(feature_names)
            set(feature_annotator_data.gui.feature_list,'Value',[]);
            feature_names = {'None Available'};
            set(feature_annotator_data.gui.active_feature, 'String',...
                    feature_names);
            set(feature_annotator_data.gui.active_feature, 'Value', 1);
            set(feature_annotator_data.gui.select_instructions,'String',...
                    's: inactive');
         else
            set(feature_annotator_data.gui.select_instructions,'String',...
                    's: set feature location');
            set(feature_annotator_data.gui.active_feature, 'String',...
                feature_names);
            set(feature_annotator_data.gui.active_feature, 'Value',...
                1);
         end

        
end

function Update_Image
    global feature_annotator_data
    
    t = feature_annotator_data.t;
    dt = feature_annotator_data.dt;
    size_T = feature_annotator_data.size_T;
    
    z = feature_annotator_data.z;
    size_Z = feature_annotator_data.size_Z;
    
    set(feature_annotator_data.gui.time_slider, 'Value', t);
    
%     switch size_Z
%         
%     %
%     % draw 2D image
%     %
%     
%     case 1 
%     
%     % display some text at the top of the window to show the current frame
%     % and the step speed
%     set(feature_annotator_data.gui.top_text, 'String', sprintf( ...
%         'T: %1d of %1d           Rate: %1d frame[s]/click', ...
%         t, size_T, dt));
% 
%     
%     im = double(imread(fullfile(feature_annotator_data.image_location,...
%                                 sprintf('T_%05d.tif',t))));  
%     %
%     % apply all the filters
%     %
%     
%     % t filter
%     if get(feature_annotator_data.gui.t_filter_checkbox,'Value')
%         t_filter_string = get(feature_annotator_data.gui. ...
%                                t_filter, 'String');
%         h =  eval(get(feature_annotator_data.gui.t_filter,'String'));
%         % normalize if there are no negative values of h
%         if all(h>=0)
%             h = h./sum_all(h);
%         end
%         
%         time_offsets = (1:length(h)) - floor(length(h)/2+1);
%         
%         im=double(imread(fullfile(feature_annotator_data.image_location,...
%                                 sprintf('T_%05d.tif',...
%                                 t+time_offsets(1))))) ...
%              * h(1);
%         
%         for i = 2:length(time_offsets)
%             if h(i) ~= 0 % save some time by skipping these
%             im =  im + double(...
%                   imread(fullfile(feature_annotator_data.image_location,...
%                                 sprintf('T_%05d.tif',...
%                                 t+time_offsets(i))))) ...
%                   * h(i);  
%             end
%         end
%         
%     end
%     
%     % xy filter
%     if get(feature_annotator_data.gui.xy_filter_checkbox,'Value')
%         xy_filter_string = get(feature_annotator_data.gui. ...
%                                xy_filter, 'String');
%         h =  eval(get(feature_annotator_data.gui.xy_filter,'String'));
%         
%         if xy_filter_string(1)=='@' % function handle?
%             im = h(im);
%         else
%             % normalize if there are no negative values of h
%             if all(h>=0)
%                 h = h./sum_all(h);
%             end
%             im = imfilter(im,h);
%         end
%     end  
%     
%     % xy threshold
%     if get(feature_annotator_data.gui.xy_threshold_checkbox,'Value')
%         threshold = get(feature_annotator_data.gui. ...
%                                xy_threshold, 'String');
%         im = im > str2num(threshold);
%         feature_annotator_data.image = imshow(im,...
%             [0 1], ...
%             'Parent', feature_annotator_data.gui.axes1);
%     else
%         feature_annotator_data.image = imshow(im,...
%             feature_annotator_data.LUT, ...
%             'Parent', feature_annotator_data.gui.axes1);
%     end  
%     
%     % attach a mouse action handler to the image
%     set(feature_annotator_data.image, 'ButtonDownFcn', ...
%           @(x,y) feature_annotator_callbacks('mouseclick_handler',y));
%     
%     
%     % features to draw
%     
%     features = feature_annotator_data.features(...
%                  get(feature_annotator_data.gui.feature_list,'Value')...
%                );
% 
%     active_feature = get(feature_annotator_data.gui.active_feature,...
%                             'Value');
%     if ~isempty(features)
%         % currently this only works for rectangular features
%         for i = 1:length(features)
%             if ~isfield(features{i},'coordinates')
%                 continue;
%             end
%             
%             if strcmp(features{i}.name, ...
%                       feature_annotator_data.features{active_feature}.name)
%                 edge_color = [0 1 0]; % green
%             else 
%                 edge_color = [1 0 0]; % red
%             end
%             
%             coords = features{i}.coordinates(t,:);
%             
%             % make modified features outlined in a different color
%             if all(~isnan( ...
%                     features{i}. ...
%                       modified_coordinates(t,:)))
%                 coords = features{i}.modified_coordinates(t,:);
%                 edge_color = edge_color + [0 0 1];
%             end
%             
%             rectangle('Position', ...
%                         [ coords(2) ... % x
%                           coords(1) ... % y
%                           features{i}.size(2)+1 ... % width
%                           features{i}.size(1)+1 ... % height
%                         ], ...
%                       'LineWidth', 2,...
%                       'EdgeColor', edge_color, ...
%                       'Parent', feature_annotator_data.gui.axes1);
%              if isfield(features{i},'ref_offset')
%                 ref_point = coords + ...
%                             features{i}.ref_offset;
%                 if size_Z == 1 || z == round(ref_point(3))
%                     hold on;
%                     plot(ref_point(2),ref_point(1),'.',...
%                         'MarkerEdgeColor', edge_color);
%                     hold off; %very important
%                 end
%            end
%         end
%     end
%         
    %
    % draw 3D image
    %
%         otherwise
            
    % figure title
    set(feature_annotator_data.gui.top_text, 'String', sprintf( ...
        ['T: %1d of %1d           Rate: %1d frame[s]/click' ...
         '           Z: %1d of %1d'], ...
        t, size_T, dt, z, size_Z));

    % if we're not drawing projections, we can be frugal and only take one
    % slice at a time from the disk to render fast.
    if ~get(feature_annotator_data.gui.show_projections,'Value')
    
    % load image
    im = load_image([], 't', t, 'z', z);

    % t filter not implemented, because we'd have to filter for lots of
    % z-values.  It may make sense to create a 4D volume and then convolve
    % x,y,z, and t simultaeneously.  Unless that is too slow.
    if get(feature_annotator_data.gui.t_filter_checkbox,'Value')
        warndlg('t-filtering not implemented for 3D images');
        set(feature_annotator_data.gui.t_filter_checkbox, false);
        t_filter_string = get(feature_annotator_data.gui. ...
                               t_filter, 'String');
    end
    
    % z filter
    if get(feature_annotator_data.gui.z_filter_checkbox,'Value')
        z_filter_string = get(feature_annotator_data.gui. ...
                              z_filter, 'String');
        h = evalin('base', z_filter_string);
        
        if z_filter_string(1)=='@' % function handle?
            warndlg('functions for z-filtering not implemented');
        else
            if all(h>=0)
                h = h./sum_all(h);
            end
            
            min_z = max(z - floor(length(h)/2),...
                        1);
            max_z = min(z + ceil(length(h)/2) - 1,...
                        size_Z);
            im = zeros(size(im));
            for iz = min_z:max_z
                new_im = double(load_image([], 't', t, 'z', iz));
                idx = iz - z + ceil(length(h)/2);                
                im = im + h(idx)*new_im;
            end
        end
    end
    
    % xy filter
    if get(feature_annotator_data.gui.xy_filter_checkbox,'Value')
        xy_filter_string = get(feature_annotator_data.gui. ...
                               xy_filter, 'String');
        h =  evalin('base', xy_filter_string);
        
        if xy_filter_string(1)=='@' % function handle?
            im = h(im);
        else
            % normalize if there are no negative values of h
            if all(h>=0)
                h = h./sum_all(h);
            end
            im = imfilter(im,h);
        end
    end  
    
    % threshold
    if get(feature_annotator_data.gui.threshold_checkbox,'Value')
        threshold = str2double(get(feature_annotator_data.gui. ...
                               threshold, 'String'));
        im(im<threshold) = 0;
    end
    
       
    % binary threshold
    if get(feature_annotator_data.gui.binary_threshold_checkbox,'Value')
        threshold = str2double(get(feature_annotator_data.gui. ...
                               binary_threshold, 'String'));
        im = im > threshold;
        LUT = [0 1];
    else
        LUT = feature_annotator_data.LUT;   
    end 

    feature_annotator_data.image = imshow(im,...
            LUT, ...
            'Parent', feature_annotator_data.gui.axes1);
        
    % features to draw
    
    features = feature_annotator_data.features(...
                 get(feature_annotator_data.gui.feature_list,'Value')...
               );

    active_feature = get(feature_annotator_data.gui.active_feature,...
                            'Value');
    if ~isempty(features)
        % currently this only works for rectangular features
        for i = 1:length(features)
            
            % color the active feature green [or blue if modified]
            if strcmp(features{i}.name, ...
                      feature_annotator_data.features{active_feature}.name)
                edge_color = [0 1 0]; % green for active features
            else 
                edge_color = [1 0 0]; % red for inactive features
            end
            
            coords = features{i}.coordinates(t,:);
                       
            
            
            if z > coords(3) && ...
               z < coords(3) + features{i}.size(3) % inside the volume
                    
            
                rectangle('Position', ...
                            [ coords(2) ... % x
                              coords(1) ... % y
                              features{i}.size(2)+1 ... % width
                              features{i}.size(1)+1 ... % height
                            ], ...
                          'LineWidth', 2,...
                          'EdgeColor', edge_color, ...
                          'Parent', feature_annotator_data.gui.axes1);
                      
            elseif z == coords(3) || ...
                   z == coords(3) + features{i}.size(3) % top/bottom face
                    
                rectangle('Position', ...
                            [ coords(2) ... % x
                              coords(1) ... % y
                              features{i}.size(2)+1 ... % width
                              features{i}.size(1)+1 ... % height
                            ], ...
                      'LineWidth', 7,... % make top/bottom faces bold
                      'EdgeColor', edge_color, ...
                      'Parent', feature_annotator_data.gui.axes1);
            else
                rectangle('Position', ...
                            [ coords(2) ... % x
                              coords(1) ... % y
                              features{i}.size(2)+1 ... % width
                              features{i}.size(1)+1 ... % height
                            ], ...
                      'LineWidth', 1,... % make a dim outline outside vol
                      'LineStyle',':',... % dotted, too
                      'EdgeColor', 0.8*edge_color, ...
                      'Parent', feature_annotator_data.gui.axes1);
            end
           if isfield(features{i},'ref_offset')
                ref_point = coords + ...
                            features{i}.ref_offset;
                if size_Z == 1 || z == round(ref_point(3))
                    hold on;
                    plot(ref_point(2),ref_point(1),'*',...
                        'MarkerEdgeColor', edge_color);
                    hold off; %very important
                end
           end
           
           % make modified features outlined in a different color
            if all(~isnan( ...
                    features{i}. ...
                      modified_coordinates(t,:)))
                coords = features{i}.modified_coordinates(t,:);
                edge_color = edge_color + [0 0 1];
                if z > coords(3) && ...
                   z < coords(3) + features{i}.size(3) % inside the volume


                    rectangle('Position', ...
                                [ coords(2) ... % x
                                  coords(1) ... % y
                                  features{i}.size(2)+1 ... % width
                                  features{i}.size(1)+1 ... % height
                                ], ...
                              'LineWidth', 2,...
                              'EdgeColor', edge_color, ...
                              'Parent', feature_annotator_data.gui.axes1);

                elseif z == coords(3) || ...
                       z == coords(3) + features{i}.size(3) % top/bottom

                    rectangle('Position', ...
                                [ coords(2) ... % x
                                  coords(1) ... % y
                                  features{i}.size(2)+1 ... % width
                                  features{i}.size(1)+1 ... % height
                                ], ...
                          'LineWidth', 3,... % make top/bottom faces bold
                          'EdgeColor', edge_color, ...
                          'Parent', feature_annotator_data.gui.axes1);
                else
                    rectangle('Position', ...
                                [ coords(2) ... % x
                                  coords(1) ... % y
                                  features{i}.size(2)+1 ... % width
                                  features{i}.size(1)+1 ... % height
                                ], ...
                          'LineWidth', 1,... % make a dim outline outside
                          'LineStyle',':',... % dotted, too
                          'EdgeColor', 0.8*edge_color, ...
                          'Parent', feature_annotator_data.gui.axes1);
                end
               if isfield(features{i},'ref_offset')
                    ref_point = coords + ...
                                features{i}.ref_offset;
                    if size_Z == 1 || z == round(ref_point(3))
                        hold on;
                        plot(ref_point(2),ref_point(1),'*',...
                            'MarkerEdgeColor', edge_color);
                        hold off; %very important
                    end
               end
            end
            
        end
    end
    
    else % 3D, and we need to calculate projections
    
    % load image
    if isfield(feature_annotator_data, 'projection_ok') && ...
       ~feature_annotator_data.projection_ok
   
        feature_annotator_data.vol = load_image([], 't', t);
    end
    
    vol = feature_annotator_data.vol;
    im = double(squeeze(vol(:,:,z)));
    
    size_Y = size(im,1);
    size_X = size(im,2);
    
    % t filter not implemented, because we'd have to filter for lots of
    % z-values.  It may make sense to create a 4D volume and then convolve
    % x,y,z, and t simultaeneously.  Unless that is too slow.
    if get(feature_annotator_data.gui.t_filter_checkbox,'Value')
        warning('t-filtering not implemented for 3D images');
        set(feature_annotator_data.gui.t_filter_checkbox,'Value', false);
    end
    
    vol = feature_annotator_filter(vol);
    
    if max_all(vol) == 1
        LUT = [0 1];
    else
        LUT = feature_annotator_data.LUT;
    end
    
    im = vol(:,:,z); 
    
    % draw main image
    feature_annotator_data.image = imshow(im,...
            LUT, ...
            'Parent', feature_annotator_data.gui.axes1);

    % calculate and draw projections if needed
    if ~isfield(feature_annotator_data, 'projection_ok') || ...
       ~feature_annotator_data.projection_ok 
       
    projector = ...
      eval(get(feature_annotator_data.gui.projection_function, 'String'));
                    
    xy_proj = projector(vol, 3); % along stacks (z-direction)
    zy_proj = projector(vol, 2); % along columns (x-direction)
    xz_proj = projector(vol, 1)'; % along rows (y-direction)
    imshow(xy_proj, LUT, 'Parent', feature_annotator_data.gui.axes_xy)
    imshow(zy_proj, LUT, 'Parent', feature_annotator_data.gui.axes_zy, ...
           'XData', [1 2*size_Z], 'YData', [1 size_Y]);
    imshow(xz_proj, LUT, 'Parent', feature_annotator_data.gui.axes_xz, ...
           'XData', [1 size_X], 'YData', [1 2*size_Z]);
    
    axes(feature_annotator_data.gui.axes_xz)
    feature_annotator_data.gui.projection_hline = hline(2*z,'--g');
    
    axes(feature_annotator_data.gui.axes_zy)
    feature_annotator_data.gui.projection_vline = vline(2*z,'--g');
       
    feature_annotator_data.projection_ok = true;
    end
    
    z_r = z/size_Z;
    if isfield(feature_annotator_data.gui, 'projection_hline') 
        if ishandle(feature_annotator_data.gui.projection_hline)
            set(feature_annotator_data.gui.projection_hline, ...
                'YData', [z z]*2);
        else
            axes(feature_annotator_data.gui.axes_xz)
            feature_annotator_data.gui.projection_hline = hline(2*z,'--g');
        end
    end
    if isfield(feature_annotator_data.gui, 'projection_vline')
        if ishandle(feature_annotator_data.gui.projection_vline)
            set(feature_annotator_data.gui.projection_vline, ...
                'XData', [z z]*2);
        else
            axes(feature_annotator_data.gui.axes_zy)
            feature_annotator_data.gui.projection_vline = vline(2*z,'--g');
        end
    end
        
    % features to draw
    
    features = feature_annotator_data.features(...
                 get(feature_annotator_data.gui.feature_list,'Value')...
               );

    active_feature = get(feature_annotator_data.gui.active_feature,...
                            'Value');
    if ~isempty(features)
        % currently this only works for rectangular features
        for i = 1:length(features)
        if ~isfield(features{i}, 'is_bad_frame') || ...
           ~features{i}.is_bad_frame(t)
           
            % color the active feature green [or blue if modified]
            if strcmp(features{i}.name, ...
                      feature_annotator_data.features{active_feature}.name)
                edge_color = [0 1 0]; % green for active features
            else 
                edge_color = [1 0 0]; % red for inactive features
            end
            
             coords = features{i}.coordinates(t,:);
             siz = features{i}.size;
            
            if z > coords(3) && ...
               z < coords(3) + features{i}.size(3) % inside the volume
                    
                rectangle('Position', ...
                            [ coords(2) ... % x
                              coords(1) ... % y
                              siz(2) ... % width
                              siz(1) ... % height
                            ], ...
                          'LineWidth', 2,...
                          'EdgeColor', edge_color, ...
                          'Parent', feature_annotator_data.gui.axes1);
                      
            elseif z == coords(3) || ...
                   z == coords(3) + features{i}.size(3) % top/bottom face
                    
                rectangle('Position', ...
                            [ coords(2) ... % x
                              coords(1) ... % y
                              siz(2) ... % width
                              siz(1) ... % height
                            ], ...
                      'LineWidth', 3,... % make top/bottom faces bold
                      'EdgeColor', edge_color, ...
                      'Parent', feature_annotator_data.gui.axes1);
            else
                rectangle('Position', ...
                            [ coords(2) ... % x
                              coords(1) ... % y
                              siz(2) ... % width
                              siz(1) ... % height
                            ], ...
                      'LineWidth', 1,... % make a dim outline outside vol
                      'LineStyle',':',... % dotted, too
                      'EdgeColor', 0.8*edge_color, ...
                      'Parent', feature_annotator_data.gui.axes1);
            end
           if isfield(features{i},'ref_offset')
                ref_point = coords + ...
                            features{i}.ref_offset;
                if size_Z == 1 || z == round(ref_point(3))
                    axes(feature_annotator_data.gui.axes1);
                    hold on;
                    plot(ref_point(2),ref_point(1),'*',...
                        'MarkerEdgeColor', edge_color ...
                        );
                    hold off; %very important
                end
           end

           % draw rectangles on the projections
           if get(feature_annotator_data.gui.show_projections, 'Value')
               size_X = size(im, 2);
               size_Y = size(im, 1);
               
               rectangle('Position', ...
                           [ coords(2) ...
                             coords(1) ...
                             siz(2) ...   
                             siz(1)], ...
                         'LineWidth', 2, ...
                         'EdgeColor', edge_color, ...
                         'Parent', feature_annotator_data.gui.axes_xy);
               
               rectangle('Position', ...
                           [ coords(2) ...
                             coords(3)*2 ...
                             siz(2) ...
                             siz(3)*2], ...
                         'LineWidth', 2, ...
                         'EdgeColor', edge_color, ...
                         'Parent', feature_annotator_data.gui.axes_xz);
               
               rectangle('Position', ...
                           [ coords(3)*2 ...
                             coords(1) ...
                             siz(3)*2 ...
                             siz(1)], ...
                         'LineWidth', 2, ...
                         'EdgeColor', edge_color, ...
                         'Parent', feature_annotator_data.gui.axes_zy);
           end
           
                     
            % make modified features outlined in a different color
            if all(~isnan( ...
                features{i}. ...
                  modified_coordinates(t,:)))
                coords = features{i}.modified_coordinates(t,:);
                edge_color = edge_color + [0 0 1];
                if z > coords(3) && ...
                   z < coords(3) + features{i}.size(3) % inside the volume

                    rectangle('Position', ...
                                [ coords(2) ... % x
                                  coords(1) ... % y
                                  siz(2) ... % width
                                  siz(1) ... % height
                                ], ...
                              'LineWidth', 2,...
                              'EdgeColor', edge_color, ...
                              'Parent', feature_annotator_data.gui.axes1);

                elseif z == coords(3) || ...
                       z == coords(3) + features{i}.size(3) % top/bottom

                    rectangle('Position', ...
                                [ coords(2) ... % x
                                  coords(1) ... % y
                                  siz(2) ... % width
                                  siz(1) ... % height
                                ], ...
                          'LineWidth', 3,... % make top/bottom faces bold
                          'EdgeColor', edge_color, ...
                          'Parent', feature_annotator_data.gui.axes1);
                else
                    rectangle('Position', ...
                                [ coords(2) ... % x
                                  coords(1) ... % y
                                  siz(2) ... % width
                                  siz(1) ... % height
                                ], ...
                          'LineWidth', 1,... % make a dim outline outside
                          'LineStyle',':',... % dotted, too
                          'EdgeColor', 0.8*edge_color, ...
                          'Parent', feature_annotator_data.gui.axes1);
                end
               if isfield(features{i},'ref_offset')
                    ref_point = coords + ...
                                features{i}.ref_offset;
                    if size_Z == 1 || z == round(ref_point(3))
                        axes(feature_annotator_data.gui.axes1);
                        hold on;
                        plot(ref_point(2),ref_point(1),'*',...
                            'MarkerEdgeColor', edge_color ...
                            );
                        hold off; %very important
                    end
               end

               % draw rectangles on the projections
               if get(feature_annotator_data.gui.show_projections, 'Value')
                   size_X = size(im, 2);
                   size_Y = size(im, 1);

                   rectangle('Position', ...
                               [ coords(2) ...
                                 coords(1) ...
                                 siz(2) ...   
                                 siz(1)], ...
                             'LineWidth', 2, ...
                             'EdgeColor', edge_color, ...
                             'Parent', feature_annotator_data.gui.axes_xy);

                   rectangle('Position', ...
                               [ coords(2) ...
                                 coords(3)*2 ...
                                 siz(2) ...
                                 siz(3)*2], ...
                             'LineWidth', 2, ...
                             'EdgeColor', edge_color, ...
                             'Parent', feature_annotator_data.gui.axes_xz);

                   rectangle('Position', ...
                               [ coords(3)*2 ...
                                 coords(1) ...
                                 siz(3)*2 ...
                                 siz(1)], ...
                             'LineWidth', 2, ...
                             'EdgeColor', edge_color, ...
                             'Parent', feature_annotator_data.gui.axes_zy);
               end
            end
           
        end
        end
    end
    
    end
%     end % switch for 2d versus 3d image drawing
    
   
end


