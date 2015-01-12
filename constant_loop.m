close all
clear
delete(timerfindall)

global gsSerialBuffer

%% Start the GUI! =========================================================
% 'handles' is a structure with all of the gui handles
%
% 'timerobj' is a timer object created to run its timer function every 5
% seconds. Its timer function simply updates the mission log with the
% current time. This could be changed to something like requesting a status
% and then updating the appropriate GUI fields.

serialPort = 'COM5';
gsSerialBuffer = serial(serialPort);
fopen(gsSerialBuffer);
[handles,timerobj] = GS_gui();
quit_flag = 0;

%% Plot the first dot and then start the timer function
h = handles.image_axes;
I = imread('cave_pic.jpg');
axes(h) % Force the GUI axes to be selected
imshow(I)
drawnow
start(timerobj)

tic
while 1
    
    drawnow
    if toc > 1000 || quit_flag == 1
        
        end_mission_Callback(handles,quit_flag)
        break
    end
  
end

fclose(gsSerialBuffer);

stop(timerobj)
delete(timerfindall)
% close(handles.figure1)