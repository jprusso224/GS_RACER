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
% =========================================================================
global gsSerialBuffer CR_status MR_status % globally shared serial port to XBee/MR
% globally shared status strings
passFailFlag = 0;
CR_status = cell(2,1);
MR_status = cell(1,1);
fullPicString = '';
tic
time_elapsed = toc;
while ~passFailFlag && time_elapsed < 40
    
    % wait for serial data ================================================
    if gsSerialBuffer.BytesAvailable > 0
        % This pause statement should vary based on the sent command. For
        % example, the image will not fill the buffer in a quarter of a
        % second. -- Thomas 1/12/2015
        switch commandType
            case 'I'
                % If we have an image command then we need to collect the
                % image as a response and write it to the 'picString.txt'
                % file. For now, we will just replicate what is done in the
                % "otherwise" case as that is what is done in current
                % functionality on the Arduino.
                response = fscanf(gsSerialBuffer,'%s'); % Get the response string
                fullPicString = [fullPicString response];
                
                if fullPicString(end-8:end) == 'ENDOFFILE';
                    passFailFlag = 1;
                end
            case 'S'
                CR_status{1,1} = sprintf('$SCB014795\n'); % CR Battery in mV
                CR_status{2,1} = sprintf('$SCP362021\n'); % CR Depth and Distance in cm
                MR_status{1,1} = sprintf('$SMB014622\n'); % MR Battery in mV
                passFailFlag = 1;
            otherwise
                pause(0.25); % allow buffer to fill(should be more than enough)
                response = fscanf(gsSerialBuffer,'%s'); % Get the response string
                if response(1) == '$' && response(2) == commandType && response(3) == 'P'
                    passFailFlag = 1;
                end
        end % end of switch commandType
    end % end of checking if bytes are available on serial object
    
    time_elapsed = toc;
    
end % end of while ~passFailFlag

% Write the fullPicString to the picString.txt file =======================
if commandType == 'I'
temp = fopen('ImageFiles\picString.txt','w+');
fprintf(temp,fullPicString(3:end-9)); % Don't include the '$I' at the beginning
fclose(temp);                         % or the 'Fin' at the end
end

end % end of function

