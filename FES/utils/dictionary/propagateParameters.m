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
n = Environment.Moon.SH.n.value;
m = Environment.Moon.SH.n.value;
[csi, eta, zeta, Cnm, Snm, TestData] = computeSHCoeffs(n,m);

% Update spherical harmonic coefficients in the Environment structure
Environment.Moon.SH.csi.value = csi;
Environment.Moon.SH.eta.value = eta;
Environment.Moon.SH.zeta.value = zeta;
Environment.Moon.SH.Cnm.value = Cnm;
Environment.Moon.SH.Snm.value = Snm;

% Update the dictionary with the modified 'Environment' and 'TestData' fields
updateParameters('Scenario.sldd',{'Environment','TestData'},{Environment,TestData},true);

% Update initial states of the satellites
initialStates();

%% Navigation Data

% Get Parameters
nav = getParameters('Navigation.sldd',{'Propagation'});
Propagation = nav{1};

% Update starting date
StartDate = Environment.Date; 

% Update Moon parameters
Propagation.Moon.eul0.value = eul.value(1,:);
Propagation.Moon.eul0.unit = 'rad';
Propagation.Moon.eul0.description = 'Initial ZXZ rotation angles from J2000 to MOON_PA';

Propagation.Moon.eul_dot.value = mean(eul_dot.value,1);
Propagation.Moon.eul_dot.unit = 'rad/s';
Propagation.Moon.eul_dot.description = 'Time derivative of the ZXZ rotation angles from J2000 to MOON_PA';

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

% Update dictionary
updateParameters('Navigation.sldd',{'StartDate','Propagation'},{StartDate,Propagation},true)

end

