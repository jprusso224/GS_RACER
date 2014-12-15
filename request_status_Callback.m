function request_status_Callback(handles)

% Create the request status command string ================================
command_str = sprintf('$SR\n');

% Pretend to send and receive the statuses ================================
pause(1) % <-- this is probably an overestimate, yes?
CR_status{1,1} = sprintf('$SCB014795\n'); % CR Battery in mV
CR_status{2,1} = sprintf('$SCP362021\n'); % CR Depth and Distance in cm
MR_status{1,1} = sprintf('$SMB014622\n'); % MR Battery in mV

% Create the log entry ====================================================
log_entry = {'Received CR & MR Statuses:';CR_status{1,1};CR_status{2,1};...
    MR_status{1,1}};
mission_log_Callback(handles,log_entry)

