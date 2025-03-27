clearvars;
close all;
clc;

%% Read data

% Get allan deviation values from datasheet
acc_asd = readmatrix("acc.csv");
acc_asd = sortrows(acc_asd);
acc.tau = acc_asd(:,1)+acc_asd(:,2)*1e-15;
acc.adev = acc_asd(:,3)+acc_asd(:,4)*1e-15;

% Scaling coefficient to convert from m/s^2 to mg 
acc.scaling = 1000/9.81;

% Get Sensor data
IMU_data = getParameters('Sensors.sldd',{'IMU'});
IMU = IMU_data{1};

%% Find optimal parameters accelerometer

% Optimization options
opt = optimoptions("fmincon","Display","iter-detailed","OptimalityTolerance",1e-10);

% Activate fast restart on the simulink model for faster simulations
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

% Save data to dictionary
updateParameters('Sensors.sldd',{'IMU'},{IMU},true);


