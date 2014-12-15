function mission_log_Callback(handles,log_entry)
% =========================================================================
% MISSION_LOG_CALLBACK(handles,log_entry)
%    This is a function that takes the GUI handles structure & a log entry
%    cell array and appends it to the mission log of the GUI. The mission
%    log entry is automatically time-stamped.
%
% Inputs:
%  handles   - The handles structure to the GS_gui_test MATLAB GUI
%  log_entry - A cell array that the user wishes to append to the mission 
%              log. This must be a column cell array {Nx1}
% Outputs:
%  NONE
% =========================================================================

% Get the current mission log cell array ==================================
str = cellstr(get(handles.Mission_Log,'String'));

% Create the time-stamp ===================================================
timestr = datestr(now);
timestr = timestr(end-7:end);

% Check if the current mission log has any entries ========================
if size(str,1) > 0
    % If so, then add the new entries at the end
    if size(log_entry,1) == 1 % This is for a single log entry
        str{end+1,1} = [timestr ' - ' log_entry];
    elseif size(log_entry,1) > 1
        % This is if the cell array is multiple lines
        for ii = 1:size(log_entry,1)
            str{end+1,1} = [timestr ' - ' log_entry{ii,1}];
        end
    end
else
    % If the mission log is currently empty then just create a new log
    str = [timestr ' - ' log_entry];
end

% Update the mission log with the new cell array ==========================
set(handles.Mission_Log,'String',str);
% Set the list box to be focused at the bottom
set(handles.Mission_Log,'ListboxTop',size(str,1));
drawnow