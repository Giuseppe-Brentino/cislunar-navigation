function [fitresult, gof] = createFit(range, sigma)
%CREATEFIT(RANGE,SIGMA)


%% Fit: 'untitled fit 1'.
[xData, yData] = prepareCurveData( range, sigma );

% Set up fittype and options.
ft = fittype( 'exp2' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Algorithm = 'Levenberg-Marquardt';
opts.DiffMaxChange = 1;
opts.DiffMinChange = 1e-09;
opts.Display = 'Off';
opts.Robust = 'Bisquare';
opts.StartPoint = [8.60311656566261 5.82026753942128e-09 -8.51385651411488 3.50719233710702e-10];

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );




