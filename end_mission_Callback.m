function end_mission_Callback(handles,quit_flag)
% =========================================================================
% END_MISSION_CALLBACK(quit_flag)
%    This callback shuts down the mission differently based on if the ABORT
%    button was pressed or not.
%
% Inputs:
%  handles   - The handles structure to the GS_gui_test MATLAB GUI
%  quit_flag - boolean flag for if the ABORT button was pressed or not
% =========================================================================

% Create the mission log entry based on the boolean flag ==================
if quit_flag % The ABORT button was pressed
    log_entry{1,1} =  '===============================================================================';
    log_entry{2,1} = ['==============!!!!!! MISSION ABORTED: ' datestr(now) ' !!!!!!=============='];
    log_entry{3,1} = log_entry{1,1};
else
    log_entry = ['============ Mission Terminated Successfully: ' datestr(now)...
        ' ============'];
end

mission_log_Callback(handles,log_entry)
