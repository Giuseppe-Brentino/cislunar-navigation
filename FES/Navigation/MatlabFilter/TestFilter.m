clearvars;
close all;
clc;

%% Measurements from simulations
% data = load('testData.mat');

load bodiesPos.mat

rng('default')
data.out = sim('Simulator');
range.value = data.out.Radio.range_PN.Data;
range.time = data.out.Radio.range_PN.Time;
rangerate.value = data.out.Radio.range_rate.Data;
rangerate.time = data.out.Radio.range_rate.Time;

%% Filter parameters

params = getParameters('Navigation.sldd',{'x0','P0','Propagation','StartDate','Q'});

x0 = params{1}.value;
P0 = params{2}.value;
Propagation = params{3};
startDate = params{4};
Q = params{5}.value(1:6,1:6);
Q(4:6,4:6) =  Q(4:6,4:6)*1e1;
Q(1:3,1:3) =  Q(1:3,1:3)*5e2;
% STM_G = zeros(12,6);
% STM_G(4:6,1:3) = eye(3);
% STM_G(1:3,1:3) = diag(ones(3,1)/Propagation.lf.value);
% STM_G(7:12,4:6) = [diag(ones(3,1)/Propagation.lf.value);eye(3);];
% Q = (STM_G)*Q*(STM_G)' ./ Propagation.lf.value;
R = diag([(7e-3)^2 (4e-4)^2]);
%% Sim data
time = data.out.tout;
xm.value = squeeze(data.out.x_main.Data);
xm.time = squeeze(data.out.x_main.Time);
vm.value = squeeze(data.out.v_main.Data);
vm.time = squeeze(data.out.v_main.Time);
xb.value = squeeze(data.out.x_beacon.Data);
xb.time = squeeze(data.out.x_beacon.Time);
vb.value = squeeze(data.out.v_beacon.Data);
vb.time = squeeze(data.out.v_beacon.Time);
%% Filter IC
% time = time(time<=3600*24*6);
x_tot = zeros(12,floor(length(time)/6));
P_tot = zeros(12,12,floor(length(time)/6));
t_tot = zeros(1,floor(length(time)/6));

real_xm = zeros(3,floor(length(time)/6));
real_xb = zeros(3,floor(length(time)/6));
real_vm = zeros(3,floor(length(time)/6));
real_vb = zeros(3,floor(length(time)/6));
meas_range = zeros(1,floor(length(time)/2));
meas_rangeRate = zeros(1,floor(length(time)/6));
est_rangeRate = zeros(1,floor(length(time)/6));

x_tot(:,1) = x0([1:6 11:16]);
P_tot(:,:,1) = P0([1:6 10:15],[1:6 10:15]);
t_tot(:,1) = 0;
j = 1;
k = 1;

x = x_tot(:,1);
P = P_tot(:,:,1);

real_xm(:,1) = xm.value(:,1);
real_xb(:,1) = xb.value(:,1);
real_vm(:,1) = vm.value(:,1);
real_vb(:,1) = vb.value(:,1);
meas_range(1) = range.value(1);
meas_rangeRate(1) = rangerate.value(1);
est_rangeRate(1) = 0;
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
        real_vm(:,j) = vm.value(:,i);
        real_vb(:,j) = vb.value(:,i);
        meas_range(:,j) = range.value(i);
        meas_rangeRate(:,j) = rangerate.value(i);

        % Propagation step
        [x,P] = propagate(x,P,Propagation,Q,startDate,time(i-1));

        % Correction
        if range.value(i) ~= range.value(i-1) && rangerate.value(i) ~= rangerate.value(i-1)
             [x,P,s] = correctRadio(x,P,R,[range.value(i),rangerate.value(i)],Q);
             % S(:,:,j-1) = s;
        else
            if range.value(i) ~= range.value(i-1)
                [x,P,~] = correctRange(x,P,R(1,1),range.value(i),Q);
            end
            if rangerate.value(i) ~= rangerate.value(i-1)
                R = (2e-4)^2;
                [x,P,~] = correctRangeRate(x,P,R(2,2),rangerate.value(i),Q);
            end
        end

        est_rangeRate(j) = (x(1:3)-x(7:9))'*(x(4:6)-x(10:12)) / norm(x(1:3)-x(7:9));
        
        x_tot(:,j) = x;
        P_tot(:,:,j) = P;
        t_tot(:,j) = time(i);
    end

end
%%% Plots

main_cov_x = zeros(size(P_tot,3),3);
beacon_cov_x = zeros(size(P_tot,3),3);
main_cov_v = zeros(size(P_tot,3),3);
beacon_cov_v = zeros(size(P_tot,3),3);
for i=1:size(P_tot,3)
    main_cov_x(i,:) = 3*sqrt(diag(P_tot(1:3,1:3,i)));
    beacon_cov_x(i,:) = 3*sqrt(diag(P_tot(7:9,7:9,i)));
    main_cov_v(i,:) = 3*sqrt(diag(P_tot(4:6,4:6,i)));
    beacon_cov_v(i,:) = 3*sqrt(diag(P_tot(10:12,10:12,i)));
