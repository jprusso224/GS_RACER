function PassFail_flag = send_command_Callback(cmd_str,handles)
% =========================================================================
% [PassFail_flag] = SEND_COMMAND_CALLBACK(cmd_str)
%     This function takes a command string that was formatted within the
%     GS_gui_test MATLAB GUI and sends the command through the serial port
%     then waits for an acknowledgement to determine if the command was
%     successfully executed.
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
% Update 4: 1/12/15 by Thomas Green
%    - Removed some erroneous lines from before the proper usage of
%    'timerfind(' was implemented
% Update 5: 1/17/15 by Thomas Green
%    - Added logic to run the python script to decode a picture string that
%    was received over the serial port. Functionality still must be added
%    to the 'waitForAcknowledgement(' function to actually receive images
%    over this wireless link.
% Update 6: 1/19/2015 by Thomas Green
%    - Added more calls to 'mission_log_Callback(' so that more information
%    is displayed to the user when imaging commands are sent. This must
%    also be done with other command types but that will come when those
%    commands actually do things other than blink LEDs on the Arduinos
% =========================================================================
PassFail_flag = 0;
global gsSerialBuffer

% Stop the heartbeat timer for the duration of the command ================
stop(timerfind('Tag','heartbeat_timer'))

% Clear the serial buffer =================================================
if gsSerialBuffer.BytesAvailable > 0
    cleared_data = fread(gsSerialBuffer,gsSerialBuffer.BytesAvailable);
end


% Send the command via the serial port ====================================
if length(cmd_str) > 3 % The command string must be at least 3 characters
switch cmd_str(2) % Check what type of command string it is
    case 'I' % Imaging command ============================================
        log_entry{1,1} = ['Sent CAPTURE IMAGE command: ' cmd_str];
        log_entry{2,1} = 'Awaiting reply...';
        mission_log_Callback(handles,log_entry)
        fprintf(gsSerialBuffer,cmd_str);
        
        PassFail_flag = waitForAcknowledgement(cmd_str(2));
        if PassFail_flag % if we were successful we must decode the image
            
            % Start creating the log_entry array
            log_entry{1,1} = 'Successfully received ''ENDOFFILE'' delimeter...';
            
            % Get the current time and format it into the desired image
            % filename
            curr_time = datestr(now);
            curr_time(curr_time == ' ' | curr_time == ':') = '';
            image_FileName = ['image' curr_time];
            curr_path = pwd; % Identify current folder
            image_Path = [curr_path '\ImageFiles\'];
            
            % Tell user what the file will be called
            log_entry{2,1} = ['Decoding text to file: ' image_FileName '.jpg ...'];
            
            % Run the python script to decode the picture
            command_Str = ['python "' curr_path ... 
                '\ImageFiles\picDecode.py" ' image_FileName];
            [status, commandOut] = system(command_Str);
            disp(commandOut)
            
            if status ~= 0 % If the decoding didn't work, let the user know
                cla(handles.image_axes) % Clear the axes
                error_str = ['Encountered an error while attempting to decode '...
                    'the image file in picString.txt. Error text from python: '...
                    commandOut];
                waitfor(errordlg(error_str))
                PassFail_flag = 0; % Make sure it doesn't pass
                log_entry{3,1} = 'Failed to decode the text into an image!!';
            else
                % Display the image to the user
                I = imread([image_Path image_FileName '.jpg']);
                I = imrotate(I,180);
                axes(handles.image_axes)
                imshow(I)
                title(image_FileName,'FontName','Courier New','FontSize',10)
                drawnow
                log_entry{3,1} = 'Successfully displayed the image to the GUI';
            end
            
        else
            log_entry = 'Acknowledgement loop timed out after never receiving ''ENDOFFILE'' delimeter!!';
        end % End of if PassFail_flag for imaging command
        
        % Update the user on what happened
        mission_log_Callback(handles,log_entry)
            
        
    case 'R' % Rappelling command =========================================
        switch cmd_str(3) % Check what type of rappelling we're doing
            case '0' % Manual rappel
                log_entry = ['Sent MANUAL RAPPEL command: ' cmd_str];
            case 'D' % Rappel Auto
                log_entry = ['Sent AUTO RAPPEL command: ' cmd_str];
            case 'U' % Retract Auto
                log_entry = ['Sent AUTO RETRACT command: ' cmd_str];
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
temp = timerfind('Tag','heartbeat_timer');
if ~strcmp(temp.Running,'on')
    start(timerfind('Tag','heartbeat_timer')) % Restart the timer object
end
end