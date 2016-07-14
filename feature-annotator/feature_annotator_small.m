function varargout = feature_annotator(varargin)
% FEATURE_ANNOTATOR MATLAB code for feature_annotator.fig
%      FEATURE_ANNOTATOR, by itself, creates a new FEATURE_ANNOTATOR or raises the existing
%      singleton*.
%
%      H = FEATURE_ANNOTATOR returns the handle to a new FEATURE_ANNOTATOR or the handle to
%      the existing singleton*.
%
%      FEATURE_ANNOTATOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FEATURE_ANNOTATOR.M with the given input arguments.
%
%      FEATURE_ANNOTATOR('Property','Value',...) creates a new FEATURE_ANNOTATOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before feature_annotator_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to feature_annotator_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help feature_annotator

% Last Modified by GUIDE v2.5 21-May-2014 15:24:17

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @feature_annotator_OpeningFcn, ...
                   'gui_OutputFcn',  @feature_annotator_OutputFcn, ...
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


% --- Executes just before feature_annotator is made visible.
function feature_annotator_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to feature_annotator (see VARARGIN)

% Choose default command line output for feature_annotator
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
feature_annotator_callbacks('open',handles);

% UIWAIT makes feature_annotator wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = feature_annotator_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function time_slider_Callback(hObject, eventdata, handles)
% hObject    handle to time_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
feature_annotator_callbacks('time_slider');



% --- Executes during object creation, after setting all properties.
function time_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to time_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function LUT_low_Callback(hObject, eventdata, handles)
% hObject    handle to LUT_low (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
feature_annotator_callbacks('LUT_low_slider');
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function LUT_low_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LUT_low (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function LUT_high_Callback(hObject, eventdata, handles)
% hObject    handle to LUT_high (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
feature_annotator_callbacks('LUT_high_slider');



% --- Executes during object creation, after setting all properties.
function LUT_high_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LUT_high (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in new_feature_pb.
function new_feature_pb_Callback(hObject, eventdata, handles)
% hObject    handle to new_feature_pb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
feature_annotator_callbacks('new_feature');


% --- Executes on selection change in feature_list.
function feature_list_Callback(hObject, eventdata, handles)
% hObject    handle to feature_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
feature_annotator_callbacks('feature_list');
% Hints: contents = cellstr(get(hObject,'String')) returns feature_list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from feature_list


% --- Executes during object creation, after setting all properties.
function feature_list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to feature_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in active_feature.
function active_feature_Callback(hObject, eventdata, handles)
% hObject    handle to active_feature (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
feature_annotator_callbacks('active_feature');
% Hints: contents = cellstr(get(hObject,'String')) returns active_feature contents as cell array
%        contents{get(hObject,'Value')} returns selected item from active_feature


% --- Executes during object creation, after setting all properties.
function active_feature_CreateFcn(hObject, eventdata, handles)
% hObject    handle to active_feature (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in segmentation_method.
function segmentation_method_Callback(hObject, eventdata, handles)
% hObject    handle to segmentation_method (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns segmentation_method contents as cell array
%        contents{get(hObject,'Value')} returns selected item from segmentation_method


% --- Executes during object creation, after setting all properties.
function segmentation_method_CreateFcn(hObject, eventdata, handles)
% hObject    handle to segmentation_method (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function timeout_Callback(hObject, eventdata, handles)
% hObject    handle to timeout (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of timeout as text
%        str2double(get(hObject,'String')) returns contents of timeout as a double


% --- Executes during object creation, after setting all properties.
function timeout_CreateFcn(hObject, eventdata, handles)
% hObject    handle to timeout (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in run_segmentation.
function run_segmentation_Callback(hObject, eventdata, handles)
% hObject    handle to run_segmentation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
feature_annotator_callbacks('auto_segment');


% --- Executes on button press in tif_directory_pb.
function tif_directory_pb_Callback(hObject, eventdata, handles)
% hObject    handle to tif_directory_pb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
feature_annotator_callbacks('tif_directory');


% --- Executes on key press with focus on figure1 and none of its controls.
function figure1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
feature_annotator_callbacks('keypress_handler', eventdata);


% --- Executes on mouse press over axes background.
function axes1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
feature_annotator_callbacks('mouseclick_handler', eventdata);


% --- Executes on button press in use_filters_for_segmentation.
function use_filters_for_segmentation_Callback(hObject, eventdata, handles)
% hObject    handle to use_filters_for_segmentation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of use_filters_for_segmentation



function xy_filter_Callback(hObject, eventdata, handles)
% hObject    handle to xy_filter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

feature_annotator_callbacks('update_filter');


% --- Executes during object creation, after setting all properties.
function xy_filter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xy_filter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in xy_filter_checkbox.
function xy_filter_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to xy_filter_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
feature_annotator_callbacks('update_filter');



function binary_threshold_Callback(hObject, eventdata, handles)
% hObject    handle to binary_threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
feature_annotator_callbacks('update_filter');


% --- Executes during object creation, after setting all properties.
function binary_threshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to binary_threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in binary_threshold_checkbox.
function binary_threshold_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to binary_threshold_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
feature_annotator_callbacks('update_filter');


function t_filter_Callback(hObject, eventdata, handles)
% hObject    handle to t_filter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
feature_annotator_callbacks('update_filter');


% --- Executes during object creation, after setting all properties.
function t_filter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to t_filter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in t_filter_checkbox.
function t_filter_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to t_filter_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
feature_annotator_callbacks('update_filter');


% --- Executes on button press in save_updates.
function save_updates_Callback(hObject, eventdata, handles)
% hObject    handle to save_updates (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
feature_annotator_callbacks('save_updates');


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



function z_filter_Callback(hObject, eventdata, handles)
% hObject    handle to z_filter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
feature_annotator_callbacks('update_filter');


% --- Executes during object creation, after setting all properties.
function z_filter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to z_filter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in z_filter_checkbox.
function z_filter_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to z_filter_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
feature_annotator_callbacks('update_filter');


% --- Executes on key press with focus on feature_list and none of its controls.
function feature_list_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to feature_list (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
feature_annotator_callbacks('feature_list_keypress_handler',eventdata);



function projection_function_Callback(hObject, eventdata, handles)
% hObject    handle to projection_function (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
feature_annotator_callbacks('update_filter');



% --- Executes during object creation, after setting all properties.
function projection_function_CreateFcn(hObject, eventdata, handles)
% hObject    handle to projection_function (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in show_projections.
function show_projections_Callback(hObject, eventdata, handles)
% hObject    handle to show_projections (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
feature_annotator_callbacks('update_filter');


% --------------------------------------------------------------------
function open_toolbar_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to open_toolbar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
feature_annotator_callbacks('set_image_location');


% --------------------------------------------------------------------
function save_toolbar_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to save_toolbar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
feature_annotator_callbacks('save_updates');



function decimation_Callback(hObject, eventdata, handles)
% hObject    handle to decimation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
feature_annotator_callbacks('update_filter');


% --- Executes during object creation, after setting all properties.
function decimation_CreateFcn(hObject, eventdata, handles)
% hObject    handle to decimation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in decimate_checkbox.
function decimate_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to decimate_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
feature_annotator_callbacks('update_filter');



function threshold_Callback(hObject, eventdata, handles)
% hObject    handle to threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
feature_annotator_callbacks('update_filter');


% --- Executes during object creation, after setting all properties.
function threshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in threshold_checkbox.
function threshold_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to threshold_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
feature_annotator_callbacks('update_filter');
