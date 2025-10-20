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
            NEES_aboveMin = length(aNEES(aNEES>=lb))/length(aNEES) * 100;

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
            title = 'AN2_NEES';
            WHratio = 1.5;
            percTextWidth = 0.7;
            obj.plot_scatterHist('x_data',x_data,'y_data',y_data,'ub',ub_plot,...
                'lb',lb_plot,'label_x',{{'Time [h]'}},'label_y',{{'NEES'}},...
                'names',names,'title',title,'WHratio',WHratio,...
                'percTextWidth',percTextWidth);

            % Plot NMEE pos vel main spacecraft
            data = {{aNMEE(1,:)},{aNMEE(2,:)},{aNMEE(3,:)},{aNMEE(4,:)},{aNMEE(5,:)},{aNMEE(6,:)}};
            label_x = {{'x position'},{'y position'},{'z position'},...
                {'x velocity'},{'y velocity'},{'z velocity'}};
             title = 'AN2_MainDist';
            WHratio = 1.8;
            percTextWidth = 0.8;
            obj.plot_histogram('data',data,'sub_cols',3,'sub_rows',2,'Nbins',20,...
                'fit_curve','Normal','label_x',label_x,'title',title,'WHratio',...
                WHratio,'percTextWidth',percTextWidth)

            % Plot NMEE evolution pos vel main spacecraft
            x_data = repmat({cat(1,{time(1:100:end)/3600})},6,1);
            y_data = {{aNMEE(1,1:100:end)},{aNMEE(2,1:100:end)},{aNMEE(3,1:100:end)},...
                {aNMEE(4,1:100:end)},{aNMEE(5,1:100:end)},{aNMEE(6,1:100:end)}};
            label_y = {{'x position'},{'y position'},{'z position'},...
                {'x velocity'},{'y velocity'},{'z velocity'}};
            label_x = repmat({'Time [h]'},6,1);
             title = 'AN2_MainTime';
            WHratio = 1.8;
            percTextWidth = 0.8;
            obj.plot_2D('x_data',x_data,'y_data',y_data,'sub_cols',3,'sub_rows',2,...
                'label_x',label_x,'label_y',label_y,'title',title,'WHratio',...
                WHratio,'percTextWidth',percTextWidth)

            % Plot NMEE pos vel beacon spacecraft
            data = {{aNMEE(10,:)},{aNMEE(11,:)},{aNMEE(12,:)},{aNMEE(13,:)},...
                {aNMEE(14,:)},{aNMEE(15,:)}};
            label_x = {{'x position'},{'y position'},{'z position'},...
                {'x velocity'},{'y velocity'},{'z velocity'}};
             title = 'AN2_BeaconDist';
            WHratio = 1.8;
            percTextWidth = 0.8;
            obj.plot_histogram('data',data,'sub_cols',3,'sub_rows',2,'Nbins',20,...
                'fit_curve','Normal','label_x',label_x,'title',title,'WHratio',...
                WHratio,'percTextWidth',percTextWidth)

            % Plot NMEE attitude params
            data = {{aNMEE(7,:)},{aNMEE(8,:)},{aNMEE(9,:)},{aNMEE(16,:)},...
                {aNMEE(17,:)},{aNMEE(18,:)}};
            label_x = {{'x attitude'},{'y attitude'},{'z attitude'},...
                {'x gyroscope bias'},{'y gyroscope bias'},{'z gyroscope bias'}};
            title = 'AN2_AttitudeDist';
            WHratio = 1.8;
            percTextWidth = 0.8;
            obj.plot_histogram('data',data,'sub_cols',3,'sub_rows',2,'Nbins',20,...
                'fit_curve','Normal','label_x',label_x,'title',title,'WHratio',...
                WHratio,'percTextWidth',percTextWidth)

            % Plot NMEE clock params
            data = {{aNMEE(19,:)},{aNMEE(20,:)},{aNMEE(21,:)}};
            label_x = {{'Clock bias'},{'Clock drift'},{'Clock aging'}};
            title = 'AN2_ClockDist';
            WHratio = 2;
            percTextWidth = 0.8;
            obj.plot_histogram('data',data,'sub_cols',3,'sub_rows',1,'Nbins',20,...
                'fit_curve','Normal','label_x',label_x,'title',title,'WHratio',...
                WHratio,'percTextWidth',percTextWidth)


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

