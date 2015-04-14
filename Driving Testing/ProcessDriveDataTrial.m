%% ProcessDriveData.m
% =========================================================================
% PURPOSE:
%    This file has the user select a driving data file to plot the
%    different wheel readings
% =========================================================================
clear; close all; clc;
spacer_bar = '=========================================================';

%%
datadirname = uigetdir(pwd,'Select a Driving Data Trial Folder');

datadir = dir(datadirname);
lastslash = find(datadirname == '\',1,'last');
datadirname = datadirname(lastslash+1:end);

disp(spacer_bar)

Ldatadirname = length(datadirname);
Lspacer_bar = length(spacer_bar);
side_length = round((Lspacer_bar - Ldatadirname)/2) - 2;
title_str = [repmat('=',1,side_length) ' ' datadirname ' '];
title_str = [title_str repmat('=',1,Lspacer_bar - length(title_str))];
disp(title_str);
disp(spacer_bar)
file_counter = 1;
for i = 1:length(datadir)
    if ~datadir(i).isdir
        [datastr(file_counter)] = parseDrivingData(fullfile(datadirname,datadir(i).name));
        fprintf('File #%d: ''%s''\n',file_counter,datadir(i).name)
        file_counter = file_counter + 1;
    end
end
file_counter = file_counter - 1;
disp(spacer_bar)
    

fclose all;

x0 = 0;
y0 = 0;
t0 = mean([datastr(1).FR_time(1) datastr(1).FL_time(1) datastr(1).BR_time(1) datastr(1).BL_time(1)]);
t = t0;
x = x0;
y = y0;
theta0 = 0;
theta = theta0;
d_backwheels  = 2*210; % mm
d_frontwheels = 2*220; % mm
full_ind = 1;
full_dist = 0;
x_full = [];
y_full = [];
theta_full = [];
t_full = [];

for jj = 1:file_counter
    
    x = x0;
    y = y0;
    theta = theta0;
    t = t0;

FR_length = length(datastr(jj).FR);
FL_length = length(datastr(jj).FL);
BR_length = length(datastr(jj).BR);
BL_length = length(datastr(jj).BL);

for ii = 1:min([FR_length FL_length BR_length BL_length])-1
    diff_front = datastr(jj).FR(ii) - datastr(jj).FL(ii);
    diff_back  = datastr(jj).BR(ii) - datastr(jj).BL(ii);
    diff_back2 = datastr(jj).BR(ii+1) - datastr(jj).BL(ii+1);
    delta_dist = mean([datastr(jj).BR(ii+1) datastr(jj).BL(ii+1)]) - mean([datastr(jj).BR(ii) datastr(jj).BL(ii)]);
    full_dist = full_dist + delta_dist;
    delta_theta = (diff_back2/2)/(d_backwheels/2) - (diff_back/2)/(d_backwheels/2);
    
    theta(ii+1,1) = theta(ii) + rad2deg(delta_theta);
    x(ii+1,1) = x(ii) + delta_dist*cos(delta_theta);
    y(ii+1,1) = y(ii) + delta_dist*sin(delta_theta);
    
    t(ii+1,1) = t0 + mean([datastr(jj).FR_time(ii+1) datastr(jj).FL_time(ii+1) datastr(jj).BR_time(ii+1) datastr(jj).BL_time(ii+1)]);
    
end

x0 = x(end);
y0 = y(end);
theta0 = theta(end);
t0 = t(end);

x_full = [x_full;x];
y_full = [y_full;y];
theta_full = [theta_full;theta];
t_full = [t_full;t];

fprintf('Total distance after File #%d: % 6.2f mm | % 4.2f in.\n',jj,full_dist,full_dist/25.4)

end
disp(spacer_bar)

figure
subplot(2,1,1)
plot(x_full, y_full,'.','MarkerSize',20,'LineWidth',3)
xlabel('X-position, mm')
ylabel('Y-position, mm')
if min(x_full) ~= max(x_full)
    xlim([min(x_full) max(x_full)])
end
grid on
subplot(2,1,2)
plot(x_full,theta_full,'r.-','MarkerSize',20,'LineWidth',3)
hold on
text(0,0,'THIS IS DEFINITELY WRONG!!!!!')
if max(x_full) ~= min(x_full)
    xlim([min(x_full) max(x_full)])
end
xlabel('X-position, mm')
ylabel('Orientation, deg')
grid on

% dt = diff(t);
% speed = diff(sqrt(x.^2 + y.^2))./dt;
% speed_time = zeros(size(speed));
% speed_time(1) = t(1) + dt(1)/2;
% for ii = 2:length(dt)
%     speed_time(ii) = t(ii) + dt(ii)/2;
% end
% figure
% plot(speed_time,speed,'.-','MarkerSize',20,'LineWidth',3)
% hold on
% plot(datastr.FRS_time,datastr.FRS,'r.-','MarkerSize',20,'LineWidth',3)
% plot(datastr.FLS_time,datastr.FLS,'k.-','MarkerSize',20,'LineWidth',3)
% legend('Measured Speed','Reported FRS','Reported FLS')
% xlabel('Time, s')
% ylabel('Speed, mm/s')
% grid on
% 
% try
% figure
% plot(datastr.pwmL_time,datastr.pwmL,'--','LineWidth',3)
% hold on
% plot(datastr.pwmR_time,datastr.pwmR,'r','LineWidth',3)
% grid on
% legend('Left-motor PWM','Right-motor PWM')
% ylim([-5 260])
% catch err
%     disp(err.message)
% end

