function [passFailFlag] = waitForAcknowledgement(commandType,commandMod,handles)
% =========================================================================
% [passFailFlag] = waitForAcknowledgement(commandType,commandMod,handles)
%     This function should be called after a command is sent to the serial
%     port and poles the serial port for an acknowledgement from the MR.
%     Returns 1 when acknowledgement is received. Also has the capability
%     to return the CR and MR status strings for further processing within
%     the 'request_status_Callback(' function.
%
% Inputs: 
%   commandType - Character that was sent as the command identifier.
%   commandMod  - Character that was sent as the command modifier (e.g. 'L'
%                 for a '$DL010' left turn command.
%   handles     - structure of the GS_GUI handles.
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
% Update 3: 2/22/2015 by Thomas Green
%    - There have been miscellaneous updates over the past couple weeks but
%    the major change is to have individual timeouts for each different
%    command type. Also adding functionality to the rappelling command to
%    detect if a rappelling failure was reported.
% Update 4: 3/10/2015 - 3/25/2015 by Thomas Green
%    - Added data saving for both rappelling and driving. Also added extra
%    inputs to the function so that we don't save data for return and
%    turning commands. 
%    - Added a "cancel" button to the GS_GUI so that if a command was sent
%    but the operator does not with to wait for a timeout or
%    acknowledgement they can just stop the while loop and the command will
%    be marked as a fail.
% Update 5: 3/24/2015 by John Russo
%   - Added Auto spool out command for testing. 
% Update 6: 3/30/2015 by John Russo
%   - Can now receive deploy acknowledgments.
% =========================================================================
global gsSerialBuffer CR_status MR_status % globally shared serial port to XBee/MR
% globally shared status strings
CR_status = cell(2,1);
MR_status = cell(1,1);

% Other variables =========================================================
passFailFlag = 0;
fullPicString = '';
tic
time_elapsed = toc;

% Determine the proper timeout duration ===================================
switch commandType
    case 'A'
        timeout_dur = 100;  %seconds
    case 'I'  
        timeout_dur = 300;   % seconds
    case 'R'
        timeout_dur = 200;  % seconds
        % Set up the data save file
        date_str = datestr(now);
        date_str(date_str == ':') = '_';
        fname_str = ['Rappelling Testing\rappelData ' date_str '.txt'];
        rappelDataFID = fopen(fname_str,'w+');
    case 'S'
        timeout_dur = 10;   % seconds
    case 'D'
        timeout_dur = 100;   % seconds
        % Set up the data save file
        if ~strcmp(commandMod,'L') && ~strcmp(commandMod,'R')
        date_str = datestr(now);
        date_str(date_str == ':') = '_';
        fname_str = ['Driving Testing\driveData ' date_str '.txt'];
        driveDataFID = fopen(fname_str,'w+');
        end
    otherwise
        timeout_dur = 30;   % seconds
end

% NOTE: THE STOP_FLAG DOES NOT CANCEL THE COMMAND ON THE CR, IT SIMPLY
% CANCELS THE TIMEOUT SO THE OPERATOR DOES NOT HAVE TO CLOSE THE GUI IF
% AN ERROR WAS ENCOUNTERED
stop_flag = get(handles.CANCEL_COMMAND_CHKBOX,'Value');
while ~passFailFlag && time_elapsed < timeout_dur && ~stop_flag
    
    % wait for serial data ================================================
    if gsSerialBuffer.BytesAvailable > 0
        switch commandType
            case 'A' % AUTO SPOOLOUT
                response = fscanf(gsSerialBuffer,'%s'); % Get the response string
                disp(response)
                if ~isempty(strfind(response,'$AP'))
                    passFailFlag = 1;
                end
            case 'D' % DRIVING COMMAND & DEPLOY
                response = fscanf(gsSerialBuffer,'%s'); % Get the response string
                fprintf('%.2f s: %s\n',time_elapsed,response);
                
                if ~strcmp(commandMod,'L') && ~strcmp(commandMod,'R') && ~strcmp(commandMod,'D')
                    fprintf(driveDataFID,'%.2f \t %s\n',time_elapsed,response);
                end
                
                % Make sure we got back the appropriate response
                if ~isempty(strfind(response,'$DP'))
                    passFailFlag = 1;
                % Check for deploy response
                elseif ~isempty(strfind(response,'$DDP'))
                    passFailFlag = 1;
                elseif ~isempty(strfind(response,'$DTP'))
                    passFailFlag = 1;
                end
                
            case 'I' % IMAGING COMMAND
                % If we have an image command then we need to collect the
                % image as a response and write it to the 'picString.txt'
                % file. We need to keep collecting the string until we get
                % to the 'ENDOFFILE' delimiter at the end of the
                % transmitted message.
                response = char(fread(gsSerialBuffer,gsSerialBuffer.BytesAvailable,'char')'); % Get the response string
%                 disp(['Got imaging response: ' response])
                
                % Concatenate the response onto the full string
                fullPicString = [fullPicString response];
                
                % Check to see if we've received the EOF delimeter. It
                % should be noted that when using 'fscanf(' it is not
                % possible to detect a newline character as a delimeter
                if length(fullPicString) > 10
                    if strcmp(fullPicString(end-9:end-1),'ENDOFFILE')
                        passFailFlag = 1;
                    end
                end
            case 'R' % RAPPELLING COMMAND
                
                response = fscanf(gsSerialBuffer,'%s'); % Get the response string
                fprintf('%.2f s: %s\n',time_elapsed,response);
                
                fprintf(rappelDataFID,'%.2f \t %s\n',time_elapsed,response);
                
                % See if we got the 'Pass' response
                if ~isempty(strfind(response,'$R0P'))
                    passFailFlag = 1;
                elseif ~isempty(strfind(response,'$R0F')) % A 'Failure' response
                    passFailFlag = 0;
                    break
                else
%                     disp(response)
                end
                
            case 'S' % STATUS REQUEST
                % For now this functionality is not yet implemented on the
                % MR or CR so just output simulated responses -- 1/19/15
                response = char(fread(gsSerialBuffer,gsSerialBuffer.BytesAvailable,'char')');
                if strcmp(response,sprintf('$SP\n'))
                    CR_status{1,1} = sprintf('$SCB014795\n'); % CR Battery in mV
                    CR_status{2,1} = sprintf('$SCP3620021\n'); % CR Depth and Distance in cm
                    MR_status{1,1} = sprintf('$SMB014622\n'); % MR Battery in mV
                    passFailFlag = 1;
                else
                    passFailFlag = 0;
                end
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
    drawnow();
    stop_flag = get(handles.CANCEL_COMMAND_CHKBOX,'Value');
    % NOTE: THE STOP_FLAG DOES NOT CANCEL THE COMMAND ON THE CR, IT SIMPLY
    % CANCELS THE TIMEOUT SO THE OPERATOR DOES NOT HAVE TO CLOSE THE GUI IF
    % AN ERROR WAS ENCOUNTERED
    
end % end of while ~passFailFlag

if stop_flag % if the user pressed cancel, force the passFailFlag to be 0
    passFailFlag = 0;
end

% Write the fullPicString to the picString.txt file =======================
if commandType == 'I' && passFailFlag == 1
for ii = 1:10
    if strcmp(fullPicString(ii),'I') && strcmp(fullPicString(ii-1),'$')
        break
    end
end
startInd = ii + 1;
numChars = 0;
for ii = length(fullPicString)-12:-1:length(fullPicString)-50
    if strcmp(fullPicString(ii:ii+12),'NUMCHARACTERS')
        for jj = (ii+13):ii+30
            if strcmp(fullPicString(jj),'E')
                numChars = str2double(fullPicString(ii+13:jj-1));
                break
            end
        end
        break
    end
end
% endInd = startInd+numChars-1;
endInd = ii - 1;
fprintf('Got %d out of expected %d characters\n',endInd-startInd+1,numChars);
if strcmp(fullPicString(endInd+1:endInd+3),'NUM') && (endInd-startInd+1) == numChars
    picStringFile = fopen('ImageFiles\picString.txt','w+');
    fprintf(picStringFile,fullPicString(startInd:endInd)); % Don't include the '$I' at
    fclose(picStringFile);                                 % the beginning or the
else                                                       % 'ENDOFFILE' at the end
    passFailFlag = 1;
    str = sprintf('ERROR: Failed to receive expected number of characters! Got %d out of expected %d',endInd-startInd,numChars);
    waitfor(errordlg(str,'Error in image string received!'));
end

end % end of if commandType == 'I'

if commandType == 'R'
    fclose(rappelDataFID);
elseif commandType == 'D' && ~strcmp(commandMod,'L') && ~strcmp(commandMod,'R')
    fclose(driveDataFID);
end

