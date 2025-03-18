function J = costFcn(x,sensor,data)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Cost Function for Sensor Calibration
% This function evaluates the cost function used for calibrating the sensor
% model parameters by minimizing the difference between simulated and
% measured Allan deviations.
%
% INPUTS:
%   x      - Optimization variables [K, Tb scaling, B scaling]
%   sensor - Sensor model structure containing calibration parameters
%   data   - Structure containing measured Allan deviation data
%
% OUTPUT:
%   J      - Cost function value representing the error between simulated
%            and measured Allan deviations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Update sensor parameters based on optimization variables
sensor.K.value = x(1);
sensor.Tb.value = sensor.Tb.value/x(2);
sensor.Sb.value = sensor.Sb.value*x(2)*x(3)^2;

% Run simulation with updated sensor parameters
simulation = sim("noiseModel.slx","srcWorkspace",'current');

% Compute Allan deviation from simulated angular velocity data
t0 = sensor.sampleTime.value;
acc = simulation.simout;
[adev_sim, tau_sim] = allanDeviation(t0,acc);

% Interpolate simulated Allan deviation to match measured datasheet values
adev_interp = data.scaling*interp1(tau_sim,adev_sim,data.tau);

% Compute cost function (weighted least squares error)
J = 0.5 * ((data.adev-adev_interp)'./data.adev') * ...
    ((data.adev-adev_interp)./data.adev);

end



