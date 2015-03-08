function request_status_Callback(handles)
% =========================================================================
% REQUEST_STATUS_CALLBACK(handles)
%     This function is the callback to a timer object running in the
%     background of the constant_loop that runs the GS_gui. It executes
%     every time the timer object fires and sends a status request to the
%     MR and CR then captures and records their results.
%
% Inputs:
%   handles - The handles structure to the GS_gui_test MATLAB GUI
% Outputs:
%   NONE
%
% UPDATE LOG ==============================================================
% Creation: ~12/5/2014 by Thomas Green
% Update 1: 1/7/2015 by Thomas Green
%    - Added some commenting as well as functionality to display the
%    information to the user. Further work must be done to actually send
%    the status request to the MR/CR and capture the response. More work
%    must also be done to parse the received string.
% Update 2: 1/12/2014 by Thomas Green
%    - Added parsing of the response strings to get battery, depth, and
%    distance travelled information. It should be noted that these
%    calculations assume a max battery voltage of 15V for both MR and CR
%    and a linear decay of voltage proportional to capacity is used.
% =========================================================================

% Clear the global status strings =========================================
global CR_status MR_status
CR_status = cell(2,1);
MR_status = cell(1,1);

% Create the request status command string ================================
cmd_str = sprintf('$SR\n');

try
% Send the request to the MR and CR =======================================
PassFail_flag = send_command_Callback(cmd_str,handles);

if PassFail_flag % Make sure it was a success
    
% Process the response ====================================================
CR_batt_mV  = str2double(CR_status{1,1}(5:10));
CR_depth_cm = str2double(CR_status{2,1}(5: 7));
CR_dist_cm  = str2double(CR_status{2,1}(8:11));
MR_batt_mV  = str2double(MR_status{1,1}(5:10));

% Update the GUI text =====================================================
CR_batt_text = sprintf('CR Battery: %d%%',round(CR_batt_mV/15000*100));
CR_depth_text = sprintf('Depth: %.2f m',CR_depth_cm/100);
CR_dist_text = sprintf('Distance Travelled: %.2f m',CR_dist_cm/100);
MR_batt_text = sprintf('MR Battery: %d%%',round(MR_batt_mV/15000*100));
set(handles.CR_batt_text,'String',CR_batt_text);
set(handles.CR_depth_text,'String',CR_depth_text);
set(handles.CR_dist_text,'String',CR_dist_text);
set(handles.MR_batt_text,'String',MR_batt_text);

% Create the log entry ====================================================
log_entry = {'Received CR & MR Statuses:';MR_batt_text;CR_batt_text;...
    CR_depth_text;CR_dist_text;'NOTE: THESE WERE SIMULATED STATUSES!'};
mission_log_Callback(handles,log_entry)
end

catch err
    disp(err.message)
end

