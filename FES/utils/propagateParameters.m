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
end

