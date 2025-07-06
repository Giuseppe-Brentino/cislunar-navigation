clearvars;
close all;
clc;

rng('default');

tic
res = sim('Simulator');
t = toc/60

%%
%%%%% POS
figure
hold on
grid on
subplot(2,3,1)
hold on
grid on
plot(res.errors.xm.Time/3600,res.errors.xm.Data(1,:))
plot(res.threeSigma.xm.Time/3600,[res.threeSigma.xm.Data(:,1),-res.threeSigma.xm.Data(:,1)],'r--')
xlabel('Time [h]')
ylabel('Main error x [km]')
subplot(2,3,2)
hold on
grid on
plot(res.errors.xm.Time/3600,res.errors.xm.Data(2,:))
plot(res.threeSigma.xm.Time/3600,[res.threeSigma.xm.Data(:,2),-res.threeSigma.xm.Data(:,2)],'r--')
xlabel('Time [h]')
ylabel('Main error y [km]')
subplot(2,3,3)
hold on
grid on
plot(res.errors.xm.Time/3600,res.errors.xm.Data(3,:))
plot(res.threeSigma.xm.Time/3600,[res.threeSigma.xm.Data(:,3),-res.threeSigma.xm.Data(:,3)],'r--')
xlabel('Time [h]')
ylabel('Main error z [km]')
subplot(2,3,4)
hold on
grid on
plot(res.errors.xb.Time/3600,res.errors.xb.Data(1,:))
plot(res.threeSigma.xb.Time/3600,[res.threeSigma.xb.Data(:,1),-res.threeSigma.xb.Data(:,1)],'r--')
xlabel('Time [h]')
ylabel('Beacon error x [km]')
subplot(2,3,5)
hold on
grid on
plot(res.errors.xb.Time/3600,res.errors.xb.Data(2,:))
plot(res.threeSigma.xb.Time/3600,[res.threeSigma.xb.Data(:,2),-res.threeSigma.xb.Data(:,2)],'r--')
xlabel('Time [h]')
ylabel('Beacon error y [km]')
subplot(2,3,6)
hold on
grid on
plot(res.errors.xb.Time/3600,res.errors.xb.Data(3,:))
plot(res.threeSigma.xb.Time/3600,[res.threeSigma.xb.Data(:,3),-res.threeSigma.xb.Data(:,3)],'r--')
xlabel('Time [h]')
ylabel('Beacon error z [km]')

%%%%% Vel
figure
hold on
grid on
subplot(2,3,1)
hold on
grid on
plot(res.errors.vm.Time/3600,res.errors.vm.Data(1,:))
plot(res.threeSigma.vm.Time/3600,[res.threeSigma.vm.Data(:,1),-res.threeSigma.vm.Data(:,1)],'r--')
xlabel('Time [h]')
ylabel('Main error x [km/s]')
subplot(2,3,2)
hold on
grid on
plot(res.errors.vm.Time/3600,res.errors.vm.Data(2,:))
plot(res.threeSigma.vm.Time/3600,[res.threeSigma.vm.Data(:,2),-res.threeSigma.vm.Data(:,2)],'r--')
xlabel('Time [h]')
ylabel('Main error y [km/s]')
subplot(2,3,3)
hold on
grid on
plot(res.errors.vm.Time/3600,res.errors.vm.Data(3,:))
plot(res.threeSigma.vm.Time/3600,[res.threeSigma.vm.Data(:,3),-res.threeSigma.vm.Data(:,3)],'r--')
xlabel('Time [h]')
ylabel('Main error z [km/s]')
subplot(2,3,4)
hold on
grid on
plot(res.errors.vb.Time/3600,res.errors.vb.Data(1,:))
plot(res.threeSigma.vb.Time/3600,[res.threeSigma.vb.Data(:,1),-res.threeSigma.vb.Data(:,1)],'r--')
xlabel('Time [h]')
ylabel('Beacon error x [km/s]')
subplot(2,3,5)
hold on
grid on
plot(res.errors.vb.Time/3600,res.errors.vb.Data(2,:))
plot(res.threeSigma.vb.Time/3600,[res.threeSigma.vb.Data(:,2),-res.threeSigma.vb.Data(:,2)],'r--')
xlabel('Time [h]')
ylabel('Beacon error y [km/s]')
subplot(2,3,6)
hold on
grid on
plot(res.errors.vb.Time/3600,res.errors.vb.Data(3,:))
plot(res.threeSigma.vb.Time/3600,[res.threeSigma.vb.Data(:,3),-res.threeSigma.vb.Data(:,3)],'r--')
xlabel('Time [h]')
ylabel('Beacon error z [km/s]')

%%% Clock
figure
subplot(3,1,1)
hold on
grid on
plot(res.errors.bias_clock.Time/3600,res.errors.bias_clock.Data)
plot(res.threeSigma.bias_clock.Time/3600,[res.threeSigma.bias_clock.Data(1,:);-res.threeSigma.bias_clock.Data(1,:)],'r--')
xlabel('Time [h]')
ylabel('Clock Bias error [km]')
ylim([-1 1])
subplot(3,1,2)
hold on
grid on
plot(res.errors.drift_clock.Time/3600,res.errors.drift_clock.Data)
plot(res.threeSigma.drift_clock.Time/3600,[res.threeSigma.drift_clock.Data(1,:);-res.threeSigma.drift_clock.Data(1,:)],'r--')
xlabel('Time [h]')
ylabel('Clock Bias error [km/s]')
ylim([-1e-3 1e-3])
subplot(3,1,3)
hold on
grid on
plot(res.errors.aging_clock.Time/3600,res.errors.aging_clock.Data)
plot(res.threeSigma.aging_clock.Time/3600,[res.threeSigma.aging_clock.Data(1,:);-res.threeSigma.aging_clock.Data(1,:)],'r--')
xlabel('Time [h]')
ylabel('Clock Aging error [km/s^2]')
ylim([-1e-10 1e-10])