end

%%%%% POS
figure
hold on
grid on
subplot(2,3,1)
hold on
grid on
plot(t_tot/3600,x_tot(1,:)-real_xm(1,:))
plot(t_tot/3600,[main_cov_x(:,1),-main_cov_x(:,1)],'r--')
xlabel('Time [h]')
ylabel('Main error x [km]')
subplot(2,3,2)
hold on
grid on
plot(t_tot/3600,x_tot(2,:)-real_xm(2,:))
plot(t_tot/3600,[main_cov_x(:,2),-main_cov_x(:,2)],'r--')
xlabel('Time [h]')
ylabel('Main error y [km]')
subplot(2,3,3)
hold on
grid on
plot(t_tot/3600,x_tot(3,:)-real_xm(3,:))
plot(t_tot/3600,[main_cov_x(:,3),-main_cov_x(:,3)],'r--')
xlabel('Time [h]')
ylabel('Main error z [km]')
subplot(2,3,4)
hold on
grid on
plot(t_tot/3600,x_tot(7,:)-real_xb(1,:))
plot(t_tot/3600,[beacon_cov_x(:,1),-beacon_cov_x(:,1)],'r--')
xlabel('Time [h]')
ylabel('Beacon error x [km]')
subplot(2,3,5)
hold on
grid on
plot(t_tot/3600,x_tot(8,:)-real_xb(2,:))
plot(t_tot/3600,[beacon_cov_x(:,2),-beacon_cov_x(:,2)],'r--')
xlabel('Time [h]')
ylabel('Beacon error y [km]')
subplot(2,3,6)
hold on
grid on
plot(t_tot/3600,x_tot(9,:)-real_xb(3,:))
plot(t_tot/3600,[beacon_cov_x(:,3),-beacon_cov_x(:,3)],'r--')
xlabel('Time [h]')
ylabel('Beacon error z [km]')
% savefig(gcf,'..\..\..\..\..\..\..\PROVE\test1POS.fig')
%%%%% VEL
figure
hold on
grid on
subplot(2,3,1)
hold on
grid on
plot(t_tot/3600,(x_tot(4,:)-real_vm(1,:))*1000)
plot(t_tot/3600,[main_cov_v(:,1),-main_cov_v(:,1)]*1000,'r--')
xlabel('Time [h]')
ylabel('Main error x [m/s]')
subplot(2,3,2)
hold on
grid on
plot(t_tot/3600,(x_tot(5,:)-real_vm(2,:))*1000)
plot(t_tot/3600,[main_cov_v(:,2),-main_cov_v(:,2)]*1000,'r--')
xlabel('Time [h]')
ylabel('Main error y [m/s]')
subplot(2,3,3)
hold on
grid on
plot(t_tot/3600,(x_tot(6,:)-real_vm(3,:))*1000)
plot(t_tot/3600,[main_cov_v(:,3),-main_cov_v(:,3)]*1000,'r--')
xlabel('Time [h]')
ylabel('Main error z [m/s]')
subplot(2,3,4)
hold on
grid on
plot(t_tot/3600,(x_tot(10,:)-real_vb(1,:))*1000)
plot(t_tot/3600,[beacon_cov_v(:,1),-beacon_cov_v(:,1)]*1000,'r--')
xlabel('Time [h]')
ylabel('Beacon error x [m/s]')
subplot(2,3,5)
hold on
grid on
plot(t_tot/3600,(x_tot(11,:)-real_vb(2,:))*1000)
plot(t_tot/3600,[beacon_cov_v(:,2),-beacon_cov_v(:,2)]*1000,'r--')
xlabel('Time [h]')
ylabel('Beacon error y [m/s]')
subplot(2,3,6)
hold on
grid on
plot(t_tot/3600,(x_tot(12,:)-real_vb(3,:))*1000)
plot(t_tot/3600,[beacon_cov_v(:,3),-beacon_cov_v(:,3)]*1000,'r--')
xlabel('Time [h]')
ylabel('Beacon error z [m/s]')
% savefig(gcf,'..\..\..\..\..\..\..\PROVE\test1VEL.fig')


est_meas = vecnorm(x_tot(1:3,2:50:end)-x_tot(7:9,2:50:end),2,1)*1e3-meas_range(2:50:end);
real_meas = vecnorm(real_xm(:,2:50:end)-real_xb(:,2:50:end),2,1)*1e3-meas_range(2:50:end);
figure
hold on
grid on
plot(t_tot(2:50:end)/(3600),est_meas,'b.')
plot(t_tot(2:50:end)/3600,real_meas,'r.')
legend('Est minus Measured range', 'Real minus Measured range')
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
% 
save '..\..\..\..\..\..\..\PROVE\test_I_OM0_20gg.mat' t_tot x_tot real_xm real_xb...
    real_vm real_vb main_cov_x beacon_cov_x main_cov_v ...
beacon_cov_v  %time range rangerate
