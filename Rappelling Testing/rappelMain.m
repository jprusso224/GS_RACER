clear all
close all

fontSize = 13;
lineWidth = 1.5;
x0 = 1.27; % initial depth, m
u = 0; % commanded depth, m
t = 0; % sec
frac_of_domain_to_steps_per_sec = 8000/0.2;%3300; % 
domain_to_slow = -0.2; % Depth error domain where we want to slow down, m


n_steps = 200; % steps per revolution, without gear ratio or micro-stepping
gear_ratio = 15;
micro_step_setting = 1/8;
n_steps_true = n_steps*gear_ratio/micro_step_setting;
radperstep = 2*pi/n_steps_true;
% radperstep = 4.0212E-4; % rad/step of stepper motor 0.0021;
radius_spool = 0.04445; % m

r_wire = 0.79375E-3; % radius of tether, m
effective_radius_spool = radius_spool + 3*r_wire;

% Depth Response plot
t_delay = 0.31; % Transport delay, seconds
sim_time = 0:t_delay:30;
[tout yout yout2] = sim('rappellingLoop.slx',sim_time);
% t_delay = 0.25;
% [tout_25 yout_t25 yout2_t25] = sim('rappellingLoop.slx');
% t_delay = 0.5;
% [tout_5 yout_t5 yout2_t5] = sim('rappellingLoop.slx');
% t_delay = 0.75;
% [tout_75 yout_t75 yout2_t75] = sim('rappellingLoop.slx');
% t_delay = 1;
% [tout_1 yout_t1 yout2_t1] = sim('rappellingLoop.slx');
figure(1)
subplot(2,1,1)
p_depth = plot(tout,yout,'.');
% hold on
% p_d25 = plot(tout_25,yout_t25,'k');
% p_d5 = plot(tout_5,yout_t5,'m');
% p_d75 = plot(tout_75,yout_t75,'r');
% p_d1 = plot(tout_1,yout_t1,'g');


grid on
set(gca,'FontSize',fontSize);
set(p_depth,'LineWidth',lineWidth);
% set(p_d25,'LineWidth',lineWidth);
% set(p_d5,'LineWidth',lineWidth);
% set(p_d75,'LineWidth',lineWidth);
% set(p_d1,'LineWidth',lineWidth);
ylabel('Depth, m')
xlabel('Time, s')
title('Rappelling Depth Response')

hold on
linearTime = linspace(0,30,100);
startControl = -domain_to_slow*ones(1,100);
plot(linearTime,startControl,'--r')
xlim([0 max(sim_time)])
ylim([-0.1 x0+(0.1*x0)])



% Velocity Response plot
subplot(2,1,2)
p_velocity = stairs(tout,yout2(:,2));
xlim([0 max(sim_time)])
ylim([-.11 0.01])
% hold on
% p_v25 = plot(tout_25,yout2_t25(:,2),'k');
% p_v5 = plot(tout_5,yout2_t5(:,2),'m');
% p_v75 = plot(tout_75,yout2_t75(:,2),'r');
% p_v1 = plot(tout_1,yout2_t1(:,2),'g');

grid on
set(gca,'FontSize',fontSize);
set(p_velocity,'LineWidth',lineWidth);
% set(p_v25,'LineWidth',lineWidth);
% set(p_v5,'LineWidth',lineWidth);
% set(p_v75,'LineWidth',lineWidth);
% set(p_v1,'LineWidth',lineWidth);
ylabel('Rate of Change of Depth, m/s')
xlabel('Time, s')
title('Rappelling Velocity Response')

figure(3)
plot(tout,yout2(:,3))
ylabel('Depth Error, m')
xlabel('Time, s')
title('Rappelling Depth Error Response')

%% Determine response properties
% startIndex = find(yout <= 1,1);
% startTime = tout(startIndex);
% endIndex = find(yout <= 0.05,1); %index of 95% of desired position
% endTime = tout(endIndex);
% timeConstant = endTime - startTime;
% 
% finalIndex = find(yout <= 0.001,1)
% finalTime = tout(finalIndex)
% finalTime - startTime
% No overshoot!!! This is because the nature of the stepper motor