%%% Gyro
figure
subplot(3,1,1)
hold on
grid on
plot(res.errors.bias_gyro.Time/3600,res.errors.bias_gyro.Data(1,:))
plot(res.threeSigma.bias_gyro.Time/3600,[res.threeSigma.bias_gyro.Data(:,1) -res.threeSigma.bias_gyro.Data(:,1)],'r--')
xlabel('Time [h]')
ylabel('Gyro Bias error x [rad]')
subplot(3,1,2)
hold on
grid on
plot(res.errors.bias_gyro.Time/3600,res.errors.bias_gyro.Data(2,:))
plot(res.threeSigma.bias_gyro.Time/3600,[res.threeSigma.bias_gyro.Data(:,2) -res.threeSigma.bias_gyro.Data(:,2)],'r--')
xlabel('Time [h]')
ylabel('Gyro Bias error y [rad]')
subplot(3,1,3)
hold on
grid on
plot(res.errors.bias_gyro.Time/3600,res.errors.bias_gyro.Data(3,:))
plot(res.threeSigma.bias_gyro.Time/3600,[res.threeSigma.bias_gyro.Data(:,3) -res.threeSigma.bias_gyro.Data(:,3)],'r--')
xlabel('Time [h]')
ylabel('Gyro Bias error z [rad]')

%%% Attitude
figure
subplot(3,1,1)
hold on
grid on
plot(res.errors.attitude.Time/3600,wrapToPi(res.errors.attitude.Data(:,1)))
plot(res.threeSigma.attitude.Time/3600,[res.threeSigma.attitude.Data(:,1) -res.threeSigma.attitude.Data(:,1)],'r--')
xlabel('Time [h]')
ylabel('Attitude error x [rad]')
subplot(3,1,2)
hold on
grid on
plot(res.errors.attitude.Time/3600,wrapToPi(res.errors.attitude.Data(:,2)))
plot(res.threeSigma.attitude.Time/3600,[res.threeSigma.attitude.Data(:,2) -res.threeSigma.attitude.Data(:,2)],'r--')
xlabel('Time [h]')
ylabel('Attitude error y [rad]')
subplot(3,1,3)
hold on
grid on
plot(res.errors.attitude.Time/3600,wrapToPi(res.errors.attitude.Data(:,3)))
plot(res.threeSigma.attitude.Time/3600,[res.threeSigma.attitude.Data(:,3) -res.threeSigma.attitude.Data(:,3)],'r--')
xlabel('Time [h]')
ylabel('Attitude error z [rad]')

%% NEES
res.NEES.Data = squeeze(res.NEES.Data);
ub = chi2inv(0.995,6);
lb = chi2inv(0.005,6);
figure;
grid on
h = scatterhist(res.NEES.Time/3600, res.NEES.Data, ...
    'Direction', 'out', ...
    'Location', 'SouthEast', ...
    'Kernel', 'on', ...
    'Marker', '.');
xlabel('Time');
ylabel('Value');
hold(h(1),"on")
plot([0,res.NEES.Time(end)/3600,nan,0,res.NEES.Time(end)/3600],[ub,ub,nan,lb,lb])
set(h(1), 'YAxisLocation', 'left');
hold(h(3), 'on');
yLims = ylim(h(3));
plot(h(3), [ub,ub,nan,lb,lb],[yLims,nan,yLims])
% delete(h(2))
legend(h(1),'Data','bounds')

NEES = length(res.NEES.Data(res.NEES.Data<=ub & res.NEES.Data>=lb))/...
    length(res.NEES.Data) * 100

%% NIS_ST
res.NIS_ST.Data = squeeze(res.NIS_ST.Data);
ub = chi2inv(0.995,3);
lb = chi2inv(0.005,3);
figure;
grid on
h = scatterhist(res.NIS_ST.Time/3600, res.NIS_ST.Data, ...
    'Direction', 'out', ...
    'Location', 'SouthEast', ...
    'Kernel', 'on', ...
    'Marker', '.');
xlabel('Time');
ylabel('Value');
hold(h(1),"on")
plot([0,res.NIS_ST.Time(end)/3600,nan,0,res.NIS_ST.Time(end)/3600],[ub,ub,nan,lb,lb])
set(h(1), 'YAxisLocation', 'left');
hold(h(3), 'on');
yLims = ylim(h(3));
plot(h(3), [ub,ub,nan,lb,lb],[yLims,nan,yLims])
% delete(h(2))
legend(h(1),'Data','bounds')

NIS = length(res.NIS_ST.Data(res.NIS_ST.Data<=ub & res.NIS_ST.Data>=lb))/...
    length(res.NIS_ST.Data) * 100


% save  '..\..\..\..\..\..\..\PROVE\15gg_acc_SRP.mat'  res -v7.3