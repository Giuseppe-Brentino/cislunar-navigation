classdef AN4_NoiseAnalysis < PostProcess
    % Analysis of the noise characteristics of the innovations and the
    % errors

    properties
        Property1
    end

    methods
        function obj = AN4_NoiseAnalysis(varargin)
            % Get data
            if isempty(varargin)
                [name,path] = uigetfile;
                data = strcat(path,name);
                data_file = matfile(data);
            else
                data_file = varargin{1};
            end

            % Initialize parent class
            obj = obj@PostProcess(data_file);



            %% Auto correlation

            % Get Data
            st_inn = obj.data_file.st_innovation;
            radio_inn = obj.data_file.radio_innovation;

            % Compute average autocorrelation
            [st_time, st_acorr] = compute_autocorrelation(obj,st_inn);
            [radio_time, radio_acorr] = compute_autocorrelation(obj,radio_inn);

            %% FFT

            % Get Data
            full_sim_data = data_file.full_error;
            fft_time = full_sim_data.Time;
            fft_xm = full_sim_data.xm';

            % Compute fft
            [freq, mag] = compute_fft(obj,fft_time,fft_xm);

            %% Plots

            % Autocorrelation st
            x_data = {repmat({st_time/3600},3,1)};
            y_data = {{st_acorr(1,:),st_acorr(2,:),st_acorr(3,:)}};
            obj.plot_2D('x_data',x_data,'y_data',y_data,'label_x',{'Time [h]'},...
                'label_y',{'auto correlation'},'names',{{'meas 1','meas 2','meas 3'}},...
                'isscatter',true);

            % Autocorrelation radio
            x_data = {repmat({radio_time/3600},2,1)};
            y_data = {{radio_acorr(2,:),radio_acorr(1,:)}};
            obj.plot_2D('x_data',x_data,'y_data',y_data,'label_x',{'Time [h]'},...
                'label_y',{'auto correlation'},'names',{{'range rate','range'}},...
                'isscatter',true);

            % FFT
            x_data = {repmat({freq},3,1)};
            y_data = {{mag(:,1),mag(:,2),mag(:,3)}};
            obj.plot_2D('x_data',x_data,'y_data',y_data,'label_x',{'Frequency [Hz]'},...
                'label_y',{'Magnitude'},'names',{{'$e_x$ main spacecraft',...
                '$e_y$ main spacecraft','$e_z$ main spacecraft'}});
        end

        function [time, auto_corr] = compute_autocorrelation(obj,data)

            % Create time vector
            time_nan = [data.time];
            time_full = time_nan(~isnan(time_nan));
            time = unique(time_full);

            % Create data matrix % DA CAPIRE, DATA_NAN è SBAGLIATO
            data_matrix=[data.data];
            data_nan = reshape(data_matrix,size(data_matrix,1),[],length(data));

            acorr_matrix = data_nan;
            % Analyze each term of the innovation vector
            for i = 1:size(data_nan,1)
                % Analyze each simulation
                for j = 1:size(data_nan,3)
                    idx = find(~isnan(data_nan(i,:,j)));
                    [temp_acorr, lags] = xcorr(data_nan(i,idx,j), 'coeff');
                    temp_acorr = temp_acorr(lags>=0);
                    acorr_matrix(i,idx,j)= temp_acorr;
                end
            end

            % average the autocorrelation over the simulations
            auto_corr_nan = squeeze(mean(acorr_matrix,3,"omitnan"));
            auto_corr = reshape(auto_corr_nan(~isnan(auto_corr_nan)),size(data_nan,1),[]);
        end

        function [freq, mag] = compute_fft(obj,t,x)
            % Check sampling info
            dt = t(2)-t(1);     % sampling interval
            Fs = 1/dt;          % sampling frequency
            N = size(x,1);      % number of samples

            % Compute FFT
            X = fft(x);
            % Take only positive frequencies
            mag = abs(X) / N;
            mag = mag(1:floor(N/2)+1,:);
            mag(2:end-1,:) = 2*mag(2:end-1,:); % correct for single-sided spectrum

            % Frequency axis
            freq = Fs*(0:floor(N/2))/N;
        end

    end
end

