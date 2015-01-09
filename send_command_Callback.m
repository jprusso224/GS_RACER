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
%
% UPDATE LOG ==============================================================
% Creation: ~12/5/2014 by Thomas Green
% Update 1: 1/7/2015 by Thomas Green
%    - Added some commenting, removed some obsolete command cases, and made
%    sure every current command case is handled. Also added some
%    error-handling for malformed input.
% Update 2: 1/8/15 by John Russo
%    - This function now sends the command string to the serial port which
%    has been declared a global variable and is shared with the main loop.
% Update 3: 1/9/15 by John Russo
%    - the waitForAcknowledgement function is called after every command
%    sent and the pass/fail flag is set based on the result of the function
%    call.
%
% =========================================================================
PassFail_flag = 0;
global gsSerialBuffer

% % See if we have multiple timer objects going =============================
% if length(timerfindall) > 1
%     log_entry = {'!!!!!!ERROR!!!!!! Multiple timer objects were detected when a command was going to be sent.';...
%         'To avoid complications that could be caused by stopping these objects the GUI will now abort.'};
%     mission_log_Callback(handles,log_entry)
%     evalin('base','quit_flag=1');
%     return
% end
% % Otherwise, stop them until the command is processed
stop(timerfind('Tag','heartbeat_timer'))

% Send the command via the serial port ====================================
if length(cmd_str) > 3 % The command string must be at least 3 characters
switch cmd_str(2) % Check what type of command string it is
    case 'I' % Imaging command ============================================
        log_entry{1,1} = ['Sent CAPTURE IMAGE command: ' cmd_str];
        log_entry{2,1} = 'Awaiting reply...';
        mission_log_Callback(handles,log_entry)
       % pause(30) % Send the capture image command
    %    fopen(gsSerialBuffer);
        fprintf(gsSerialBuffer,cmd_str);
     %   fclose(gsSerialBuffer);
        axes(handles.image_axes)
        imshow('cave_pic.jpg')
        text(10,10,datestr(now),'Color','w','FontName','Courier New')
        PassFail_flag = waitForAcknowledgement(cmd_str(2));
        
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
        % Send the rappel command
        fprintf(gsSerialBuffer,cmd_str);
        PassFail_flag = waitForAcknowledgement(cmd_str(2));
        
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
        % Send the driving command
        fprintf(gsSerialBuffer,cmd_str);
        PassFail_flag = waitForAcknowledgement(cmd_str(2));
        
    case 'S' % Status update request ======================================
        if strcmp(cmd_str,sprintf('$SR\n'))
            log_entry = ['Sent STATUS REQUEST: ' cmd_str];
            % Send the status request
            fprintf(gsSerialBuffer,cmd_str);
            PassFail_flag =  waitForAcknowledgement(cmd_str(2));
        else
            log_entry = ['Unknown STATUS REQUEST string: ' cmd_str];
        end
        mission_log_Callback(handles,log_entry)
        
    otherwise % If we don't know what this is then do nothing =============
        log_entry = ['Unknown command string: ' cmd_str];
        mission_log_Callback(handles,log_entry)
        
end
start(timerfind('Tag','heartbeat_timer')) % Restart the timer object
end