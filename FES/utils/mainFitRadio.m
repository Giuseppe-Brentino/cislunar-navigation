close all;
clearvars;
clc;

model = sim("provaTuningRadio.slx");
range = model.range;
sigma_DLL = model.sigma_DLL;
sigma_PLL = model.sigma_PLL;
% [fit_DLL, ~] = createFit(range, sigma_DLL)
% [fit_PLL, ~] = createFit(range, sigma_PLL)
% save fit_Radio fit_DLL fit_PLL

figure
hold on
grid on
plot(range/1000,sigma_DLL)
xlabel('Range [km]')
ylabel('$1\sigma$ noise [m]')
xlim([0 1.5e5])
exportStandardizedFigure(gcf,'PN_noise',0.6, 'addMarkers', false, ...
         'WHratio', 1.5,'overwriteFigure',true)