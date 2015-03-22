%% ProcessDriveData.m
% =========================================================================
% PURPOSE:
%    This file has the user select a driving data file to plot the
%    different wheel readings
% =========================================================================
clear; close all;

%%
datafile = uigetfile('*.txt','Select A Driving Data File');

dataFID = fopen(datafile);
% data = [];


datastr = struct([]);
datastr(1).FR_time = [];
datastr(1).FR = [];
datastr(1).FL_time = [];
datastr(1).FL = [];
datastr(1).BR_time = [];
datastr(1).BR = [];
datastr(1).BL_time = [];
datastr(1).BL = [];

dataline = fgetl(dataFID);
dataline_EOT = find(dataline == ' ',1,'first')-1;
dataline_SOD = find(dataline == ' ',1,'last') +1;
FR_count = 1;
FRS_count = 1;
FL_count = 1;
FLS_count = 1;
BR_count = 1;
BL_count = 1;
while dataline ~= -1
%     disp(dataline(8:9))
    if length(dataline) > dataline_SOD
%         disp(dataline)
    switch dataline(dataline_SOD:dataline_SOD+1)
        case 'FR'
            if strcmp(dataline(dataline_SOD+2),'D')
                datastr.FR_time(FR_count) = str2double(dataline(1:dataline_EOT));
                datastr.FR(FR_count) = str2double(dataline(dataline_SOD+4:end));
                FR_count = FR_count+1;
            elseif strcmp(dataline(dataline_SOD+2),'S')
                datastr.FRS_time(FRS_count) = str2double(dataline(1:dataline_EOT));
                datastr.FRS(FRS_count) = str2double(dataline(dataline_SOD+4:end))/1000;
                FRS_count = FRS_count+1;
            end
        case 'FL'
            if strcmp(dataline(dataline_SOD+2),'D')
                datastr.FL_time(FL_count) = str2double(dataline(1:dataline_EOT));
                datastr.FL(FL_count) = str2double(dataline(dataline_SOD+4:end));
                FL_count = FL_count+1;
            elseif strcmp(dataline(dataline_SOD+2),'S')
                datastr.FLS_time(FLS_count) = str2double(dataline(1:dataline_EOT));
                datastr.FLS(FLS_count) = str2double(dataline(dataline_SOD+4:end))/1000;
                FLS_count = FLS_count+1;
            end
        case 'BR'
            datastr.BR_time(BR_count) = str2double(dataline(1:dataline_EOT));
            datastr.BR(BR_count) = str2double(dataline(dataline_SOD+4:end));
            BR_count = BR_count+1;
        case 'BL'
            datastr.BL_time(BL_count) = str2double(dataline(1:dataline_EOT));
            datastr.BL(BL_count) = str2double(dataline(dataline_SOD+4:end));
            BL_count = BL_count+1;
    end
    end
    dataline = fgetl(dataFID);
    dataline_EOT = find(dataline == ' ',1,'first')- 1;
    dataline_SOD = find(dataline == ' ',1,'last') + 1;
end

fclose all;

figure
plot(datastr.FR_time,datastr.FR,datastr.FL_time,datastr.FL,...
    datastr.BR_time,datastr.BR,datastr.BL_time,datastr.BL,...
    'linewidth',3);
grid on
legend('FR','FL','BR','BL','Location','NorthEast')
grid on

FR_length = length(datastr.FR);
FL_length = length(datastr.FL);
BR_length = length(datastr.BR);
BL_length = length(datastr.BL);

x0 = 0;
y0 = 0;
t0 = mean([datastr.FR_time(1) datastr.FL_time(1) datastr.BR_time(1) datastr.BL_time(1)]);
t = t0;
x = x0;
y = y0;
theta0 = 0;
theta = theta0;
d_backwheels  = 2*210; % mm
d_frontwheels = 2*220; % mm
for ii = 1:min([FR_length FL_length BR_length BL_length])-1
    diff_front = datastr.FR(ii) - datastr.FL(ii);
    diff_back  = datastr.BR(ii) - datastr.BL(ii);
    diff_back2 = datastr.BR(ii+1) - datastr.BL(ii+1);
    delta_dist = mean([datastr.BR(ii+1) datastr.BL(ii+1)]) - mean([datastr.BR(ii) datastr.BL(ii)]);
    delta_theta = (diff_back2/2)/(d_backwheels/2) - (diff_back/2)/(d_backwheels/2);
    
    theta(ii+1,1) = theta(ii) + rad2deg(delta_theta);
    x(ii+1,1) = x(ii) + delta_dist*cos(delta_theta);
    y(ii+1,1) = y(ii) + delta_dist*sin(delta_theta);
    
    t(ii+1,1) = mean([datastr.FR_time(ii+1) datastr.FL_time(ii+1) datastr.BR_time(ii+1) datastr.BL_time(ii+1)]);
    
end

figure
subplot(2,1,1)
plot(x, y,'.-')
xlabel('X-position, mm')
ylabel('Y-position, mm')
xlim([min(x) max(x)])
grid on
subplot(2,1,2)
plot(x,theta,'r.-')
xlim([min(x) max(x)])
xlabel('X-position, mm')
ylabel('Orientation, deg')
grid on

speed = diff(sqrt(x.^2 + y.^2))./diff(t);
figure
plot(t(1:end-1),speed,'.-')
hold on
plot(datastr.FRS_time,datastr.FRS,'r.-')
plot(datastr.FLS_time,datastr.FLS,'k.-')
legend('Measured Speed','Reported FRS','Reported FLS')
xlabel('Time, s')
ylabel('Speed, mm/s')
grid on

