classdef AN1_EstimationErrors < PostProcess
    % Plot the estimation errors during the simulations together with their
    % RMSE and 3sigma values

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
            uncertainties = obj.data_file.est_three_sigma;

            % Reshape data as ([sim nan sim ecc..], variable)
            xm_reshaped = squeeze(reshape(permute(cat(2,...
                permute(cat(3,errors.xm),[3 2 1]),...
                nan*ones(length(errors),1,3)),[2 1 3]),[],1,3));
            vm_reshaped = squeeze(reshape(permute(cat(2,...
                permute(cat(3,errors.vm),[3 2 1]),...
                nan*ones(length(errors),1,3)),[2 1 3]),[],1,3));
            xb_reshaped = squeeze(reshape(permute(cat(2,...
                permute(cat(3,errors.xb),[3 2 1]),...
                nan*ones(length(errors),1,3)),[2 1 3]),[],1,3));
            vb_reshaped = squeeze(reshape(permute(cat(2,...
                permute(cat(3,errors.vb),[3 2 1]),...
                nan*ones(length(errors),1,3)),[2 1 3]),[],1,3));
            attitude_reshaped = squeeze(reshape(permute(cat(2,...
                permute(cat(3,errors.attitude),[3 2 1]),...
                nan*ones(length(errors),1,3)),[2 1 3]),[],1,3));
            bias_g_reshaped = squeeze(reshape(permute(cat(2,...
                permute(cat(3,errors.bias_gyro),[3 2 1]),...
                nan*ones(length(errors),1,3)),[2 1 3]),[],1,3));
            bias_c_reshaped = squeeze(reshape(permute(cat(2,...
                permute(cat(3,errors.bias_clock),[3 2 1]),...
                nan*ones(length(errors),1,1)),[2 1 3]),[],1));
            drift_c_reshaped = squeeze(reshape(permute(cat(2,...
                permute(cat(3,errors.drift_clock),[3 2 1]),...
                nan*ones(length(errors),1,1)),[2 1 3]),[],1));
            aging_c_reshaped = squeeze(reshape(permute(cat(2,...
                permute(cat(3,errors.aging_clock),[3 2 1]),...
                nan*ones(length(errors),1,1)),[2 1 3]),[],1));


            % Compute 3 sigma and RMSE values of the estimated errors
            [average.xm, RMSE.xm, real_3sigma.xm, est_3sigma.xm] =...
                obj.get_stoch_params(cat(3, errors.xm), cat(3, uncertainties.xm));
            [average.vm, RMSE.vm, real_3sigma.vm, est_3sigma.vm] =...
                obj.get_stoch_params(cat(3, errors.vm), cat(3, uncertainties.vm));

            %% PLOTS
            % Tranform matrix into single vector separated by NaNs for
            % better plots
            time_reshaped = [errors(1).Time' nan];
            for i = 2:length(errors)
                time_reshaped = [time_reshaped errors(i).Time' nan];
            end

            % Plot Main SC Data
            x_data = repmat({cat(1,{time_reshaped./3600},{errors(1).Time./3600},...
                {[errors(1).Time./3600;nan;errors(1).Time./3600]},...
                {[errors(1).Time./3600;nan;errors(1).Time./3600]})},6,1);
            y_data = { {xm_reshaped(:,1),RMSE.xm(1,:),[est_3sigma.xm(1,:) nan -est_3sigma.xm(1,:)],...
                [average.xm(1,:)+real_3sigma.xm(1,:) nan average.xm(1,:)-real_3sigma.xm(1,:)]}...
                {xm_reshaped(:,2),RMSE.xm(2,:),[est_3sigma.xm(2,:) nan -est_3sigma.xm(2,:)],...
                [average.xm(2,:)+real_3sigma.xm(2,:),nan,average.xm(2,:)-real_3sigma.xm(2,:)]}...
                {xm_reshaped(:,3),RMSE.xm(3,:),[est_3sigma.xm(3,:) nan -est_3sigma.xm(3,:)],...
                [average.xm(3,:)+real_3sigma.xm(3,:),nan,average.xm(3,:)-real_3sigma.xm(3,:)]}...
                {vm_reshaped(:,1),RMSE.vm(1,:),[est_3sigma.vm(1,:) nan -est_3sigma.vm(1,:)],...
                [average.vm(1,:)+real_3sigma.vm(1,:),nan,average.vm(1,:)-real_3sigma.vm(1,:)]}...
                {vm_reshaped(:,2),RMSE.vm(2,:),[est_3sigma.vm(2,:) nan -est_3sigma.vm(2,:)],...
                [average.vm(2,:)+real_3sigma.vm(2,:),nan,average.vm(2,:)-real_3sigma.vm(2,:)]}...
                {vm_reshaped(:,3),RMSE.vm(3,:),[est_3sigma.vm(3,:) nan -est_3sigma.vm(3,:)],...
                [average.vm(3,:)+real_3sigma.vm(3,:),nan,average.vm(3,:)-real_3sigma.vm(3,:)]}...
                };

            label_x = repmat({'Time [h]'},6,1);
            label_y = {'X error [km]','Y error [km]','Z error [km]',...
                'X error [km/s]','Y error [km/s]','Z error [km/s]'};
            legend = repmat({{'Errors','RMSE','est 3\sigma','real 3\sigma'}},6,1);

            obj.plot_2D('x_data',x_data,'y_data',y_data,'label_x',label_x,...
                'label_y',label_y,'sub_cols',3,'sub_rows',2,'names',legend);
        end

        function [mean_val, rmse, real_3sigma, est_3sigma] = get_stoch_params(obj,err,unc)

            % Reshape data as (simulation, time, variable)
            organized_err = permute(err,[3 2 1]);
            organized_unc = permute(unc,[3 2 1]);

            % Compute the mean and standard deviation of the estimated errors at each
            % timestep
            n = size(err,1);

            real_3sigma = zeros(n,size(unc,2));
            est_3sigma = zeros(n,size(unc,2));
            rmse = zeros(n,size(err,2));
            mean_val = zeros(n,size(err,2));

            for i = 1:n
                real_3sigma(i,:) = 3*std(organized_err(:,:,i),0,1);
                mean_val(i,:) = mean(organized_err(:,:,i),1);
                rmse(i,:) = sqrt(sum(organized_err(:,:,i).^2,1)/size(err,3));
                est_3sigma(i,:) =  mean(organized_unc(:,:,i),1);
            end

        end

    end
end

