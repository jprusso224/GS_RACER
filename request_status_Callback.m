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
% =========================================================================

% Create the request status command string ================================
cmd_str = sprintf('$SR\n');

% Pretend to send and receive the statuses ================================
% THIS IS WHERE WE SEND THE cmd_str VIA THE SERIAL PORT
PassFail_flag = send_command_Callback(cmd_str,handles);
if PassFail_flag % Make sure it was a success
CR_status{1,1} = sprintf('$SCB014795\n'); % CR Battery in mV
CR_status{2,1} = sprintf('$SCP362021\n'); % CR Depth and Distance in cm
MR_status{1,1} = sprintf('$SMB014622\n'); % MR Battery in mV

% Create the log entry ====================================================
log_entry = {'Received CR & MR Statuses:';CR_status{1,1};CR_status{2,1};...
    MR_status{1,1};'NOTE: THESE WERE SIMULATED STATUSES!'};
mission_log_Callback(handles,log_entry)
end

