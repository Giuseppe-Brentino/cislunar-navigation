clearvars;
close all;
clc;

%% Read data

% Get allan deviation values from datasheet
acc_asd = readmatrix("acc.csv");
acc_asd = sortrows(acc_asd);
acc.tau = acc_asd(:,1)+acc_asd(:,2)*1e-15;
acc.adev = acc_asd(:,3)+acc_asd(:,4)*1e-15;

gyro_asd = readmatrix("gyro.csv");
gyro_asd = sortrows(gyro_asd);
gyro.tau = gyro_asd(:,1)+gyro_asd(:,2)*1e-15;
gyro.adev = gyro_asd(:,3)+gyro_asd(:,4)*1e-15;

% Scaling coefficient to convert from deg/s to deg/h 
gyro.scaling = 3600;

% Get Sensor data
IMU_data = getParameters('Sensors.sldd',{'IMU'});
IMU = IMU_data{1};

%% Find optimal parameters accelerometer

% Optimization options
opt = optimoptions("fmincon","Display","iter-detailed","OptimalityTolerance",1e-10);

% Activate fast restart on the simulink model for faster simulations
load_system("noiseModel.slx")
set_param("noiseModel","FastRestart","on")

% Initial conditions [K, Tb scaling, B scaling]
x0_acc = [1e-5,1, 1];

% Optimization
[x_acc,~,exitflag] = fmincon(@(x)costFcn(x,IMU.accelerometer,acc),x0_acc,[],[],...
    [],[],[0,1e-1,1e-1],[1,10,1e1],[],opt);

% If a valid solution is found, update the sensor's parameters
if exitflag >=0
    IMU.accelerometer.K.value = x_acc(1);
    IMU.accelerometer.Tb.value = IMU.accelerometer.Tb.value/x_acc(2);
    IMU.accelerometer.Sb.value = IMU.accelerometer.Sb.value*x_acc(2)*x_acc(3)^2;
end

%% Find optimal parameters gyro

% Initial conditions [K, Tb scaling, B scaling]
x0_gyro = [1e-8,1, 1];

% Optimization
[x_gyro,~,exitflag] = fmincon(@(x)costFcn(x,IMU.gyroscope,gyro),x0_gyro,[],[],...
    [],[],[0,1e-1,1e-1],[1,10,1e1],[],opt);

% If a valid solution is found, update the sensor's parameters
if exitflag >=0
    IMU.gyroscope.K.value = x_gyro(1);
    IMU.gyroscope.Tb.value = IMU.gyroscope.Tb.value/x_gyro(2);
    IMU.gyroscope.Sb.value = IMU.gyroscope.Sb.value*x_gyro(2)*x_gyro(3)^2;
end

%% Save data to dictionary
updateParameters('Sensors.sldd',{'IMU'},{IMU},true);

%% 
sensor = IMU.gyroscope;
simulation = sim("noiseModel.slx","srcWorkspace",'current');

% Compute Allan deviation from simulated angular velocity data
t0 = sensor.sampleTime.value;
meas = simulation.simout;
[adev_sim, tau_sim] = allanDeviation(t0,meas);
adev_sim = gyro.scaling*adev_sim;

figure
loglog(gyro.tau,gyro.adev,'DisplayName','Real')
hold on
grid on
loglog(tau_sim,adev_sim,'--','DisplayName','Simulated')
xlabel('Averaging time [s]')
ylabel('Root Allan Variance [deg/h]')
legend
exportStandardizedFigure(gcf,'gyro_allan',0.65,'addMarkers',false,...
    'overwriteFigure',true,'WHRatio',13/9)

%% ACC
sensor = IMU.accelerometer;
simulation = sim("noiseModel.slx","srcWorkspace",'current');

% Compute Allan deviation from simulated angular velocity data
t0 = sensor.sampleTime.value;
meas = simulation.simout;
[adev_sim, tau_sim] = allanDeviation(t0,meas);
adev_sim = 1000/9.81*adev_sim;

figure
loglog(acc.tau,acc.adev,'DisplayName','Real')
hold on
grid on
loglog(tau_sim,adev_sim,'--','DisplayName','Simulated')
xlabel('Averaging time [s]')
ylabel('Root Allan Variance [mg]')
legend
exportStandardizedFigure(gcf,'acc_allan',0.65,'addMarkers',false,...
    'overwriteFigure',true,'WHRatio',13/9)

%% Clock
s = getParameters('Sensors.sldd',{'clock'});
clock = s{1};
sensor = clock;
simulation = sim("noiseModel.slx","srcWorkspace",'current');

% Compute Allan deviation from simulated angular velocity data
t0 = sensor.sampleTime.value;
meas = simulation.simout;
[adev_sim, tau_sim] = allanDeviation(t0,meas);

tau_ideal = [1e-1 1e1 1e3 1e4];
adev_ideal = [1e-12 1e-13 1e-13 2e-13];
figure
loglog(tau_ideal, adev_ideal,'DisplayName','Designed')
hold on
grid on
loglog(tau_sim, adev_sim,'--','DisplayName','Simulated')
xlabel('Averaging time [s]')
ylabel('Root Allan Variance [s]')
legend
exportStandardizedFigure(gcf,'clock_allan',0.65,'addMarkers',false,...
    'overwriteFigure',true,'WHRatio',13/9)











