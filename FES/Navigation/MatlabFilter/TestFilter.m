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
Q(4:6,4:6) =  Q(4:6,4:6);
Q(1:3,1:3) =  Q(1:3,1:3);
%% Measurements from simulations
data = load('testData.mat');
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

real_xm(:,1) = xm.value(:,1);
real_xb(:,1) = xb.value(:,1);

for i = 2:length(time)

    if mod(time(i),1/Propagation.lf.value) == 0
        j = j+1;

        %
        real_xm(:,j) = xm.value(:,i);
        real_xb(:,j) = xb.value(:,i);

        % Propagation step

        [x,P] = propagate(x,P,Propagation,Q,startDate,time(i-1));

        % Correction
        % % % if range.value(i) ~= range.value(i-1) && rangerate.value(i) ~= rangerate.value(i-1)
        % % %     R = diag([(5e-3)^2 (2e-5)^2]);
        % % %     [x,P] = correctRadio(x,P,R,[range.value(i),rangerate.value(i)]);
        % % % else
            % if range.value(i) ~= range.value(i-1)
            %     R = (5e-3)^2;
            %     [x,P] = correctRange(x,P,R,range.value(i));
            % end
            if rangerate.value(i) ~= rangerate.value(i-1)
                R = (5e-6)^2;
                [x,P] = correctRangeRate(x,P,R,rangerate.value(i));
            end
        % % % end

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
plot(t_tot,vecnorm(x_tot(1:3,:)-real_xm,2,1),'b')
plot(t_tot,vecnorm(x_tot(7:9,:)-real_xb,2,1),'r')
plot(t_tot,3*[main_cov -main_cov],'k')
plot(t_tot,3*[beacon_cov -beacon_cov],'g')
legend ('Position error sc1','Position error sc2','Position sc1 3\sigma','',...
    'Position sc2 3\sigma')
ylim([-50 50])
xlabel('Time [s]')
ylabel('Position error [km]')