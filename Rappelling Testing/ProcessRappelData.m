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
set(0,'DefaultAxesFontSize',14)

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
[SIM_depth, SIM_DR, SIM_t] = RappellingSimulink(final_depth, time_data);
% SIM.depth = (SIM.depth - max(SIM.depth)).*100;
% SIM.DR = -100.*SIM.DR(:,2);

% Load video data =========================================================
load('CR_vid_position.mat');
CRpos.time_seconds(1:4) = [];
CRpos.time_seconds = CRpos.time_seconds - CRpos.time_seconds(1);
CRpos.x_pixel(1:4) = [];
load('top_bot_refs_3_18_18_34_56.mat');
pixel2ft = (top_bot_refs.top_bot_diff_ft./(top_bot_refs.x_pixel(1:2:end-1) - top_bot_refs.x_pixel(2:2:end)));
pixel2m = pixel2ft.*0.3048; % Convert from ft/pix to m/pix
top_pix_interp = interp1(top_bot_refs.time_seconds(2:2:end),top_bot_refs.x_pixel(2:2:end),CRpos.time_seconds,'linear','extrap');
bot_pix_interp = interp1(top_bot_refs.time_seconds(1:2:end-1),top_bot_refs.x_pixel(1:2:end-1),CRpos.time_seconds,'linear','extrap');

% Determine the CR Depth over time ========================================
CR_depth_vid = (bot_pix_interp-CRpos.x_pixel).*mean(pixel2m);
CR_depth_vid = CR_depth_vid - CR_depth_vid(1);
CR_depth_vid = CR_depth_vid.*100; % Convert to cm

% Calculate the error bars for depth ======================================
uncert_pix = 50;
% uncert_depth = CR_depth.*sqrt((uncert_pix./(bot_pix_interp-pos.x_pixel)).^2 +...
%     ((std(pixel2m)/mean(pixel2m)).^2).*ones(size(pos.x_pixel)));
uncert_depth_vid = uncert_pix*mean(pixel2m)*100.*ones(size(CR_depth_vid)) + ...
    0.*std(pixel2m)*mean(pixel2m)*100.*ones(size(CR_depth_vid));

% Create error bars for the depth =========================================
uncert_depth = 1.*ones(size(depth_data)); % +/- 1cm is accuracy of range-finder

figure
h1 = plot([0 max(time_data)],[-final_depth+20 -final_depth+20],'g--','LineWidth',3);
hold on
h2 = plot(SIM_t,SIM_depth,'b','LineWidth',3);
h3 = plot(CRpos.time_seconds,CR_depth_vid,'k^','MarkerSize',8,'MarkerFaceColor','k');
err_h2 = errorbar(CRpos.time_seconds,CR_depth_vid,uncert_depth_vid,'k');
h4 = plot(time_data,-depth_data,'r.','MarkerSize',15);
err_h = errorbar(time_data,-depth_data,uncert_depth,'r');
set(err_h,'LineStyle','none');
set(err_h2,'LineStyle','none');
err_h_Children = get(err_h,'Children');
set(err_h_Children(1),'LineWidth',1.5);
set(err_h_Children(2),'LineWidth',1.5);
err_h2_Children = get(err_h2,'Children');
set(err_h2_Children(1),'LineWidth',1.5);
set(err_h2_Children(2),'LineWidth',1.5);
xlabel('Time, s')
ylabel('Depth, cm')
grid on
ylim([-final_depth 0])
xlim([0 max(time_data)])
legend([h4 h3 h2 h1],'Range-finder Depth Measurements','Depth Measurements From Video','Expected Performance From Model','20cm Above Target Depth')

% Plot the residuals ======================================================
sim_interp = griddedInterpolant(SIM_t,SIM_depth,'linear');
RF_res = (-depth_data) - sim_interp(time_data);
vid_res = CR_depth_vid - sim_interp(CRpos.time_seconds);

figure
h1 = plot(CRpos.time_seconds,vid_res,'k^','MarkerSize',8,'MarkerFaceColor','k');
hold on
err_h1 = errorbar(CRpos.time_seconds,vid_res,uncert_depth_vid,'k');
set(err_h1,'LineStyle','none');
err_h1_Children = get(err_h1,'Children');
set(err_h1_Children(1),'LineWidth',1.5);
set(err_h1_Children(2),'LineWidth',1.5);
h2 = plot(time_data,RF_res,'r.','MarkerSize',15);
err_h2 = errorbar(time_data,RF_res,uncert_depth,'r');
set(err_h2,'LineStyle','none');
err_h2_Children = get(err_h2,'Children');
set(err_h2_Children(1),'LineWidth',1.5);
set(err_h2_Children(2),'LineWidth',1.5);
xlim([0 max(time_data)])
grid on
xlabel('Time, s')
ylabel('Depth Measurement Residuals, cm')
legend([h2 h1],'Range-finder Depth Measurement Residuals','Residuals of Depth Measurements From Video')

% Determine the descent rate ==============================================
descent_rate = diff(depth_data)./diff(time_data);
dt = diff(time_data);
DR_time_vec = zeros(size(descent_rate));
DR_time_vec(1) = dt(1)/2;
for ii = 2:length(dt)
    DR_time_vec(ii) = time_data(ii) + dt(ii)/2;
end

% Determine the error in descent rate =====================================
uncert_DR = descent_rate.*sqrt((mean(uncert_depth)./diff(depth_data)).^2 + ...
    (std(dt)./DR_time_vec).^2);

figure
h1 = stairs(SIM_t,SIM_DR,'b','LineWidth',3);
hold on
h2 = plot(DR_time_vec,descent_rate,'r.','MarkerSize',15);
err_h2 = errorbar(DR_time_vec,descent_rate,uncert_DR,'r');
set(err_h2,'LineStyle','none');
err_h2_Children = get(err_h2,'Children');
set(err_h2_Children(1),'LineWidth',1.5);
set(err_h2_Children(2),'LineWidth',1.5);
xlabel('Time, s')
ylabel('Descent Rate, cm/s')
xlim([0 max(time_data)])
grid on
legend([h2 h1],'Calculated Speed From Range-finder Data','Expected Performance From Model')
% ylim([-final_depth 0])
% xlim([0 max(time_data)])
