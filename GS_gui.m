function varargout = GS_gui(varargin)
% GS_GUI MATLAB code for GS_gui.fig
%      GS_GUI, by itself, creates a new GS_GUI or raises the existing
%      singleton*.
%
%      H = GS_GUI returns the handle to a new GS_GUI or the handle to
%      the existing singleton*.
%
%      GS_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GS_GUI.M with the given input arguments.
%
%      GS_GUI('Property','Value',...) creates a new GS_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GS_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GS_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GS_gui

% Last Modified by GUIDE v2.5 07-Jan-2015 16:24:09

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GS_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @GS_gui_OutputFcn, ...
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

% --- Executes just before GS_gui is made visible.
function varargout = GS_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GS_gui (see VARARGIN)

% Choose default command line output for GS_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Reset the mission log ===================================================
str = cellstr(get(handles.Mission_Log,'String'));
mission_start_str = ['===================================== Mission Start: ' ...
    datestr(now) ' ======================================='];
if size(str,1) > 1
    newstr = str;
    newstr{end+1,1} = mission_start_str;
else
    newstr = mission_start_str;
end
set(handles.Mission_Log,'String',newstr);
set(handles.Mission_Log,'ListboxTop',size(newstr,1));

% UIWAIT makes GS_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GS_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1,1} = handles;

a = timer;
timer_period = 10;
set(a,'executionMode','fixedRate')
set(a,'TimerFcn','request_status_Callback(handles)','BusyMode','queue','Period',timer_period,'StartDelay',timer_period,'Tag','heartbeat_timer')
% start(a)

varargout{2,1} = a;


