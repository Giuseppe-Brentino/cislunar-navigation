function propagateParameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Propagate parameters based on input data from a Simulink data dictionary,
% updating all the correlated entries.
%
% Input:
% None (dictionary values are retrieved within the function)
%
% Output:
% None 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Get dictionary data
params = getParameters('Scenario.sldd',{'time','Environment'});
time = params{1};
Environment = params{2};

% Update moon orientation and its rate of change
[eul, eul_dot, jd_interval] = moonOrientation(Environment.Date,time.value);

% Update the Environment structure with the new moon orientation data
Environment.Moon.orientation = eul;
Environment.Moon.orientation_dot = eul_dot;
Environment.Moon.jd_interval = jd_interval;

% Update the Moon's spherical harmonics coefficients
Environment.Moon.SH.n.value = 15;
Environment.Moon.SH.m.value = 15;
n = Environment.Moon.SH.n.value;
m = Environment.Moon.SH.n.value;
[csi, eta, zeta, Cnm, Snm, Znm, TestData] = computeSHCoeffs(n,m);

% Update spherical harmonic coefficients in the Environment structure
Environment.Moon.SH.csi.value = csi;
Environment.Moon.SH.eta.value = eta;
Environment.Moon.SH.zeta.value = zeta;
Environment.Moon.SH.Cnm.value = Cnm;
Environment.Moon.SH.Snm.value = Snm;
Environment.Moon.SH.Znm.value = Znm;

Environment.Date.hour = 0;
Environment.Date.day = 1;
% Update the dictionary with the modified 'Environment' and 'TestData' fields
updateParameters('Scenario.sldd',{'Environment','TestData'},{Environment,TestData},true);

% Update initial states of the satellites
initialStates();

%% Navigation Data

% Get spacecraft data
sc = getParameters('Scenario.sldd',{'MainSpacecraft','BeaconSpacecraft'});
MainSpacecraft = sc{1};
BeaconSpacecraft = sc{2};

% Get IMU data
imu = getParameters('Sensors.sldd',{'IMU'});
imu_angles = imu{1}.orientation.value;

% Get clock data
clock = getParameters('Sensors.sldd',{'clock'});

% Get NAV Parameters
nav = getParameters('Navigation.sldd',{'Propagation','R_sensor2body','P0','x0','SRP'});
Propagation = nav{1};
R_sensor2body = nav{2};
P0 = nav{3};
x0 = nav{4};
SRP = nav{5};

% SRP Data
SRP.MainSpacecraft.C_R.value = MainSpacecraft.rp_coeff.nominal;
SRP.BeaconSpacecraft.C_R.value = BeaconSpacecraft.rp_coeff.nominal;
SRP.MainSpacecraft.mass.value = MainSpacecraft.mass.value;
SRP.BeaconSpacecraft.mass.value = BeaconSpacecraft.mass.value;
SRP.MainSpacecraft.radius.value = MainSpacecraft.radius.value;
SRP.BeaconSpacecraft.radius.value = BeaconSpacecraft.radius.value;

% Initial Covariance
P0.value(1:3,1:3) = diag(MainSpacecraft.x0.std.^2);
P0.value(4:6,4:6) = diag(MainSpacecraft.v0.std.^2);
P0.value(7:9,7:9) = diag(ones(3,1)*deg2rad(0.5)^2);
P0.value(10:12,10:12) = diag(BeaconSpacecraft.x0.std.^2);
P0.value(13:15,13:15) = diag(BeaconSpacecraft.v0.std.^2);
P0.value(16:18,16:18) = diag(ones(3,1)*(imu{1}.accelerometer.bias.std*0.001)^2);
P0.value(19:21,19:21) = diag(ones(3,1)*deg2rad(imu{1}.gyroscope.bias.std)^2);
P0.value(22,22) = (Environment.c.value*1e-3*clock{1}.deltaT0.std)^2;
P0.value(23,23) = (Environment.c.value*1e-3*clock{1}.deltaT1.std)^2;
P0.value(24,24) = (Environment.c.value*1e-3*clock{1}.deltaT2.std)^2;

% Update starting date
StartDate = Environment.Date; 

% Update Moon parameters
Propagation.Moon.eul0.value = eul.value(1,:);
Propagation.Moon.eul0.unit = 'rad';
Propagation.Moon.eul0.description = 'Initial ZXZ rotation angles from J2000 to MOON_PA';

Propagation.Moon.eul_dot.value = mean(eul_dot.value,1);
Propagation.Moon.eul_dot.unit = 'rad/s';
Propagation.Moon.eul_dot.description = 'Time derivative of the ZXZ rotation angles from J2000 to MOON_PA';

Propagation.Moon.SH.m.value = 10;
Propagation.Moon.SH.n.value= 10;
Propagation.Moon.SH.csi.value = Environment.Moon.SH.csi.value...
    (1:Propagation.Moon.SH.n.value+1,1:Propagation.Moon.SH.m.value+1);
Propagation.Moon.SH.eta.value = Environment.Moon.SH.eta.value...
    (1:Propagation.Moon.SH.n.value+1,1:Propagation.Moon.SH.m.value+1);
Propagation.Moon.SH.zeta.value= Environment.Moon.SH.zeta.value...
    (1:Propagation.Moon.SH.n.value+1,1:Propagation.Moon.SH.m.value+1);
Propagation.Moon.SH.Cnm.value = Environment.Moon.SH.Cnm.value...
    (1:Propagation.Moon.SH.n.value+1,1:Propagation.Moon.SH.m.value+1);
Propagation.Moon.SH.Snm.value = Environment.Moon.SH.Snm.value...
    (1:Propagation.Moon.SH.n.value+1,1:Propagation.Moon.SH.m.value+1);
Propagation.Moon.SH.Znm.value = Environment.Moon.SH.Znm.value...
    (1:Propagation.Moon.SH.n.value+1,1:Propagation.Moon.SH.m.value+1);

% Update IMU orientation
R_sensor2body.value = angle2dcm(imu_angles(3),imu_angles(2),imu_angles(1),'ZXZ')';

% Initial state
x0.value(1:3) = MainSpacecraft.x0.nominal;
x0.value(4:6) = MainSpacecraft.v0.nominal;
x0.value(11:13) = BeaconSpacecraft.x0.nominal;
x0.value(14:16) = BeaconSpacecraft.v0.nominal;
% Update dictionary
updateParameters('Navigation.sldd',{'StartDate','Propagation','R_sensor2body','P0','x0','SRP'},...
    {StartDate,Propagation,R_sensor2body,P0,x0,SRP},true)

end

