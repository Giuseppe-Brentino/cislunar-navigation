%% get data from dictionary
data= getParameters('Scenario.sldd',{'Environment','MainSpacecraft','BeaconSpacecraft'});
MainSpacecraft = data{2};
BeaconSpacecraft = data{3};

%% Main spacecraft initial state
% orbital elements
a = 2000;
e = 0;
i = deg2rad(45);
OM = deg2rad(90);
om = 0;
th = 0;

OrbitCtrl = getParameters('Scenario.sldd',{'OrbitCtrl'});
OrbitCtrl{1}.target_i.value = rad2deg(i);
updateParameters('Scenario.sldd',{'OrbitCtrl'},OrbitCtrl(1),true);

% conversion to cartesian state
[x,v] = kep2car(a,e,i,OM,om,th,data{1}.Moon.mu.value);


% Save initial conditions
MainSpacecraft = saveIC(MainSpacecraft,x,v);


%% Beacon Spacecraft

% Get the full path of the current function file
currentFile = mfilename('fullpath');

% Get the folder containing the function
folder = fileparts(currentFile);

% Simulation start date
date = data{1}.Date;
y = date.year;
m = date.month;
d = date.day;
h = date.hour;
min = date.min;
s = date.sec;
startDate = datetime(y,m,d,h,min,s);

% Convert dates to ephemeris time (ET) using cspice_str2et
cspice_furnsh(strcat(folder,'\..\..\Data\naif0012.tls'));
et =  cspice_str2et( char(startDate ) );

% Read data from kernel
cspice_furnsh(strcat(folder,'\LumioKernel.bsp'));
cspice_furnsh(strcat(folder,'\..\..\Data\de421.bsp'));
[xx,~] = cspice_spkezr('-100009', et, 'J2000', 'NONE', 'MOON');

% Save initial conditions
BeaconSpacecraft = saveIC(BeaconSpacecraft,xx(1:3),xx(4:6));

%% Filter initial state

% Get data from dictionary
nav = getParameters('Navigation.sldd',{'x0'});
x0 = nav{1};

% Save inital state
x0.value(1:3) = MainSpacecraft.x0.nominal;
x0.value(4:6) = MainSpacecraft.v0.nominal;
x0.value(7:10) = MainSpacecraft.q0.value;
x0.value(11:13) = BeaconSpacecraft.x0.nominal;
x0.value(14:16) = BeaconSpacecraft.v0.nominal;

%% Update dictionaries
updateParameters('Scenario.sldd',{'MainSpacecraft','BeaconSpacecraft'},...
    {MainSpacecraft,BeaconSpacecraft}, true);

updateParameters('Navigation.sldd',{'x0'},{x0},true);
