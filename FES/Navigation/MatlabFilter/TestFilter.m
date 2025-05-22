clearvars;
close all;
clc;
%% Filter parameters

params = getParameters('Navigation.sldd',{'x0','P0','Propagation','StartDate','Q'});

x0 = params{1}.value;
P0 = params{2}.value;
Propagation = params{3};
startDate = params{4};
Q = params{5}.value(1:6,1:6);
Q(4:6,4:6) =  Q(4:6,4:6)*10;
Q(1:3,1:3) =  Q(1:3,1:3)*1000;
%% Measurements from simulations
% data = load('testData3.mat');
data.out = sim('Simulator');
range.value = data.out.Radio.range_PN.Data;
range.time = data.out.Radio.range_PN.Time;
rangerate.value = data.out.Radio.range_rate.Data;
rangerate.time = data.out.Radio.range_rate.Time;
%% Sim data
time = data.out.tout;
xm.value = squeeze(data.out.x_main.Data);
xm.time = squeeze(data.out.x_main.Time);
xb.value = squeeze(data.out.x_beacon.Data);
xb.time = squeeze(data.out.x_beacon.Time);
%% Filter IC
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

real_xm(:,1) = xm.value(:,1);
real_xb(:,1) = xb.value(:,1);
meas_range(:,1) = range.value(1);
meas_rangeRate(:,1) = rangerate.value(1);
est_rangeRate(:,1) = 0;
%% SPICE
% Get the full path of the current function file
currentFile = mfilename('fullpath');
% Get the folder containing the function
folder = fileparts(currentFile);

cspice_furnsh(strcat(folder,'\..\..\Data\naif0012.tls'));
cspice_furnsh(strcat(folder,'\..\..\Data\de421.bsp'));
%% FILTER
for i = 2:length(time)

    if mod(time(i),1/Propagation.lf.value) == 0
        j = j+1;

        %
        real_xm(:,j) = xm.value(:,i);
        real_xb(:,j) = xb.value(:,i);
        meas_range(:,j) = range.value(i);
        meas_rangeRate(:,j) = rangerate.value(i);
              % Propagation step

        [x,P] = propagate(x,P,Propagation,Q,startDate,time(i-1));

        % Correction
        if range.value(i) ~= range.value(i-1) && rangerate.value(i) ~= rangerate.value(i-1)
            R = diag([(5e-3)^2 (2e-4)^2]);
            [x,P] = correctRadio(x,P,R,[range.value(i),rangerate.value(i)]);
        else
            if range.value(i) ~= range.value(i-1)
                R = (5e-3)^2;
                [x,P] = correctRange(x,P,R,range.value(i));
            end
            if rangerate.value(i) ~= rangerate.value(i-1)
                R = (2e-4)^2;
                [x,P] = correctRangeRate(x,P,R,rangerate.value(i));
            end
        end
        est_rangeRate(j) = (x(1:3)-x(7:9))'*(x(4:6)-x(10:12)) / norm(x(1:3)-x(7:9));
        x_tot(:,j) = x;
        P_tot(:,:,j) = P;
        t_tot(:,j) = time(i);
    end



end
%% Plots

main_cov = zeros(size(P_tot,3),1);
beacon_cov = zeros(size(P_tot,3),1);
for i=1:size(P_tot,3)
    main_cov(i) = 3*norm(diag(P_tot(1:3,1:3,i)));
    beacon_cov(i) = 3*norm(diag(P_tot(7:9,7:9,i)));
end

figure
hold on
grid on
plot(t_tot/3600,vecnorm(x_tot(1:3,:)-real_xm,2,1),'b')
plot(t_tot/3600,vecnorm(x_tot(7:9,:)-real_xb,2,1),'r')
plot(t_tot/3600,3*[main_cov -main_cov],'k')
plot(t_tot/3600,3*[beacon_cov -beacon_cov],'g')
legend ('Position error sc1','Position error sc2','Position sc1 3\sigma','',...
    'Position sc2 3\sigma')
ylim([-200 200])
xlabel('Time [h]')
ylabel('Position error [km]')

est_meas = vecnorm(x_tot(1:3,2:50:end)-x_tot(7:9,2:50:end),2,1)*1e3-meas_range(2:50:end);
real_meas = vecnorm(real_xm(:,2:50:end)-real_xb(:,2:50:end),2,1)*1e3-meas_range(2:50:end);
figure
hold on
grid on
% plot(t_tot(2:50:end)/(3600),est_meas,'b.')
plot(t_tot(2:50:end)/3600,real_meas,'r.')
legend('Real minus Measured range', 'Real minus Measured range')
ylabel('m')
xlabel('h')
ylim([-30 30])

figure
hold on
grid on
plot(t_tot(2:50:end)/(3600),est_rangeRate(2:50:end)*1e3-meas_rangeRate(2:50:end),'b.')
legend('Estimated minus Measured range rate')
ylabel('m/s')
xlabel('h')
