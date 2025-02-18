function propagateParameters

% Get dictionary data
params = getParameters('Scenario.sldd',{'time','Environment'});
time = params{1};
Environment = params{2};

% Update moon orientation and its rate of change
[eul, eul_dot, jd_interval] = moonOrientation(Environment.Date,time.value);

Environment.Moon.orientation = eul;
Environment.Moon.orientation_dot = eul_dot;
Environment.Moon.jd_interval = jd_interval;

% Update the Moon's spherical harmonics coefficients
n = Environment.Moon.SH.n.value;
m = Environment.Moon.SH.n.value;
[csi, eta, zeta, Cnm, Snm, TestData] = computeSHCoeffs(n,m);
Environment.Moon.SH.csi.value = csi;
Environment.Moon.SH.eta.value = eta;
Environment.Moon.SH.zeta.value = zeta;
Environment.Moon.SH.Cnm.value = Cnm;
Environment.Moon.SH.Snm.value = Snm;
updateParameters('Scenario.sldd',{'Environment','TestData'},{Environment,TestData},true);
end

