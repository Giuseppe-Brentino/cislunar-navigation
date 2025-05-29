function [x,P] = propagate(x_prev,P_prev,Propagation,Q,date,time)

%% planetary data

% time
jd = time2JD(date,time);
julian_centuries = (jd-2451545)/36525;

% Earth Position
% x_e_parts = Propagation.Earth.amp.value.*sin(Propagation.Earth.phase.value + ...
%     julian_centuries.*Propagation.Earth.freq.value);
% x_e = sum(x_e_parts,2);

y = date.year;
m = date.month;
d = date.day;
h = date.hour;
min = date.min;
s = date.sec+time;
startDate = datetime(y,m,d,h,min,s);
et =  cspice_str2et( char(startDate ) );
[xx,~] = cspice_spkezr('EARTH', et, 'J2000', 'NONE', 'MOON');
x_e = xx(1:3);
%%
% Sun position

% [xx,~] = cspice_spkezr('SUN', et, 'J2000', 'NONE', 'MOON');
% x_s =xx(1:3);
% x_s =x_e + approxSun(jd);


% mu_s = 1.32712440018e+11; %km^3/s^2

% Moon orientation
moon_angles = Propagation.Moon.eul0.value + time*Propagation.Moon.eul_dot.value;
MPA = angle2dcm(moon_angles(3),moon_angles(2),moon_angles(1),"ZXZ");

%% SC gravity

% Beacon
% % % gm_beacon = -Propagation.Moon.mu.value*x_prev(7:9)/norm(x_prev(7:9))^3;
% % % ge_beacon = -Propagation.Earth.mu.value*(x_e/norm(x_e)^3 + (x_prev(7:9)-x_e)/norm(x_prev(7:9)-x_e)^3 );

% Main
SH = SH_nav;

SH.body_coeffs = Propagation.Moon.SH;
SH.mu = Propagation.Moon.mu.value;
SH.ref_radius = Propagation.Moon.radius.value;
SH.nMax = Propagation.Moon.SH.n.value;
SH.mMax = Propagation.Moon.SH.m.value;

x_rot = MPA*x_prev(1:3);
[~, dgdx_rot] = SH.getDerivative(x_rot);

dgdx = MPA'*dgdx_rot*MPA;

% % % gm_main = MPA'*gm_rot;
% % % ge_main = -Propagation.Earth.mu.value*(x_e/norm(x_e)^3 + (x_prev(1:3)-x_e)/norm(x_prev(1:3)-x_e)^3 );


 [~, x] = ode4(@odefun, [time time+0.2],x_prev,SH,Propagation,date,x_e,[],MPA);
x=x(end,:)';

% %% Update velocities
% x = zeros(12,1);
% 
% x(4:6) = x_prev(4:6) + (gm_main+ge_main)/Propagation.lf.value;
% x(10:12) = x_prev(10:12) + (gm_beacon+ge_beacon)/Propagation.lf.value;
% 
% %% Update positions
% x(1:3) = x_prev(1:3) + 0.5*(x(4:6)+x_prev(4:6))/Propagation.lf.value;
% x(7:9) = x_prev(7:9) + 0.5*(x(10:12)+x_prev(10:12))/Propagation.lf.value;

%% STM
STM = zeros(12);

STM(1:3,4:6) = eye(3);

STM(7:9,10:12) = eye(3);

dgE_dx = Propagation.Earth.mu.value * (3*(x_prev(1:3)-x_e)*(x_prev(1:3)-x_e)'...
    /norm(x_prev(1:3)-x_e)^5 - eye(3)./norm(x_prev(1:3)-x_e)^3);
% dgS_dx = mu_s * (3*(x_prev(1:3)-x_s)*(x_prev(1:3)-x_s)'...
%     /norm(x_prev(1:3)-x_s)^5 - eye(3)./norm(x_prev(1:3)-x_s)^3);

STM(4:6,1:3) = dgdx + dgE_dx;% + dgS_dx;

dgE_dx = Propagation.Earth.mu.value * (3*(x_prev(1:3)-x_e)*(x_prev(1:3)-x_e)'...
    /norm(x_prev(1:3)-x_e)^5 - eye(3)./norm(x_prev(1:3)-x_e)^3);
% dgS_dx = mu_s * (3*(x_prev(1:3)-x_s)*(x_prev(1:3)-x_s)'...
%     /norm(x_prev(1:3)-x_s)^5 - eye(3)./norm(x_prev(1:3)-x_s)^3);
dg2b_dx = Propagation.Moon.mu.value * (3*(x_prev(7:9))*(x_prev(7:9))'...
    /norm(x_prev(7:9))^5 - eye(3)./norm(x_prev(7:9))^3);

STM(10:12,7:9) = dg2b_dx + dgE_dx;% + dgS_dx;

STM = eye(12) + STM/Propagation.lf.value;

%% G
G = zeros(12,6);
G(4:6,1:3) = eye(3);
G(10:12,4:6) = eye(3);

PN = (STM*G)*Q*(STM*G)' ./ Propagation.lf.value;

%% Cov matrix
P = STM*P_prev*STM' + PN;
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