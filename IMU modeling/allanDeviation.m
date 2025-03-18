function [adev,tau] = allanDeviation(t0, meas)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute Allan Deviation
% This function calculates the Allan deviation for a given set of
% measurements, providing insight into the noise characteristics of a
% sensor.
%
% INPUTS:
%   t0    - Sampling time interval (seconds)
%   meas -  measurements
%
% OUTPUTS:
%   adev  - Allan deviation values
%   tau   - Averaging times (seconds)
%
% Reference:
% https://it.mathworks.com/help/nav/ug/inertial-sensor-noise-analysis-using-allan-variance.html
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Compute the integral of the measurements
theta = cumsum(meas, 1)*t0;

% Define the number of averaging times
maxNumM = 100;
L = size(theta, 1);
maxM = 2.^floor(log2(L/2));

% Generate logarithmically spaced values for averaging factor m
m = logspace(log10(1), log10(maxM), maxNumM).';
m = ceil(m); % m must be an integer.
m = unique(m); % Remove duplicates.

% Compute corresponding averaging times
tau = m*t0;

% Initialize Allan variance array
avar = zeros(numel(m), 1);

% Compute Allan variance using the standard three-sample formula
for i = 1:numel(m)
    mi = m(i);
    avar(i,:) = sum( ...
        (theta(1+2*mi:L) - 2*theta(1+mi:L-mi) + theta(1:L-2*mi)).^2, 1);
end

% Normalize Allan variance
avar = avar ./ (2*tau.^2 .* (L - 2*m));

% Compute Allan deviation as the square root of Allan variance
adev = sqrt(avar);

end
