close all
clear
delete(timerfindall) % Delete all timer objects (hidden and not)
delete(instrfindall) % Delete all serial objects (hidden and not)
quit_flag = 0; % Initialize the quit_flag to 0
serial_flag = 0; % Used to verify that serial port was found

global gsSerialBuffer serialPort

%% Start the GUI! =========================================================
% 'handles' is a structure with all of the gui handles
%
% 'timerobj' is a timer object created to run its timer function every 5
% seconds. Its timer function simply updates the mission log with the
% current time. This could be changed to something like requesting a status
% and then updating the appropriate GUI fields.

[handles,timerobj] = GS_gui();

%% Initialize serial communications =======================================
% The serialPort global variable is set during the creation of the GUI
try 
    % If there were no serial ports available at startup then initializing
    % the serial port will not work.
    gsSerialBuffer = serial(serialPort);
    gsSerialBuffer.BaudRate = 115200;
    gsSerialBuffer.InputBufferSize = 100000; % Buffer size, in bytes
    gsSerialBuffer.Timeout = 40;
    fopen(gsSerialBuffer);
catch err
    disp(err.message)
    log_entry = 'ERROR: No valid serial ports were found at startup so the mission will be aborted...';
    waitfor(errordlg(log_entry))
    mission_log_Callback(handles,log_entry)
    quit_flag = 1;
    serial_flag = 1;
end
    

%% Start the timer object =================================================
start(timerobj) % This is a "heartbeat" timer that asks for the CR/MR status

%% Begin the "constant loop" ==============================================
tic
while 1
    
    drawnow
    if toc > 1000 || quit_flag == 1
        
        end_mission_Callback(handles,quit_flag)
        break
    end
  
end

% On cleanup, the serial object must both be closed and deleted to avoid
% clutter
if ~serial_flag
    fclose(gsSerialBuffer);
    delete(gsSerialBuffer);
end
stop(timerobj)
delete(timerfindall)
% close(handles.figure1)