% --- Executes on selection change in Mission_Log.
function Mission_Log_Callback(hObject, eventdata, handles)
% hObject    handle to Mission_Log (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% contents = cellstr(get(hObject,'String'));
% selection = [contents{get(hObject,'Value')} ' <-- SELECTED'];
% contents{get(hObject,'Value')} = selection;
% set(hObject,'String',contents);

% Hints: contents = cellstr(get(hObject,'String')) returns Mission_Log contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Mission_Log


% --- Executes during object creation, after setting all properties.
function Mission_Log_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Mission_Log (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Abort_Button.
function Abort_Button_Callback(hObject, eventdata, handles)
% hObject    handle to Abort_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Set the quit_flag in the workspace to 1 =================================
evalin('base','quit_flag = 1;')


% --- Executes on button press in send_command_button.
function send_command_button_Callback(hObject, eventdata, handles)
% hObject    handle to send_command_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Switch case for different radio buttons being selected
switch get(get(handles.command_options_button_group,'SelectedObject'),'Tag')
    case 'rappel_option'
        % Get the manual rappelling distance ==============================
        rappel_dist_m = str2double(get(handles.rappel_distance_m,'String'));
        % Determine the sign to put in the command packet =================
        if rappel_dist_m < 0
            rappel_dist_sign = '-';
        else
            rappel_dist_sign = '+';
        end
        % Format the command string =======================================
        cmd_str = sprintf('$R0%c%03d\n',rappel_dist_sign,abs(rappel_dist_m)*100);
    case 'drive_option'
        % Get the driving distance and determine direction ================
        drive_dist_m = str2double(get(handles.drive_distance_m,'String'));
        if drive_dist_m <= 0
            drive_dir = 'B';
        else
            drive_dir = 'F';
        end
        % Format the command string and make the log entry ================
        cmd_str = sprintf('$D%c%03d\n',drive_dir,drive_dist_m*100);
    case 'turn_option'
        % Get the turning angle and determine direction ===================
        turn_ang_deg = str2double(get(handles.turn_angle_deg,'String'));
        if turn_ang_deg <= 0 % A negative turn is left/counter-clockwise
            turn_dir = 'L';
        else
            turn_dir = 'R';
        end
        % Format the command string and make the log entry ================
        cmd_str = sprintf('$D%c%03d\n',turn_dir,turn_ang_deg);
    case 'capture_image'
        % Get the user-input pan and tilt angles ==========================
        pan_angle_deg = str2double(get(handles.pan_angle_deg,'String'));
        tilt_angle_deg = str2double(get(handles.tilt_angle_deg,'String'));
        if pan_angle_deg < 0
            pan_angle_sign = '-';
        else
            pan_angle_sign = '+';
        end
        % Construct the command string and "capture" the image ============
        cmd_str = sprintf('$I%c%02d%02d\n',pan_angle_sign,pan_angle_deg,tilt_angle_deg);
    case 'return_option'
        % Construct the command string and make the log entry =============
        cmd_str = sprintf('$RU\n'); % This is for auto-retract
        
%     case 'deploy_option'
% This option may or may not be unnecessary. Must talk w/ John about what
% would go into this. -- Thomas 1/7/2015
        
    otherwise % Somehow no command option was selected
        log_entry = '!!SEND COMMAND failed due to a non-implemented command option being selected!!';
        mission_log_Callback(handles,log_entry);
        cmd_str = '';
end
PassFail_flag = send_command_Callback(cmd_str,handles);
if PassFail_flag
    mission_log_Callback(handles,'Command execution: success');
else
    mission_log_Callback(handles,'Command execution: FAILURE!!!');
end
mission_log_Callback(handles,'Awaiting next user input...')

function rappel_distance_m_Callback(hObject, eventdata, handles)
% hObject    handle to rappel_distance_m (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rappel_distance_m as text
%        str2double(get(hObject,'String')) returns contents of rappel_distance_m as a double

% Get the input rappel distance in meters =================================
rappel_dist = str2double(get(hObject,'String'));
% Check if the entry was numeric
if isnan(rappel_dist)
    rappel_dist = '0.0'; % If it wasn't then just set it to zero
elseif abs(rappel_dist) > 1
    % If the input was larger than 1m then bound it
    rappel_dist = sprintf('%1.1f',rappel_dist/abs(rappel_dist));
else
    % Otherwise just round it to centimeter accuracy
    rappel_dist = sprintf('%1.2f',rappel_dist);
end

% Update the rappel distance ==============================================
set(hObject,'String',rappel_dist)

% --- Executes during object creation, after setting all properties.
function rappel_distance_m_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rappel_distance_m (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

set(hObject,'String','0.0')


function drive_distance_m_Callback(hObject, eventdata, handles)
% hObject    handle to drive_distance_m (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of drive_distance_m as text
%        str2double(get(hObject,'String')) returns contents of drive_distance_m as a double

% Get the input drive distance in meters ==================================
drive_dist = str2double(get(hObject,'String'));
% Check if the entry was numeric
if isnan(drive_dist)
    drive_dist = '0.0'; % If it wasn't then just set it to zero
elseif abs(drive_dist) > 1
    % If the input was larger than 1m then bound it
    drive_dist = sprintf('%1.1f',drive_dist/abs(drive_dist));
else
    % Otherwise just round it to centimeter accuracy
    drive_dist = sprintf('%1.2f',drive_dist);
end

% Update the drive distance ===============================================
set(hObject,'String',drive_dist)

% --- Executes during object creation, after setting all properties.
function drive_distance_m_CreateFcn(hObject, eventdata, handles)
% hObject    handle to drive_distance_m (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

set(hObject,'String','0.0')


function pan_angle_deg_Callback(hObject, eventdata, handles)
% hObject    handle to pan_angle_deg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pan_angle_deg as text
%        str2double(get(hObject,'String')) returns contents of pan_angle_deg as a double

% Get the input pan angle in degrees ======================================
pan_angle = str2double(get(hObject,'String'));
% Check if the entry was numeric or less than zero
if isnan(pan_angle) || pan_angle < 0
    pan_angle = '0'; % If it wasn't then just set it to zero
elseif pan_angle > 90
    % If the input was larger than 90 degrees then bound it
    pan_angle = '90';
else
    % Otherwise just round it to degree accuracy
    pan_angle = num2str(ceil(pan_angle));
end

% Update the drive distance ===============================================
set(hObject,'String',pan_angle)

% --- Executes during object creation, after setting all properties.
function pan_angle_deg_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pan_angle_deg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

set(hObject,'String','0')


function tilt_angle_deg_Callback(hObject, eventdata, handles)
% hObject    handle to tilt_angle_deg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tilt_angle_deg as text
%        str2double(get(hObject,'String')) returns contents of tilt_angle_deg as a double

% Get the input tilt angle in degrees =====================================
tilt_angle = str2double(get(hObject,'String'));
% Check if the entry was numeric or less than zero
if isnan(tilt_angle) || tilt_angle < 0
    tilt_angle = '0'; % If it wasn't then just set it to zero
elseif tilt_angle > 90
    % If the input was larger than 90 degrees then bound it
    tilt_angle = '90';
else
    % Otherwise just round it to degree accuracy
    tilt_angle = num2str(ceil(tilt_angle));
end

% Update the drive distance ===============================================
set(hObject,'String',tilt_angle)

% --- Executes during object creation, after setting all properties.
function tilt_angle_deg_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tilt_angle_deg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

set(hObject,'String','0')


function turn_angle_deg_Callback(hObject, eventdata, handles)
% hObject    handle to turn_angle_deg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of turn_angle_deg as text
%        str2double(get(hObject,'String')) returns contents of turn_angle_deg as a double

% Get the input turn angle in degrees =====================================
turn_angle = str2double(get(hObject,'String'));
% Check if the entry was numeric
if isnan(turn_angle)
    turn_angle = '0'; % If it wasn't then just set it to zero
elseif abs(turn_angle) > 10
    % If the input was larger than 10 degrees then bound it
    turn_angle = sprintf('%2.f',turn_angle/abs(turn_angle)*10);
else
    % Otherwise just round it to degree accuracy
    turn_angle = num2str(ceil(turn_angle));
end

% Update the drive distance ===============================================
set(hObject,'String',turn_angle)

% --- Executes during object creation, after setting all properties.
function turn_angle_deg_CreateFcn(hObject, eventdata, handles)
% hObject    handle to turn_angle_deg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

set(hObject,'String','0')
