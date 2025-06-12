clearvars;
close all;
clc;

rng('default');
data = sim('Simulator');


%%
%%%%% POS
figure
hold on
grid on
subplot(2,3,1)
hold on
grid on
plot(data.errors.xm.Time/3600,data.errors.xm.Data(1,:))
plot(data.threeSigma.xm.Time/3600,[data.threeSigma.xm.Data(:,1),-data.threeSigma.xm.Data(:,1)],'r--')
xlabel('Time [h]')
ylabel('Main error x [km]')
subplot(2,3,2)
hold on
grid on
plot(data.errors.xm.Time/3600,data.errors.xm.Data(2,:))
plot(data.threeSigma.xm.Time/3600,[data.threeSigma.xm.Data(:,2),-data.threeSigma.xm.Data(:,2)],'r--')
xlabel('Time [h]')
ylabel('Main error y [km]')
subplot(2,3,3)
hold on
grid on
plot(data.errors.xm.Time/3600,data.errors.xm.Data(3,:))
plot(data.threeSigma.xm.Time/3600,[data.threeSigma.xm.Data(:,3),-data.threeSigma.xm.Data(:,3)],'r--')
xlabel('Time [h]')
ylabel('Main error z [km]')
subplot(2,3,4)
hold on
grid on
plot(data.errors.xb.Time/3600,data.errors.xb.Data(1,:))
plot(data.threeSigma.xb.Time/3600,[data.threeSigma.xb.Data(:,1),-data.threeSigma.xb.Data(:,1)],'r--')
xlabel('Time [h]')
ylabel('Beacon error x [km]')
subplot(2,3,5)
hold on
grid on
plot(data.errors.xb.Time/3600,data.errors.xb.Data(2,:))
plot(data.threeSigma.xb.Time/3600,[data.threeSigma.xb.Data(:,2),-data.threeSigma.xb.Data(:,2)],'r--')
xlabel('Time [h]')
ylabel('Beacon error y [km]')
subplot(2,3,6)
hold on
grid on
plot(data.errors.xb.Time/3600,data.errors.xb.Data(3,:))
plot(data.threeSigma.xb.Time/3600,[data.threeSigma.xb.Data(:,3),-data.threeSigma.xb.Data(:,3)],'r--')
xlabel('Time [h]')
ylabel('Beacon error z [km]')

%%%%% Vel
figure
hold on
grid on
subplot(2,3,1)
hold on
grid on
plot(data.errors.vm.Time/3600,data.errors.vm.Data(1,:))
plot(data.threeSigma.vm.Time/3600,[data.threeSigma.vm.Data(:,1),-data.threeSigma.vm.Data(:,1)],'r--')
xlabel('Time [h]')
ylabel('Main error x [m/s]')
subplot(2,3,2)
hold on
grid on
plot(data.errors.vm.Time/3600,data.errors.vm.Data(2,:))
plot(data.threeSigma.vm.Time/3600,[data.threeSigma.vm.Data(:,2),-data.threeSigma.vm.Data(:,2)],'r--')
xlabel('Time [h]')
ylabel('Main error y [m/s]')
subplot(2,3,3)
hold on
grid on
plot(data.errors.vm.Time/3600,data.errors.vm.Data(3,:))
plot(data.threeSigma.vm.Time/3600,[data.threeSigma.vm.Data(:,3),-data.threeSigma.vm.Data(:,3)],'r--')
xlabel('Time [h]')
ylabel('Main error z [m/s]')
subplot(2,3,4)
hold on
grid on
plot(data.errors.vb.Time/3600,data.errors.vb.Data(1,:))
plot(data.threeSigma.vb.Time/3600,[data.threeSigma.vb.Data(:,1),-data.threeSigma.vb.Data(:,1)],'r--')
xlabel('Time [h]')
ylabel('Beacon error x [m/s]')
subplot(2,3,5)
hold on
grid on
plot(data.errors.vb.Time/3600,data.errors.vb.Data(2,:))
plot(data.threeSigma.vb.Time/3600,[data.threeSigma.vb.Data(:,2),-data.threeSigma.vb.Data(:,2)],'r--')
xlabel('Time [h]')
ylabel('Beacon error y [m/s]')
subplot(2,3,6)
hold on
grid on
plot(data.errors.vb.Time/3600,data.errors.vb.Data(3,:))
plot(data.threeSigma.vb.Time/3600,[data.threeSigma.vb.Data(:,3),-data.threeSigma.vb.Data(:,3)],'r--')
xlabel('Time [h]')
ylabel('Beacon error z [m/s]')

%%% Clock
figure
subplot(2,1,1)
hold on
grid on
plot(data.errors.bias_clock.Time/3600,data.errors.bias_clock.Data)
plot(data.threeSigma.bias_clock.Time/3600,[data.threeSigma.bias_clock.Data(1,:);-data.threeSigma.bias_clock.Data(1,:)],'r--')
xlabel('Time [h]')
ylabel('Clock Bias error [km]')
ylim([-1 1])
subplot(2,1,2)
hold on
grid on
plot(data.errors.drift_clock.Time/3600,data.errors.drift_clock.Data)
plot(data.threeSigma.drift_clock.Time/3600,[data.threeSigma.drift_clock.Data(1,:);-data.threeSigma.drift_clock.Data(1,:)],'r--')
xlabel('Time [h]')
ylabel('Clock Bias error [km/s]')
ylim([-1e-3 1e-3])

% save  '..\..\..\..\..\..\..\PROVE\test_I_cBiasDrift2.mat'  data