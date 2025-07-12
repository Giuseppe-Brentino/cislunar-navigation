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

            % Get NMEE
            aNMEE = data_file.aNMEE;

            % Get number of simulations
            Nsim = length(data_file.est_errors);

            % 95% bounds
            ub = chi2inv(0.975,21*Nsim)/Nsim; % 21 states
            lb = chi2inv(0.025,21*Nsim)/Nsim;

            %% NEES data
            NEES_within = length(aNEES(aNEES<=ub & aNEES>=lb ))/length(aNEES) * 100;
            NEES_belowMax = length(aNEES(aNEES<=ub))/length(aNEES) * 100;
            NEES_aboveMin = length(aNEES(aNEES>=ub))/length(aNEES) * 100;

            %% NMEE data
            NMEE_target_std = 1/Nsim;
            NMEE_mean = mean(aNMEE,2);
            NMEE_std = std(aNMEE,0,2);

            %% Plots

            % Plot NEES
            x_data = {{time/3600}};
            y_data = {{aNEES}};
            ub_plot = {{repmat(ub,length(time),1)}};
            lb_plot = {{repmat(lb,length(time),1)}};
            names = {{'NEES','Bounds'}};
            obj.plot_scatterHist('x_data',x_data,'y_data',y_data,'ub',ub_plot,...
                'lb',lb_plot,'label_x',{{'Time [h]'}},'label_y',{{'NEES'}},'names',names)

            % Plot NMEE pos vel main spacecraft
            data = {{aNMEE(1,:)},{aNMEE(2,:)},{aNMEE(3,:)},{aNMEE(4,:)},{aNMEE(5,:)},{aNMEE(6,:)}};
            label_x = {{'x position'},{'y position'},{'z position'},...
                {'x velocity'},{'y velocity'},{'z velocity'}};
            obj.plot_histogram('data',data,'sub_cols',3,'sub_rows',2,'Nbins',20,...
                'fit_curve','Normal','label_x',label_x)

            % Plot NMEE pos vel beacon spacecraft
            data = {{aNMEE(10,:)},{aNMEE(11,:)},{aNMEE(12,:)},{aNMEE(13,:)},...
                {aNMEE(14,:)},{aNMEE(15,:)}};
            label_x = {{'x position'},{'y position'},{'z position'},...
                {'x velocity'},{'y velocity'},{'z velocity'}};
            obj.plot_histogram('data',data,'sub_cols',3,'sub_rows',2,'Nbins',20,...
                'fit_curve','Normal','label_x',label_x)

            % Plot NMEE attitude params
            data = {{aNMEE(7,:)},{aNMEE(8,:)},{aNMEE(9,:)},{aNMEE(16,:)},...
                {aNMEE(17,:)},{aNMEE(18,:)}};
            label_x = {{'x attitude'},{'y attitude'},{'z attitude'},...
                {'x gyroscope bias'},{'y gyroscope bias'},{'z gyroscope bias'}};
            obj.plot_histogram('data',data,'sub_cols',3,'sub_rows',2,'Nbins',20,...
                'fit_curve','Normal','label_x',label_x)

            % Plot NMEE clock params
            data = {{aNMEE(19,:)},{aNMEE(20,:)},{aNMEE(21,:)}};
            label_x = {{'Clock bias'},{'Clock drift'},{'Clock aging'}};
            obj.plot_histogram('data',data,'sub_cols',3,'sub_rows',1,'Nbins',20,...
                'fit_curve','Normal','label_x',label_x)

            %% Write text file
            dataPath = data_file.Properties.Source;

            [folder_name, ~, ~] = fileparts(dataPath);
            % Open file
            fid = fopen(string(folder_name)+filesep+"EstimationTests.txt", 'w');
            % Write file
            fprintf(fid, 'NEES within bounds: %.2f %% \n',NEES_within);
            fprintf(fid, 'NEES above lower bound (not optimistic cases): %.2f %% \n',NEES_aboveMin);
            fprintf(fid, 'NEES below upper bound (not pessimistic cases): %.2f %% \n',NEES_belowMax);
            fprintf(fid,'\n\n\n');
            fprintf(fid, 'NMEE mean values: ');
            fprintf(fid, '%e ', NMEE_mean);
            fprintf(fid, '\n');
            fprintf(fid, 'NMEE std values: ');
            fprintf(fid, '%e ', NMEE_std);
            fprintf(fid, '\n');
            fprintf(fid, 'NMEE target std: %.4f \n',NMEE_target_std);
            % Close file
            fclose(fid);
        end

    end
end

