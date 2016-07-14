function varargout = scope_controls(varargin)
% SCOPE_CONTROLS MATLAB code for scope_controls.fig
%      SCOPE_CONTROLS, by itself, creates a new SCOPE_CONTROLS or raises the existing
%      singleton*.
%
%      H = SCOPE_CONTROLS returns the handle to a new SCOPE_CONTROLS or the handle to
%      the existing singleton*.
%
%      SCOPE_CONTROLS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SCOPE_CONTROLS.M with the given input arguments.
%
%      SCOPE_CONTROLS('Property','Value',...) creates a new SCOPE_CONTROLS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before scope_controls_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to scope_controls_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help scope_controls

% Last Modified by GUIDE v2.5 18-May-2015 17:24:23

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @scope_controls_OpeningFcn, ...
                   'gui_OutputFcn',  @scope_controls_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before scope_controls is made visible.
function scope_controls_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to scope_controls (see VARARGIN)

% Choose default command line output for feature_annotator
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes scope_controls wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = scope_controls_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in camera_on_pb.
function camera_on_pb_Callback(hObject, eventdata, handles)
% hObject    handle to camera_on_pb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global scope;
scope.prepare_continuous();
scope.camera_on();

% --- Executes on button press in camera_off_pb.
function camera_off_pb_Callback(hObject, eventdata, handles)
% hObject    handle to camera_off_pb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global scope;
scope.camera_off();

% --- Executes on button press in tracker_on_pb.
function tracker_on_pb_Callback(hObject, eventdata, handles)
% hObject    handle to tracker_on_pb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global scope;
scope.tracker_on();

% --- Executes on button press in tracker_off_pb.
function tracker_off_pb_Callback(hObject, eventdata, handles)
% hObject    handle to tracker_off_pb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global scope;
scope.tracker_off();

% --- Executes on button press in record_pb.
function record_pb_Callback(hObject, eventdata, handles)
% hObject    handle to record_pb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global scope;
scope.recorder_on();

% --- Executes on button press in stop_pb.
function stop_pb_Callback(hObject, eventdata, handles)
% hObject    handle to stop_pb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global scope;
scope.recorder_off();


function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
global scope;
set(hObject, 'String', scope.Logger.Directory);




% --- Executes on button press in restart_camera_pb.
function restart_camera_pb_Callback(hObject, eventdata, handles)
% hObject    handle to restart_camera_pb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global scope;
scope.camera_off();
%scope.prepare_continuous();
scope.camera_on();



function purple_eth_Callback(hObject, eventdata, handles)
% hObject    handle to purple_eth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global scope;
scope.Purple = str2double(get(hObject,'String'));


% --- Executes during object creation, after setting all properties.
function purple_eth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to purple_eth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
global scope;
set(hObject, 'String', num2str(scope.Purple));


