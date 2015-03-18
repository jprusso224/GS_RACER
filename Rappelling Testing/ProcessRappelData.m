%% ProcessRappelData.m
% =========================================================================
% PURPOSE:
%    This file has the user select a rappelling data file to generate depth
%    vs. time as well as descent rate vs. time plots. This analysis assumes
%    that there is a 20cm offset applied to the depth readings that we get
%    back so for the first 20 cm we are reading zeroes even though it is
%    going from 0 to 20 in that time. 
% =========================================================================
clear; close all;

%%
datafile = uigetfile('*.txt','Select A Rappelling Data File');

dataFID = fopen(datafile);
% data = [];

data = fscanf(dataFID,'%f',[2,inf])';
fclose all;

prompt={'Please enter the total rappel distance commanded for this test in cm:'};
name='Enter Total Rappel Distance';
numlines=1;
defaultanswer={'0'};

answer=inputdlg(prompt,name,numlines,defaultanswer);
final_depth = str2double(answer);

if data(end,2) == 0
    data(end,2) = final_depth-20;
elseif data(end,2) ~= final_depth - 20
    waitfor(errordlg('ERROR: The data file does not seem to end at the proper depth. Forcing the final data point to the final depth'));
    data(end,2) = final_depth-20;
end

data(:,2) = data(:,2) + 20;
data(1,2) = 0;
time_data = data(:,1) - data(1,1);
depth_data = data(:,2);

% Trim out data between 0 and 20 cm depth =================================
time_data(depth_data == 20) = [];
depth_data(depth_data == 20) = [];

% Load simulink data ======================================================
load('SIM_data.mat');
SIM.depth = (SIM.depth - max(SIM.depth)).*100;
SIM.DR = -100.*SIM.DR(:,2);

% Create error bars for the depth =========================================
uncert_depth = 1.*ones(size(depth_data)); % +/- 1cm is accuracy of range-finder

figure
plot(SIM.t,SIM.depth,'r','LineWidth',3)
hold on
plot(time_data,-depth_data,'.','MarkerSize',10)
err_h = errorbar(time_data,-depth_data,uncert_depth);
set(err_h,'LineStyle','none');
err_h_Children = get(err_h,'Children');
set(err_h_Children(1),'LineWidth',1.5);
set(err_h_Children(2),'LineWidth',1.5);
xlabel('Time, s')
ylabel('Depth, cm')
grid on
ylim([-final_depth 0])
xlim([0 max(time_data)])

% Determine the descent rate ==============================================
descent_rate = diff(depth_data)./diff(time_data);
dt = diff(time_data);
DR_time_vec = zeros(size(descent_rate));
DR_time_vec(1) = dt(1)/2;
for ii = 2:length(dt)
    DR_time_vec(ii) = DR_time_vec(ii-1) + dt(ii);
end

% Determine the error in descent rate =====================================
uncert_DR = descent_rate.*sqrt((mean(uncert_depth)./diff(depth_data)).^2 + ...
    (std(dt)./DR_time_vec).^2);

figure
plot(SIM.t,SIM.DR,'r','LineWidth',3)
hold on
plot(DR_time_vec,descent_rate,'.','MarkerSize',10)
err_h2 = errorbar(DR_time_vec,descent_rate,uncert_DR);
set(err_h2,'LineStyle','none');
err_h2_Children = get(err_h2,'Children');
set(err_h2_Children(1),'LineWidth',1.5);
set(err_h2_Children(2),'LineWidth',1.5);
xlabel('Time, s')
ylabel('Depth, cm')
grid on
% ylim([-final_depth 0])
% xlim([0 max(time_data)])
