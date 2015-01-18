function [available] = checkSerialPort(port)
% =========================================================================
% [available] = CHECKSERIALPORT(port)
%     This function attempts to open a serial port object to determine if
%     the port is available to be used. The function returns a boolean flag
%     based on if the serial port is available.
%
% Inputs: 
%   port      - String for the COM port that is being polled (e.g. 'COM2')
%
% Outputs:
%   available - This is a boolean flag stating whether the port is
%               available to be written/read from.
% 
% NOTE: This function is written based on code developped by Paul Guerrie
% for ASEN 2004 while working for Trudy Schwartz at the University of
% Colorado, Boulder. It has been adapted for usage by Team RACER.
%
% UPDATE LOG ==============================================================
% Creation: 1/14/2015 by Thomas Green
% =========================================================================

% Initialize the port =====================================================
available = 1;    % Assume it is available
s = serial(port); % Create serial port object for specified port

% Attempt to open communications ==========================================
try
    fopen(s); % Try to open serial port object for communications
catch
    available = 0; % If there was an error we know it is unavailable
end

% Perform some cleanup ====================================================
fclose(s); % Close object
delete(s); % delete object
