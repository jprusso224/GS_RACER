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

% Last Modified by GUIDE v2.5 24-Mar-2015 12:06:26

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

% Add the GUI Support Functions to the path ===============================
cd  GUI' Support Functions\' %change to the gui function directory
gui_dir = pwd;      % set a variable to the gui function directory
cd ..               % change directory back to the original directory
addpath(gui_dir);   % add the gui function directory to the matlab search 
                    % path to here

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

set(handles.CANCEL_COMMAND_CHKBOX,'Value',0,'Visible','off')

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
timer_period = 30;
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

set(hObject,'Enable','off')
drawnow

global serialPort gsSerialBuffer

% Make sure the com port is still available ===============================
try
    fclose(gsSerialBuffer);
    delete(gsSerialBuffer);
end
available = checkSerialPort(serialPort);
if available
    % If it is available then we can go ahead and create a new serial
    % object for the port
    gsSerialBuffer = serial(serialPort);
    gsSerialBuffer.BaudRate = 115200;
    gsSerialBuffer.InputBufferSize = 100000; % Buffer size, in bytes
    gsSerialBuffer.Timeout = 40;
    fopen(gsSerialBuffer);
    pause(1)
end

if available % Make sure the selected com port is still available =========
set(handles.CANCEL_COMMAND_CHKBOX,'Value',0,'Visible','on')
drawnow

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
        cmd_str = sprintf('$D%c%03d\n',drive_dir,abs(drive_dist_m)*100);
    case 'turn_option'
        % Get the turning angle and determine direction ===================
        turn_ang_deg = str2double(get(handles.turn_angle_deg,'String'));
        if turn_ang_deg <= 0 % A negative turn is left/counter-clockwise
            turn_dir = 'L';
        else
            turn_dir = 'R';
        end
        % Format the command string and make the log entry ================
        cmd_str = sprintf('$D%c%03d\n',turn_dir,abs(turn_ang_deg));
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
    case 'spool_out_option'
        auto_spoolout_distance = str2double(get(handles.spool_out_distance_m,'String'));
        if auto_spoolout_distance < 0
            auto_spool_sign = '-';
        else
            auto_spool_sign = '+';
        end
        cmd_str = sprintf('$AO%c%03d\n',auto_spool_sign,abs(auto_spoolout_distance)*100);
    case 'deploy_option'
        cmd_str = sprintf('$DD\n');
    case 'transition_option'
        cmd_str = sprintf('$DT\n');
    case 'auto_rappel_option'
        cmd_str = sprintf('$RD\n');
%     case 'deploy_option'
% This option may or may not be unnecessary. Must talk w/ John about what
% would go into this. -- Thomas 1/7/2015
        
    otherwise % Somehow no command option was selected
        log_entry = '!!SEND COMMAND failed due to a non-implemented command option being selected!!';
        mission_log_Callback(handles,log_entry);
        cmd_str = '';
end

% Now send the command ====================================================
PassFail_flag = send_command_Callback(cmd_str,handles);

set(handles.CANCEL_COMMAND_CHKBOX,'Value',0,'Visible','off')
drawnow

% Make sure it was executed successfully
if PassFail_flag
    mission_log_Callback(handles,'Command execution: success');
else
    mission_log_Callback(handles,'Command execution: FAILURE!!!!!!');
end
mission_log_Callback(handles,'Awaiting next user input...')

else % IF THE COM PORT WAS NOT AVAILABLE ==================================
    mission_log_Callback(handles,'ERROR: Did not send command because COM port was unavailable...')
    com_port_list_Callback(handles.com_port_list, eventdata, handles);
end

set(hObject,'Enable','on')
drawnow

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
elseif abs(rappel_dist) > 5
    % If the input was larger than 5m then bound it
    rappel_dist = sprintf('%1.1f',5*rappel_dist/abs(rappel_dist));
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
elseif abs(turn_angle) > 300
    % If the input was larger than 90 degrees then bound it
    turn_angle = sprintf('%2.f',turn_angle/abs(turn_angle)*300);
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


% --- Executes on selection change in com_port_list.
function com_port_list_Callback(hObject, eventdata, handles)
% hObject    handle to com_port_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global gsSerialBuffer serialPort
try % Attempt to close the serial object
    % This will throw an error if the gsSerialBuffer was never successfully
    % opened.
    fclose(gsSerialBuffer);
    delete(gsSerialBuffer);
end

