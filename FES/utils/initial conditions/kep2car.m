function [r, v] = kep2car(a, e, i, OM, om, th, mu)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  Conversion from Keplerian elements to Cartesian coordinates.
%  
% INPUT:
%   a[1]    Semi-major axis                     [km]
%   e[1]    Eccentricity                        [-]
%   i[1]    Inclination                         [rad]
%   OM[1]   RAAN                                [rad]
%   om[1]   Argument of pericentre              [rad]
%   th[1]   True anomaly                        [rad]
%   mu[1]   Planet's gravitational parameter    [km^3/s^2]
%
% OUTPUT:
%   r[3x1]  Position vector           [km]
%   v[3x1]  Velocity vector           [km/s]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin==6
    mu=398600.433;
end

p = a*(1-e^2);          % semi-latus rectum [km]
r = p/(1+e*cos(th));    % radius [km]

% State vector in perifocal reference frame
r_PF = r*[cos(th), sin(th), 0]';
v_PF = sqrt(mu/p)*[-sin(th), e+cos(th), 0]';


%% Rotation of the state vector in the Earth Centered Equatorial Inertial Frame

%Starting frame: ECEI
% Rotation around axis k of an angle OM
R3_OM=[cos(OM) sin(OM) 0;
      -sin(OM) cos(OM) 0;
       0       0       1];

% Rotation around i'= N (node line) of an angle i
R1_i=[1  0      0;
      0  cos(i) sin(i);
      0 -sin(i) cos(i)];

% Rotation around k'' = h (angular momentum vector) of an angle om
R3_om=[ cos(om) sin(om) 0;
       -sin(om) cos(om) 0;
        0       0       1];

% Final frame: Perifocal frame
T_PF2ECI=(R3_om*R1_i*R3_OM)';     % Complete rotation matrix from PF to ECI

r = T_PF2ECI * r_PF;      %r_ECI
v = T_PF2ECI * v_PF;      %v_ECI

return




