function [SIM_depth, SIM_DR, SIM_t] = RappellingSimulink(depth_cmd, t_exp)

x0 = depth_cmd/100; % commanded depth, m
u = 0; % initial depth, m
t = 0;
frac_of_domain_to_steps_per_sec = 8000/0.2;
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

sim_time = t_exp; % Run simulation at same update rate as the true experiment
options = simset('SrcWorkspace','current');
set_param('rappellingLoop','InitInArrayFormatMsg','None');

[tout, yout, yout2] = sim('rappellingLoop.slx',sim_time,options);

SIM_t = tout;
SIM_depth = 100.*(yout - max(yout));
SIM_DR = -100.*yout2(:,2);
