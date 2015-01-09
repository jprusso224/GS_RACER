function [passFailFlag] = waitForAcknowledgement(commandType)
% =========================================================================
% [passFailFlag] = waitForAcknowledgement(commandType)
%     This function should be called after a command is sent to the serial
%     port and poles the serial port for an acknowledgement from the MR.
%     Returns 1 when acknowledgement is received.
%
% Inputs: 
%   commandType - Character that was sent as the command identifier.
%
% Outputs:
%   passFailFlag - This is a boolean flag stating whether the command was
%                   successfully executed. (Acknowledgement received)
%
% UPDATE LOG ==============================================================
% Creation: 1/9/2014 by John Russo
% =========================================================================
global gsSerialBuffer % globally shared serial port to XBee/MR
passFailFlag = 0;
while ~passFailFlag
    
    % wait for serial data
    if gsSerialBuffer.BytesAvailable > 0
        pause(0.25); % allow buffer to fill(should be more than enough)
        input = fscanf(gsSerialBuffer,'%s');
        if input(1) == '$' && input(2) == commandType && input(3) == 'P'
            passFailFlag = 1;
        end
    end
    
end


end