% Hints: contents = cellstr(get(hObject,'String')) returns com_port_list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from com_port_list
com_port_list = cellstr(get(hObject,'String'));
com_port = com_port_list{get(hObject,'Value')};
init_com_port = com_port;

% Make sure the com port is still available
available = checkSerialPort(com_port);
if available
    % If it is available then we can go ahead and create a new serial
    % object for the port
    serialPort = com_port;
    gsSerialBuffer = serial(serialPort);
    gsSerialBuffer.BaudRate = 115200;
    gsSerialBuffer.InputBufferSize = 100000; % Buffer size, in bytes
    gsSerialBuffer.Timeout = 40;
    fopen(gsSerialBuffer);
    log_entry = ['Successfully opened serial port: ' serialPort];
else % If it wasn't available then recreate the com port list
    com_port_list_CreateFcn(hObject, eventdata, handles);
    set(hObject,'Value',1)
    com_port_list = cellstr(get(hObject,'String'));
    com_port = com_port_list{get(hObject,'Value')};
    serialPort = com_port;
    % Make sure there were available ports
    if strcmp(serialPort,'ERR')
        log_entry = 'ERROR: The GUI was unable to successfully open any COM ports';
    else % If there was a valid selection, then open it!
        gsSerialBuffer = serial(serialPort);
        gsSerialBuffer.BaudRate = 115200;
        gsSerialBuffer.InputBufferSize = 100000; % Buffer size, in bytes
        gsSerialBuffer.Timeout = 40;
        fopen(gsSerialBuffer);
        log_entry = {['ERROR: Serial port: ' init_com_port ' was no longer available...'];...
            ['Successfully opened ' serialPort ' instead!']};
    end
end

% Update the mission log
mission_log_Callback(handles,log_entry);


% --- Executes during object creation, after setting all properties.
function com_port_list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to com_port_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global serialPort
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% Get a list of available COM ports and put it in the popup-menu list
ports = getAvailableComPorts(20);
set(hObject,'String',ports)
set(hObject,'Value',1)
if strcmp(ports,'ERR')
    % If something went wrong when trying to find valid serial ports or
    % none were found then just throw an error and update the mission log
    log_entry = {'ERROR: No available com ports were found!';'The GS will be unable to send and receive communications!'};
    if ~isempty(handles)
        % If this is the first time running the GUI then we can't update
        % the mission log
        mission_log_Callback(handles,log_entry);
    end
else
    % Set the serial port global variable to the first item in the list
    serialPort = ports{1};
end

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global gsSerialBuffer
% Hint: delete(hObject) closes the figure
button = 'Yes';
if evalin('base','exist(''quit_flag'')')
    if ~evalin('base','quit_flag')
        button = questdlg('Are you sure you would like to close the GS GUI?','Closing GS GUI');
    end
else
    button = 'Yes';
end
switch button
    case 'Yes'
        delete(hObject)
        
        try
        fclose(gsSerialBuffer);
        delete(gsSerialBuffer);
        end
        
        if ~isempty(timerfindall)
            stop(timerfindall)
            delete(timerfindall)
        end
        if ~isempty(instrfindall)
            delete(instrfindall)
        end
        fclose all;
    otherwise
        % If they didn't press yes then do nothing!
end


% --- Executes on button press in save_Mission_Logs_Check.
function save_Mission_Logs_Check_Callback(hObject, eventdata, handles)
% hObject    handle to save_Mission_Logs_Check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of save_Mission_Logs_Check
global saveMissionLogsCheck
saveMissionLogsCheck = get(hObject,'Value');


% --- Executes during object creation, after setting all properties.
function save_Mission_Logs_Check_CreateFcn(hObject, eventdata, handles)
% hObject    handle to save_Mission_Logs_Check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

global saveMissionLogsCheck
set(hObject,'Value',0)
saveMissionLogsCheck = 0;



% --- Executes on button press in CANCEL_COMMAND_CHKBOX.
function CANCEL_COMMAND_CHKBOX_Callback(hObject, eventdata, handles)
% hObject    handle to CANCEL_COMMAND_CHKBOX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CANCEL_COMMAND_CHKBOX
if get(hObject,'Value')
    set(hObject,'Visible','off')
end



function spool_out_distance_m_Callback(hObject, eventdata, handles)
% hObject    handle to spool_out_distance_m (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of spool_out_distance_m as text
%        str2double(get(hObject,'String')) returns contents of spool_out_distance_m as a double


% --- Executes during object creation, after setting all properties.
function spool_out_distance_m_CreateFcn(hObject, eventdata, handles)
% hObject    handle to spool_out_distance_m (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
