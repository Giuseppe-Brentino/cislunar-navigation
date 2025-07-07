close all;
clearvars;
clc;

model = sim("provaTuningRadio.slx");
range = model.range;
sigma_DLL = model.sigma_DLL;
sigma_PLL = model.sigma_PLL;
[fit_DLL, ~] = createFit(range, sigma_DLL)
[fit_PLL, ~] = createFit(range, sigma_PLL)
save fit_Radio fit_DLL fit_PLL