% --- Executes on button press in purple_on.
function purple_on_Callback(hObject, eventdata, handles)
% hObject    handle to purple_on (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global scope;
scope.PurpleOn = true;

% --- Executes on button press in purple_off.
function purple_off_Callback(hObject, eventdata, handles)
% hObject    handle to purple_off (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global scope;
scope.PurpleOn = false;


function gfp_eth_Callback(hObject, eventdata, handles)
% hObject    handle to gfp_eth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global scope;
scope.GFP = str2double(get(hObject,'String'));

% --- Executes during object creation, after setting all properties.
function gfp_eth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gfp_eth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
global scope;
set(hObject, 'String', num2str(scope.GFP));


% --- Executes on button press in gfp_on.
function gfp_on_Callback(hObject, eventdata, handles)
% hObject    handle to gfp_on (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global scope;
scope.GFPOn = true;

% --- Executes on button press in gfp_off.
function gfp_off_Callback(hObject, eventdata, handles)
% hObject    handle to gfp_off (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global scope;
scope.GFPOn = false;


function rfp_eth_Callback(hObject, eventdata, handles)
% hObject    handle to rfp_eth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global scope;
scope.RFP = str2double(get(hObject,'String'));

% --- Executes during object creation, after setting all properties.
function rfp_eth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rfp_eth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
global scope;
set(hObject, 'String', num2str(scope.RFP));


% --- Executes on button press in rfp_on.
function rfp_on_Callback(hObject, eventdata, handles)
% hObject    handle to rfp_on (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global scope;
scope.RFPOn = true;

% --- Executes on button press in rfp_off.
function rfp_off_Callback(hObject, eventdata, handles)
% hObject    handle to rfp_off (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global scope;
scope.RFPOn = false;



function gainxy_eth_Callback(hObject, eventdata, handles)
% hObject    handle to gainxy_eth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global scope;
scope.Tracker.GainXY = str2double(get(hObject,'String'));


% --- Executes during object creation, after setting all properties.
function gainxy_eth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gainxy_eth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
global scope;
set(hObject, 'String', num2str(scope.Tracker.GainXY));


function threshold_eth_Callback(hObject, eventdata, handles)
% hObject    handle to threshold_eth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global scope;
scope.Tracker.BinaryThreshold = str2double(get(hObject,'String'));

% --- Executes during object creation, after setting all properties.
function threshold_eth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to threshold_eth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
global scope;
set(hObject, 'String', num2str(scope.Tracker.BinaryThreshold));


function tracking_radius_eth_Callback(hObject, eventdata, handles)
% hObject    handle to tracking_radius_eth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global scope;
scope.Tracker.TrackingRadius = str2double(get(hObject,'String'));


% --- Executes during object creation, after setting all properties.
function tracking_radius_eth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tracking_radius_eth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
global scope;
set(hObject, 'String', num2str(scope.Tracker.TrackingRadius));



function velocity_damping_eth_Callback(hObject, eventdata, handles)
% hObject    handle to velocity_damping_eth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global scope;
scope.Tracker.DampingXY = str2double(get(hObject,'String'));


% --- Executes during object creation, after setting all properties.
function velocity_damping_eth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to velocity_damping_eth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
global scope;
set(hObject, 'String', num2str(scope.Tracker.DampingXY));


function gainz_eth_Callback(hObject, eventdata, handles)
% hObject    handle to gainz_eth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global scope;
scope.Tracker.GainZ = str2double(get(hObject,'String'));

% --- Executes during object creation, after setting all properties.
function gainz_eth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gainz_eth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
global scope;
set(hObject, 'String', num2str(scope.Tracker.GainZ));


function z_update_eth_Callback(hObject, eventdata, handles)
% hObject    handle to z_update_eth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global scope;
scope.Tracker.UpdatePeriodZ = str2double(get(hObject,'String'));

% --- Executes during object creation, after setting all properties.
function z_update_eth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to z_update_eth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
global scope;
set(hObject, 'String', num2str(scope.Tracker.UpdatePeriodZ));


function raster_offset_eth_Callback(hObject, eventdata, handles)
% hObject    handle to raster_offset_eth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global scope;
scope.ZRasterOffset  = str2double(get(hObject,'String'));

% --- Executes during object creation, after setting all properties.
function raster_offset_eth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to raster_offset_eth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
global scope;
set(hObject, 'String', num2str(scope.ZRasterOffset));


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on key press with focus on figure1 and none of its controls.
function figure1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
global scope;

switch eventdata.Character
    
    % Start acquisition
    case 'f'
        scope.prepare_continuous();
        scope.camera_on();

    % Stop acquisition
    case 'd'
        scope.camera_off();
        
    % Start tracking
    case 't'
        scope.tracker_on();
        
    % Stop tracking
    case 's'
        scope.tracker_off();
        
    % Begin recording
    case 'r'
        scope.recorder_on();
        
    % End recording
    case 'e'
        scope.recorder_off();
        
    % restart
    case 'q'
        scope.recorder_off();
        scope.tracker_off();
        scope.camera_off();
        pause(0.2);
        scope.prepare_continuous();
        scope.camera_on();
        
        
end
