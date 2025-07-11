classdef AN2_EstimationTests < PostProcess
    % Compute the Normalized Estimation Error Squared and the Normalized
    % Mean Estimation Errors
    
    methods
        function obj = AN2_EstimationTests(varargin)

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

            % Get NEES
            aNEES = data_file.aNEES;
            time = data_file.time;

            % Get number of simulations
            Nsim = length(data_file.est_errors);
            % 95% bounds
            
            ub = chi2inv(0.975,21*Nsim)/Nsim; % 21 states
            lb = chi2inv(0.025,21*Nsim)/Nsim;

            %% Plots

            % Plot NEES
            x_data = {{time/3600}};
            y_data = {{aNEES}};
            ub_plot = {{repmat(ub,length(time),1)}};
            lb_plot = {{repmat(lb,length(time),1)}};
            names = {{'NEES','Bounds'}};
            obj.plot_scatterHist('x_data',x_data,'y_data',y_data,'ub',ub_plot,...
                'lb',lb_plot,'label_x',{{'Time [h]'}},'label_y',{{'NEES'}},'names',names)
        end
       
    end
end

