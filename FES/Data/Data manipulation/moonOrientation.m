function [eul, eul_dot, jd_interval] = moonOrientation(date, time)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute the moon's orientation (ZXZ Euler angles) and its rate of change 
% (Euler angle derivatives) for a given date and time interval.
%
% Input:
% date: struct - containing year, month, day, hour, minute, and second
% time: scalar - time interval in seconds from the start date
%
% Output:
% eul: struct - contains the computed Euler angles (ZXZ rotation angles)
% eul_dot: struct - contains the computed time derivatives of the Euler angles
% jd_interval: struct - contains Julian dates for the interpolation points
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Get the full path of the current function file
currentFile = mfilename('fullpath');

% Get the folder containing the function
functionFolder = fileparts(currentFile);

% Get the parent folder of that folder
folder = fileparts(functionFolder);

% Load spice data
cspice_furnsh(strcat(folder,'/moon_pa_de421_1900-2050.bpc'));
cspice_furnsh(strcat(folder,'/moon_080317.tf'));
cspice_furnsh(strcat(folder,'/naif0012.tls'));

% Extract date and time information
y = date.year;
m = date.month;
d = date.day;
h = date.hour;
min = date.min;
s = date.sec;
startDate = datetime(y,m,d,h,min,s);
endDate = startDate + seconds(time);
epoch = startDate:minutes(1):endDate;

% Convert dates to ephemeris time (ET) using cspice_str2et
dates =  cspice_str2et( char(epoch ) );

% Compute the rotation matrix from J2000 to MOON_PA for the given dates
rotate = cspice_sxform( 'J2000', 'MOON_PA', dates );

% Initialize output structure for Euler angles (ZXZ)
eul.type = "ZXZ";
[eul.value(:,3), eul.value(:,2), eul.value(:,1)] = dcm2angle(rotate(1:3,1:3,:),eul.type);
eul.unit = 'rad';
eul.description = 'ZXZ rotation angles from J2000 to MOON_PA';

% Initialize output structure for the time derivative of Euler angles (Euler dot)
eul_dot.unit = 'rad/s';
eul_dot.description = 'Time derivative of the ZXZ rotation angles from J2000 to MOON_PA';

% Extract the derivatives of the rotation matrix (rot_dot)
rot_dot = rotate(4:6,1:3,:);

% Compute sine and cosine values for the Euler angles
sin_psi = sin(eul.value(:,1));
cos_psi = cos(eul.value(:,1));
sin_theta = sin(eul.value(:,2));
cos_theta = cos(eul.value(:,2));
sin_phi = sin(eul.value(:,3));
cos_phi = cos(eul.value(:,3));

% Compute the time derivatives of each Euler angle

theta_dot = squeeze(-rot_dot(end,end,:))./sin_theta;

phi_dot = (squeeze(rot_dot(3,1,:)) - cos_theta.*sin_phi.*theta_dot)./(sin_theta.*cos_phi);

psi_dot = (squeeze(rot_dot(1,1,:)) - theta_dot.*sin_psi.*sin_theta.*sin_phi + ...
    (cos_psi.*sin_phi + sin_psi.*cos_phi.*cos_theta).*phi_dot) ./ ...
    ( -sin_psi.*cos_phi -cos_psi.*cos_theta.*sin_phi );

% Store the computed derivatives in the eul_dot structure
eul_dot.value = [psi_dot,theta_dot,phi_dot];

% Compute Julian date for the interpolation points
jd_interval.value = juliandate(epoch);
jd_interval.unit = 'julian date';
jd_interval.description = 'Interpolation points for Environment.Moon.eul';

end

