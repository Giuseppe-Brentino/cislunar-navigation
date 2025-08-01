clearvars -except data Q_original;
close all;
clc;

val = Q_original.value;
val(1:3,1:3)= Q_original.value(1:3,1:3)/10;
val(4:6,4:6)= Q_original.value(4:6,4:6)/100;
pn = getParameters('Navigation.sldd',{'Q'});
Q = pn{1};
Q.value = val;
updateParameters('Navigation.sldd',{'Q'},{Q},true);
rng('default');

tic
res = sim('Simulator');
t = toc/60
% save  '..\..\..\..\..\..\..\15gg2_DATA.mat'  res -v7.3

%%
%%%%% POS
figure
hold on
grid on
subplot(2,3,1)
hold on
grid on
plot(res.errors.xm.Time/3600,res.errors.xm.Data(1,:))
plot(res.threeSigma.xm.Time/3600,[res.threeSigma.xm.Data(1,:);-res.threeSigma.xm.Data(1,:)],'r--')
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
ylim([-3 3])
subplot(3,1,2)
hold on
grid on
plot(res.errors.drift_clock.Time/3600,res.errors.drift_clock.Data)
plot(res.threeSigma.drift_clock.Time/3600,[res.threeSigma.drift_clock.Data(1,:);-res.threeSigma.drift_clock.Data(1,:)],'r--')
xlabel('Time [h]')
ylabel('Clock Bias error [km/s]')
ylim([-1e-2 1e-2])
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
ub = chi2inv(0.975,21);
lb = chi2inv(0.025,21);

NEES_perc = length(res.NEES.Data(res.NEES.Data<=ub & res.NEES.Data>=lb ))/...
    length(res.NEES.Data) * 100;

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
xlim([0,res.NEES.Time(end)/3600])
yLims = ylim(h(1));
xLims = xlim(h(1));
text(0.01,yLims(2)-2,num2str(NEES_perc)+"% inside the 95% bounds")
hold(h(3), 'on');
yLims = ylim(h(3));
plot(h(3), [ub,ub,nan,lb,lb],[yLims,nan,yLims])
delete(h(2))
legend(h(1),'Data','bounds')

%% NMEE
NMEE = squeeze(res.NMEE.Data);

figure
sgtitle('clock')
subplot(1,3,1)
hold on
grid on
histfit(NMEE(19,:),20,'Normal')
xline(mean(NMEE(19,:)),'r-','LineWidth',2.5)
xline(std(NMEE(19,:)),'k-','LineWidth',2.5)
subplot(1,3,2)
hold on
grid on
histfit(NMEE(20,:),20,'Normal')
xline(mean(NMEE(20,:)),'r-','LineWidth',2.5)
xline(std(NMEE(20,:)),'k-','LineWidth',2.5)
subplot(1,3,3)
hold on
grid on
histfit(NMEE(21,:),20,'Normal')
xline(mean(NMEE(21,:)),'r-','LineWidth',2.5)
xline(std(NMEE(21,:)),'k-','LineWidth',2.5)

figure
sgtitle('Main SC pos vel')
subplot(2,3,1)
hold on
grid on
histfit(NMEE(1,:),20,'Normal')
xline(mean(NMEE(1,:)),'r-','LineWidth',2.5)
xline(std(NMEE(1,:)),'k-','LineWidth',2.5)
subplot(2,3,2)
hold on
grid on
histfit(NMEE(2,:),20,'Normal')
xline(mean(NMEE(2,:)),'r-','LineWidth',2.5)
xline(std(NMEE(2,:)),'k-','LineWidth',2.5)
subplot(2,3,3)
hold on
grid on
histfit(NMEE(3,:),20,'Normal')
xline(mean(NMEE(3,:)),'r-','LineWidth',2.5)
xline(std(NMEE(3,:)),'k-','LineWidth',2.5)

subplot(2,3,4)
hold on
grid on
histfit(NMEE(4,:),20,'Normal')
xline(mean(NMEE(4,:)),'r-','LineWidth',2.5)
xline(std(NMEE(4,:)),'k-','LineWidth',2.5)
subplot(2,3,5)
hold on
grid on
histfit(NMEE(5,:),20,'Normal')
xline(mean(NMEE(5,:)),'r-','LineWidth',2.5)
xline(std(NMEE(5,:)),'k-','LineWidth',2.5)
subplot(2,3,6)
hold on
grid on
histfit(NMEE(6,:),20,'Normal')
xline(mean(NMEE(6,:)),'r-','LineWidth',2.5)
xline(std(NMEE(6,:)),'k-','LineWidth',2.5)

%% NIS 
NIS_ST.Time = res.NIS_ST.Time(res.NIS_ST_flag.Data);
NIS_ST.Data = squeeze(res.NIS_ST.Data(res.NIS_ST_flag.Data));
ub = chi2inv(0.975,3);
lb = chi2inv(0.025,3);
NIS_ST_perc = length(NIS_ST.Data(NIS_ST.Data<=ub & NIS_ST.Data>=lb ))/...
    length(NIS_ST.Data) * 100;

figure;
grid on
h = scatterhist(NIS_ST.Time/3600, NIS_ST.Data, ...
    'Direction', 'out', ...
    'Location', 'SouthEast', ...
    'Kernel', 'on', ...
    'Marker', '.');
xlabel('Time');
ylabel('Value');
hold(h(1),"on")
plot([0,NIS_ST.Time(end)/3600,nan,0,NIS_ST.Time(end)/3600],[ub,ub,nan,lb,lb])
set(h(1), 'YAxisLocation', 'left');
xlim([0,NIS_ST.Time(end)/3600])
yLims = ylim(h(1));
text(0.01,yLims(2)-2,num2str(NIS_ST_perc)+"% inside the 95% bounds")
hold(h(3), 'on');
yLims = ylim(h(3));
plot(h(3), [ub,ub,nan,lb,lb],[yLims,nan,yLims])
delete(h(2))
legend(h(1),'Data','bounds')

NIS_Radio.Time = res.NIS_Radio.Time(res.NIS_Radio_flag.Data);
NIS_Radio.Data = squeeze(res.NIS_Radio.Data(res.NIS_Radio_flag.Data));
ub = chi2inv(0.975,2);
lb = chi2inv(0.025,2);
NIS_Radio_perc = length(NIS_Radio.Data(NIS_Radio.Data<=ub & NIS_Radio.Data>=lb ))/...
    length(NIS_Radio.Data) * 100;

figure;
grid on
h = scatterhist(NIS_Radio.Time/3600, NIS_Radio.Data, ...
    'Direction', 'out', ...
    'Location', 'SouthEast', ...
    'Kernel', 'on', ...
    'Marker', '.');
xlabel('Time');
ylabel('Value');
hold(h(1),"on")
plot([0,NIS_Radio.Time(end)/3600,nan,0,NIS_Radio.Time(end)/3600],[ub,ub,nan,lb,lb])
set(h(1), 'YAxisLocation', 'left');
xlim([0,NIS_Radio.Time(end)/3600])
yLims = ylim(h(1));
xLims = xlim(h(1));
text(0.01,yLims(2)-2,num2str(NIS_Radio_perc)+"% inside the 95% bounds")
hold(h(3), 'on');
yLims = ylim(h(3));
plot(h(3), [ub,ub,nan,lb,lb],[yLims,nan,yLims])
delete(h(2))
legend(h(1),'Data','bounds')


save  '..\..\..\..\..\..\..\PROVE\15gg_NEES_Rconst.mat'  res -v7.3