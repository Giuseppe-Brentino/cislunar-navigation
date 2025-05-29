function dx = odefun(t,x,SH,Propagation,date,x_e,x_s,MPA)

% time
jd = time2JD(date,t);
julian_centuries = (jd-2451545)/36525;

% Earth Position
% x_e_parts = Propagation.Earth.amp.value.*sin(Propagation.Earth.phase.value + ...
%     julian_centuries.*Propagation.Earth.freq.value);
% x_e = sum(x_e_parts,2);

% y = date.year;
% m = date.month;
% d = date.day;
% h = date.hour;
% min = date.min;
% s = date.sec+t;
% startDate = datetime(y,m,d,h,min,s);
% et =  cspice_str2et( char(startDate ) );
% [xx,~] = cspice_spkezr('EARTH', et, 'J2000', 'NONE', 'MOON');
% x_e = xx(1:3);
% 
% % Sun position
% [xx,~] = cspice_spkezr('SUN', et, 'J2000', 'NONE', 'EARTH');
% x_s =xx(1:3);
% x_s =x_e + approxSun(jd);

mu_s = 1.32712440018e+11; %km^3/s^2

% Moon orientation
% moon_angles = Propagation.Moon.eul0.value + t*Propagation.Moon.eul_dot.value;
% MPA = angle2dcm(moon_angles(3),moon_angles(2),moon_angles(1),"ZXZ");
%% SC gravity

% Beacon
gm_beacon = -Propagation.Moon.mu.value*x(7:9)/norm(x(7:9))^3;
ge_beacon = -Propagation.Earth.mu.value*(x_e/norm(x_e)^3 + (x(7:9)-x_e)/norm(x(7:9)-x_e)^3 );
gs_beacon =0;%-mu_s*(x_s/norm(x_s)^3 + (x(7:9)-x_s)/norm(x(7:9)-x_s)^3 );

% Main
x_rot = MPA*x(1:3);
[gm_rot, ~] = SH.getDerivative(x_rot);
gm_main = MPA'*gm_rot;
ge_main = -Propagation.Earth.mu.value*(x_e/norm(x_e)^3 + (x(1:3)-x_e)/norm(x(1:3)-x_e)^3 );
gs_main =0;% -mu_s*(x_s/norm(x_s)^3 + (x(1:3)-x_s)/norm(x(1:3)-x_s)^3 );

dx(1:3) = x(4:6);
dx(4:6) = gm_main + ge_main + gs_main;
dx(7:9) = x(10:12);
dx(10:12) = gm_beacon + ge_beacon + gs_beacon;

dx = dx';
end

function jd = time2JD(date,time)
Y   = date.year;
M   = date.month;
D   = date.day;
hrs = date.hour;
mn  = date.min;
sec = date.sec+time;

fracday = (hrs + (mn + sec/60)/60) / 24;
% Formula converting Gregorian date into JD
jd = 367*Y - floor(7*(Y+floor((M+9)/12))/4) ...
    - floor(3*floor((Y+(M-9)/7)/100+1)/4) ...
    + floor(275*M/9) ...
    + D + 1721028.5 +fracday;
end
