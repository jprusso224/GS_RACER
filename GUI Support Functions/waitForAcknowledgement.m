function [passFailFlag] = waitForAcknowledgement(commandType)
% =========================================================================
% [passFailFlag] = waitForAcknowledgement(commandType)
%     This function should be called after a command is sent to the serial
%     port and poles the serial port for an acknowledgement from the MR.
%     Returns 1 when acknowledgement is received. Also has the capability
%     to return the CR and MR status strings for further processing within
%     the 'request_status_Callback(' function.
%
% Inputs: 
%   commandType - Character that was sent as the command identifier.
%
% Outputs:
%   passFailFlag - This is a boolean flag stating whether the command was
%                   successfully executed. (Acknowledgement received)
%
% UPDATE LOG ==============================================================
% Creation: 1/9/2015 by John Russo
% Update 1: 1/12/2015 by Thomas Green
%    - Added a case statement for different processing if it's a status
%    request. This will also need to be done for an image.
% Update 2: 1/19/2015 by Thomas Green
%    - Added support for receiving images through the serial port! Further
%    work will include adding support for comm dropouts as well as all
%    command types.
% =========================================================================
global gsSerialBuffer CR_status MR_status % globally shared serial port to XBee/MR
% globally shared status strings
passFailFlag = 0;
CR_status = cell(2,1);
MR_status = cell(1,1);
fullPicString = '';
tic
time_elapsed = toc;

% Determine the proper timeout duration ===================================
switch commandType
    case 'I'
        timeout_dur = 60;   % seconds
    case 'R'
        timeout_dur = 2000; % seconds
    case 'S'
        timeout_dur = 10;   % seconds
    case 'D'
        timeout_dur = 30;   % seconds
    otherwise
        timeout_dur = 30;   % seconds
end
        
while ~passFailFlag && time_elapsed < timeout_dur
    
    % wait for serial data ================================================
    if gsSerialBuffer.BytesAvailable > 0
        switch commandType
            case 'D' % DRIVING COMMAND
                response = fscanf(gsSerialBuffer,'%s'); % Get the response string
                fprintf('%.2f s: %s\n',time_elapsed,response)
                
                % Make sure we got back the appropriate response
                if length(response) >= 3 && strcmp(response(end-2:end),'$DP')
                    passFailFlag = 1;
                end
                
            case 'I' % IMAGING COMMAND
                % If we have an image command then we need to collect the
                % image as a response and write it to the 'picString.txt'
                % file. We need to keep collecting the string until we get
                % to the 'ENDOFFILE' delimiter at the end of the
                % transmitted message.
                response = fscanf(gsSerialBuffer,'%s'); % Get the response string
                
                % Concatenate the response onto the full string
                fullPicString = [fullPicString response];
                
                % Check to see if we've received the EOF delimeter. It
                % should be noted that when using 'fscanf(' it is not
                % possible to detect a newline character as a delimeter
                if length(fullPicString) > 10
                    if strcmp(fullPicString(end-8:end),'ENDOFFILE')
                        passFailFlag = 1;
                    end
                end
            case 'R' % RAPPELLING COMMAND
                
                response = fscanf(gsSerialBuffer,'%s'); % Get the response string
                fprintf('%.2f s: %s\n',time_elapsed,response)
                
                % See if we got the 'Pass' response
                if ~isempty(response) && response(1) == '$' && response(2) == commandType && response(3) == 'P'
                    passFailFlag = 1;
                end
                if strcmp(response,'Yadonegoofed$RP')
                    passFailFlag = 1;
                end
                
            case 'S' % STATUS REQUEST
                % For now this functionality is not yet implemented on the
                % MR or CR so just output simulated responses -- 1/19/15
                CR_status{1,1} = sprintf('$SCB014795\n'); % CR Battery in mV
                CR_status{2,1} = sprintf('$SCP3620021\n'); % CR Depth and Distance in cm
                MR_status{1,1} = sprintf('$SMB014622\n'); % MR Battery in mV
                passFailFlag = 1;
            otherwise
                pause(0.25); % allow buffer to fill(should be more than enough)
                response = fscanf(gsSerialBuffer,'%s'); % Get the response string
                % Make sure we got back the appropriate response
                if response(1) == '$' && response(2) == commandType && response(3) == 'P'
                    passFailFlag = 1;
                end
        end % end of switch commandType
    end % end of checking if bytes are available on serial object
    
    time_elapsed = toc; % For timeout purposes
    
end % end of while ~passFailFlag

% Write the fullPicString to the picString.txt file =======================
if commandType == 'I' && passFailFlag == 1
picStringFile = fopen('ImageFiles\picString.txt','w+');
fprintf(picStringFile,fullPicString(3:end-9)); % Don't include the '$I' at 
fclose(picStringFile);                         % the beginning or the 
end                                            % 'ENDOFFILE' at the end

end % end of function

