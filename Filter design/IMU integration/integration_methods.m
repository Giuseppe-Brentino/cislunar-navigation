close all;
clearvars;
clc;

%% Simulate measurements

rng('default')

meas = sim("measurement_sim.slx");
accelerometer = meas.acc';
gyroscope = meas.omega';
dt = 1/30;
%% Forward Euler at full speed

v = zeros(3,size(gyroscope,2));
q = zeros(4,size(gyroscope,2));
q(4,1) = 1;

tic
for i = 2:size(gyroscope,2)
v(:,i) = v(:,i-1) + accelerometer(:,i)*dt;

omega = gyroscope(:,i);
omega_mat   = [ 0      -omega(3)   omega(2);
               omega(3)  0       -omega(1);
               -omega(2)  omega(1)   0;];
Omega       = [ -omega_mat  omega;
                -omega'      0];         
q(:,i)      = (eye(4) + 0.5*Omega*dt)*q(:,i-1);
end
time.FE_30Hz=toc;

%% Forward Euler at reduced speed
reduced_coeff = 6; % From 30 to 5 Hz
gyro_red = gyroscope(:,1:reduced_coeff:end);
acc_red = accelerometer(:,1:reduced_coeff:end);

v = zeros(3,size(gyro_red,2));
q = zeros(4,size(gyro_red,2));
q(4,1) = 1;

tic

for i = 2:size(gyro_red,2)
v(:,i) = v(:,i-1) + acc_red(:,i)*dt*reduced_coeff;

omega = gyro_red(:,i);
omega_mat   = [ 0      -omega(3)   omega(2);
               omega(3)  0       -omega(1);
               -omega(2)  omega(1)   0;];
Omega       = [ -omega_mat  omega;
                -omega'      0];         
q(:,i)      = (eye(4) + 0.5*Omega*dt*reduced_coeff)*q(:,i-1);
end

time.FE_5Hz=toc;
