function PassFail_flag = send_command_Callback(cmd_str,handles)
% =========================================================================
% [PassFail_flag] = SEND_COMMAND_CALLBACK(cmd_str)
%     This function takes a command string that was formatted within the
%     GS_gui_test MATLAB GUI and simulates sending the command and
%     receiving a response.
%
% Inputs:
%   cmd_str - This is a properly formatted command string with a start
%             delimiter of '$' and an end delimiter of '\n'.
%   handles - The handles structure to the GS_gui_test MATLAB GUI
% Outputs:
%   PassFail_flag - This is a boolean flag stating whether the command was
%                   successfully executed.
% =========================================================================
PassFail_flag = 0;
if length(cmd_str) > 3 % The command string must be at least 3 characters
switch cmd_str(2) % Check what type of command string it is
    case 'I' % Imaging command ============================================
        log_entry{1,1} = ['Sent CAPTURE IMAGE command: ' cmd_str];
        log_entry{2,1} = 'Awaiting reply...';
        mission_log_Callback(handles,log_entry)
        pause(30);
        axes(handles.image_axes)
        imshow('cave_pic.jpg')
        text(10,10,datestr(now),'Color','w','FontName','Courier New')
        
    case 'R' % Rappelling command =========================================
        switch cmd_str(3) % Check what type of rappelling we're doing
            case '0' % Manual rappel
                log_entry = ['Sent MANUAL RAPPEL command: ' cmd_str];
                dur = abs(str2double(cmd_str(4:7)))/10;
            case 'D' % Rappel Auto
                log_entry = ['Sent AUTO RAPPEL command: ' cmd_str];
                dur = 500/10;
            case 'U' % Retract Auto
                log_entry = ['Sent AUTO RETRACT command: ' cmd_str];
                dur = 500/10;
        end
        mission_log_Callback(handles,log_entry)
        pause(dur)
        PassFail_flag = 1;
        
    case 'D' % Driving command ============================================
        switch cmd_str(3) % Check what type of driving we're doing
            case 'F' % Forward driving
                log_entry = ['Sent FORWARD DRIVE command: ' cmd_str];
            case 'B' % Backward driving
                log_entry = ['Sent REVERSE DRIVE command: ' cmd_str];
            case 'L' % Left-hand turn
                log_entry = ['Sent LEFT TURN command: ' cmd_str];
            case 'R' % Right-hand turn
                log_entry = ['Sent RIGHT TURN command: ' cmd_str];
        end
        dur = abs(str2double(cmd_str(4:7)))/0.1;
        mission_log_Callback(handles,log_entry)
        pause(dur)
        PassFail_flag = 1;
        
    case 'S' % Status update request ======================================
        
end
end