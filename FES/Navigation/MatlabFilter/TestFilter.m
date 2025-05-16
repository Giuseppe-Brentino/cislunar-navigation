clearvars;
close all;
clc;
%% Filter parameters

params = getParameters('Navigation.sldd',{'x0','P0','Propagation','StartDate','Q'});

x0 = params{1}.value;
P0 = params{2}.value;
Propagation = params{3};
startDate = params{4};
Q = params{5}.value;

%% Measurements from simulations
data = load('testData.mat');
range.value = data.out.Radio.range_PN.Data;
range.time = data.out.Radio.range_PN.Time;

%% Sim data
time = data.out.tout;
xm.value = squeeze(data.out.x_main.Data);
xm.time = squeeze(data.out.x_main.Time);
xb.value = squeeze(data.out.x_beacon.Data);
xb.time = squeeze(data.out.x_beacon.Time);
%% Filter
x_tot = zeros(12,floor(length(time)/(Propagation.hf.value/Propagation.lf.value)));
P_tot = zeros(12,12,floor(length(time)/(Propagation.hf.value/Propagation.lf.value)));
t_tot = zeros(1,floor(length(time)/(Propagation.hf.value/Propagation.lf.value)));

x_tot(:,1) = x0([1:6 11:16]);
P_tot(:,:,1) = P0([1:6 10:15],[1:6 10:15]);
t_tot(:,1) = 0;
j = 1;
k = 1;

x = x_tot(:,1);
P = P_tot(:,:,1);
for i = 2:length(time)
   
    if mod(time(i),1/Propagation.lf.value) == 0
        j = j+1;

        %
        real_xm(:,j) = xm.value(:,i);
        real_xb(:,j) = xb.value(:,i);
        % Propagation step
        [x,P] = propagate(x,P,Propagation,Q(1:6,1:6),startDate,time(i-1));

        % Correction step
        if range.value(i) ~= range.value(i-1)
            R = (2e-3)^2;
            [x,P] = correctRange(x,P,R,range.value(i));

            meas_est(k) = range.value(i)*1e-3 - norm(x(1:3) - x(7:9));
            meas_real(k) = range.value(i)*1e-3 - norm(xm.value(:,i) - xb.value(:,i));
            est_real(k) = norm(x(1:3) - x(7:9)) - norm(xm.value(:,i) - xb.value(:,i));
            ty(k) = time(i);
            k = k+1;
        end

    end
    
    x_tot(:,j) = x;
    P_tot(:,:,j) = P;
    t_tot(:,j) = time(i);

end
%%
 
figure
hold on
grid on
plot(ty,meas_est)
% plot(ty,meas_real)
plot(ty,-est_real)
legend('meas-est', 'meas-real', 'est-real')


figure
hold on
grid on
plot(t_tot,x_tot(1,:)-real_xm(1,:),'b')
plot(t_tot,x_tot(7,:)-real_xb(1,:),'r')
legend ('error xm','','', 'error xb')
ylim([-100 300])