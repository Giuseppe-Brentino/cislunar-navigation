close all;
clearvars;
clc;

%% Get gravity data

% Run simulation
out = sim("GravityModel.slx");

% get gravity error
main_err = 1e3*squeeze(out.main_diff);
beacon_err = 1e3*squeeze(out.beacon_diff);


%% FIT

% main
[sm1,~] = mle(main_err(1,:)','pdf',@(x,sigma) pdf('normal',main_err(1,:)',0,sigma),...
    'start',std(main_err(1,:)));
[sm2,~] = mle(main_err(2,:)','pdf',@(x,sigma) pdf('normal',main_err(2,:)',0,sigma),...
    'start',std(main_err(2,:)));
[sm3,~] = mle(main_err(3,:)','pdf',@(x,sigma) pdf('normal',main_err(3,:)',0,sigma),...
    'start',std(main_err(3,:)));

% Beacon
[sb1,~] = mle(beacon_err(1,:)','pdf',@(x,sigma) pdf('normal',beacon_err(1,:)',0,sigma),...
    'start',std(beacon_err(1,:)));
[sb2,~] = mle(beacon_err(2,:)','pdf',@(x,sigma) pdf('normal',beacon_err(2,:)',0,sigma),...
    'start',std(beacon_err(2,:)));
[sb3,~] = mle(beacon_err(3,:)','pdf',@(x,sigma) pdf('normal',beacon_err(3,:)',0,sigma),...
    'start',std(beacon_err(3,:)));
%% Plots
figure

sgtitle('main error')
x = linspace(-5e-4,5e-4,500);
subplot(3,1,1)
hold on 
grid on
title('g_x')
histogram(main_err(1,:),100,'Normalization', 'pdf')
plot(x,normpdf(x,0,sm1),"LineWidth",2)
xlabel('gravity error [m/s^2]')
ylabel('PDF')

subplot(3,1,2)
hold on 
grid on
title('g_y')
histogram(main_err(2,:),100,'Normalization', 'pdf')
plot(x,normpdf(x,0,sm2),"LineWidth",2)
xlabel('gravity error [m/s^2]')
ylabel('PDF')

subplot(3,1,3)
hold on 
grid on
title('g_z')
histogram(main_err(3,:),100,'Normalization', 'pdf')
plot(x,normpdf(x,0,sm3),"LineWidth",2)
xlabel('gravity error [m/s^2]')
ylabel('PDF')
lgd = legend('error','fitted zero mean gaussian','Orientation','horizontal');
lgd.Position = [0.35 0 0.3 0.05];  % Manually position at bottom center

figure
sgtitle('beacon error')
x = linspace(-1e-5,8e-6,500);
subplot(3,1,1)
hold on 
grid on
title('g_x')
histogram(beacon_err(1,:),100,'Normalization', 'pdf')
plot(x,normpdf(x,0,sb1),"LineWidth",2)
xlabel('gravity error [m/s^2]')
ylabel('PDF')

subplot(3,1,2)
hold on 
grid on
title('g_y')
histogram(beacon_err(2,:),100,'Normalization', 'pdf')
h3 = plot(x,normpdf(x,0,sb2),"LineWidth",2);
xlabel('gravity error [m/s^2]')
ylabel('PDF')

subplot(3,1,3)
hold on 
grid on
title('g_z')
histogram(beacon_err(3,:),100,'Normalization', 'pdf');
plot(x,normpdf(x,0,sb3),"LineWidth",2);
xlabel('gravity error [m/s^2]')
ylabel('PDF')
lgd = legend('error','fitted zero mean gaussian','Orientation','horizontal');
lgd.Position = [0.35 0 0.3 0.05];  

%% Save Q matrix
sensorData = getParameters('Sensors.sldd',{'IMU','clock'});
acc = sensorData{1}.accelerometer;
gyro = sensorData{1}.gyroscope;
clock = sensorData{2};
env = getParameters('Scenario.sldd',{'Environment'});
c = env{1}.c.value*1e-3;

Q = struct();
Q.description = 'Process noise matrix';
Q.value = zeros(20);
Q.value(1:3,1:3) = diag(([sm1,sm2,sm3]*1e-3).^2);
Q.value(4:6,4:6) = diag(([sb1,sb2,sb3]*1e-3).^2);
Q.value(7:9,7:9) = diag((ones(3,1)*acc.N.value*1e-3).^2);
Q.value(10:12,10:12) = diag((ones(3,1)*acc.K.value*1e-3).^2);
Q.value(13:15,13:15) = diag((ones(3,1)*gyro.N.value*1e-3).^2);
Q.value(16:18,16:18) = diag((ones(3,1)*gyro.K.value*1e-3).^2);
Q.value(19,19) = (clock.K.value*c)^2;
Q.value(20,20) = 0;
updateParameters('Navigation.sldd',{'Q'},{Q},true);

%% Define F

% Define symbolic 3x3 blocks
syms F12 F21 F23 F26 [3 3] real
syms F33 F37 F45 F54 [3 3] real

% Define symbolic scalar
syms F89 real

% Define timestep
syms dt real

% Initialize a 23x23 symbolic zero matrix
F = sym(zeros(23));

% Helper function to convert block indices to actual row/col indices
block = @(i) (3*(i-1)+1):(3*i);

% Insert 3x3 symbolic blocks in appropriate positions
F(block(1), block(2)) = F12;
F(block(2), block(1)) = F21;
F(block(2), block(3)) = F23;
F(block(2), block(6)) = F26;
F(block(3), block(3)) = F33;
F(block(3), block(7)) = F37;
F(block(4), block(5)) = F45;
F(block(5), block(4)) = F54;

% Insert scalar symbolic block
F(22,23) = F89;

PSI = sym(eye(23)) + F*dt;
%% Define Q
syms eta_gm eta_gb eta_acc eta_accB eta_gyro eta_gyroB eta_clockD eta_clockA real

QSym = sym(zeros(20));

QSym(block(1), block(1)) = diag(eta_gm*ones(3,1));
QSym(block(2), block(2)) = diag(eta_gb*ones(3,1));
QSym(block(3), block(3)) = diag(eta_acc*ones(3,1));
QSym(block(4), block(4)) = diag(eta_accB*ones(3,1));
QSym(block(5), block(5)) = diag(eta_gyro*ones(3,1));
QSym(block(6), block(6)) = diag(eta_gyroB*ones(3,1));
QSym(19,19) = eta_clockD;
QSym(20,20) = eta_clockA;

%% Define G
syms R_bi R_sb [3 3] real

G = sym(zeros(23,20));

G(block(2), block(1)) = eye(3);
G(block(2), block(3)) = R_bi*R_sb;
G(block(3), block(5)) = -R_sb;
G(block(5), block(2)) = eye(3);
G(block(6), block(4)) = eye(3);
G(block(7), block(6)) = eye(3);
G(22,19) = 1;
G(23,20) = 1;
%% Process noise

process_noise = simplify((PSI*G)*QSym*dt*(PSI*G)');
save process_noise process_noise

%% Simplified process noise

Pn_simp = computeProcessNoise(dt, PSI, R_bi, R_sb, QSym);

% simplify(process_noise-Pn_simp)