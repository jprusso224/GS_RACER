close all
clear
delete(timerfindall) % Delete all timer objects (hidden and not)
delete(instrfindall) % Delete all serial objects (hidden and not)
quit_flag = 0; % Initialize the quit_flag to 0

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
    fopen(gsSerialBuffer);
catch err
    disp(err.message)
    log_entry = 'ERROR: No valid serial ports were found at startup so the mission will be aborted...';
    waitfor(errordlg(log_entry))
    mission_log_Callback(handles,log_entry)
    quit_flag = 1;
end
    

%% Plot a placeholder image and start the timer object ====================
h = handles.image_axes;
I = imread('cave_pic.jpg');
axes(h) % Force the GUI axes to be selected
imshow(I)
drawnow

start(timerobj) % This is a "heartbeat" timer that asks for the CR/MR status

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
fclose(gsSerialBuffer);
delete(gsSerialBuffer);

stop(timerobj)
delete(timerfindall)
% close(handles.figure1)