function [eul, eul_dot, jd_interval] = moonOrientation(date, time)


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

y = date.year;
m = date.month;
d = date.day;
h = date.hour;
min = date.min;
s = date.sec;
startDate = datetime(y,m,d,h,min,s);
endDate = startDate + seconds(time);
epoch = startDate:minutes(1):endDate;
dates =  cspice_str2et( char(epoch ) );

rotate = cspice_sxform( 'J2000', 'MOON_PA', dates );

eul.type = "ZXZ";
eul.value = rotm2eul(rotate(1:3,1:3,:),eul.type);
eul.unit = 'rad';
eul.description = 'ZXZ rotation angles from J2000 to MOON_PA';
eul_dot.unit = 'rad/s';
eul_dot.description = 'Time derivative of the ZXZ rotation angles from J2000 to MOON_PA';

% Compute derivative from the derivative of the rotation matrix:
% It's easy because sine and cosine of second and third rotation angles are
% never zero
rot_dot = rotate(4:6,1:3,:);
sin_psi = sin(eul.value(:,1));
cos_psi = cos(eul.value(:,1));
sin_theta = sin(eul.value(:,2));
cos_theta = cos(eul.value(:,2));
sin_phi = sin(eul.value(:,3));
cos_phi = cos(eul.value(:,3));

theta_dot = squeeze(-rot_dot(end,end,:))./sin_theta;

phi_dot = (squeeze(rot_dot(3,1,:)) - cos_theta.*sin_phi.*theta_dot)./(sin_theta.*cos_phi);

psi_dot = (squeeze(rot_dot(1,1,:)) - theta_dot.*sin_psi.*sin_theta.*sin_phi + ...
    (cos_psi.*sin_phi + sin_psi.*cos_phi.*cos_theta).*phi_dot) ./ ...
    ( -sin_psi.*cos_phi -cos_psi.*cos_theta.*sin_phi );

eul_dot.value = [psi_dot,theta_dot,phi_dot];

% save julian date
jd_interval.value = juliandate(epoch);
jd_interval.unit = 'julian date';
jd_interval.description = 'Interpolation points for Environment.Moon.eul';
end

