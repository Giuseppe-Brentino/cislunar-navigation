classdef AN1_EstimationErrors < PostProcess
    % Plot the estimation errors during the simulations together with their
    % average and 3sigma values

    methods

        function obj = AN1_EstimationErrors(varargin)
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

            errors = obj.data_file.est_errors;

            % Compute 3 sigma and average values of the estimated errors
            [average.xm, three_sigma.xm] = obj.get_stoch_params(cat(3, errors.xm));
            [average.vm, three_sigma.vm] = obj.get_stoch_params(cat(3, errors.vm));
            [average.attitude, three_sigma.attitude] = obj.get_stoch_params...
                (cat(3, errors.attitude));
            [average.xb, three_sigma.xb] = obj.get_stoch_params(cat(3, errors.xb));
            [average.vb, three_sigma.vb] = obj.get_stoch_params(cat(3, errors.vb));
            [average.bias_gyro, three_sigma.bias_gyro] = obj.get_stoch_params...
                (cat(3, errors.bias_gyro));
            [average.bias_clock, three_sigma.bias_clock] = obj.get_stoch_params...
                (cat(3, errors.bias_clock));
            [average.drift_clock, three_sigma.drift_clock] = obj.get_stoch_params...
                (cat(3, errors.drift_clock));
            [average.aging_clock, three_sigma.aging_clock] = obj.get_stoch_params...
                (cat(3, errors.aging_clock));

            %% PLOTS

            % Plot Main SC Data
            x_data = repmat({repmat({errors(1).Time/3600},4,1)},6,1);
            y_data = x_data;
            label_x = repmat({'Time [h]'},6,1);
            label_y = {'X error [km]','Y error [km]','Z error [km]',...
                'X error [km/s]','Y error [km/s]','Z error [km/s]'};
            legend = repmat({{'Errors','Average error','+3\sigma','-3/sigma'}},6,1);
            
            obj.plot_2D('x_data',x_data,'y_data',y_data,'label_x',label_x,...
                'label_y',label_y,'sub_cols',3,'sub_rows',2,'names',legend);
        end

        function [mean_val, three_sigma] = get_stoch_params(obj,data)

            % Reshape data as (simulation, time, variable)
            organized_data = permute(data,[3 2 1]);

            % Compute the mean and standard deviation of the estimated errors at each
            % timestep
            n = size(data,1);

            three_sigma = zeros(n,size(data,2));
            mean_val = zeros(n,size(data,2));

            for i = 1:n
                three_sigma(i,:) = 3*std(organized_data(:,:,i),0,1);
                mean_val(i,:) = mean(organized_data(:,:,i),1);
            end

        end

    end
end

