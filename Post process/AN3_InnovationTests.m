classdef AN3_InnovationTests < PostProcess
    % Compute the Normalized Innovation Squared and the Normalized
    % Mean Innovation Errors


    methods
        function obj = AN3_InnovationTests(varargin)
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

            % Get NIS
            aNIS = data_file.aNIS;

            % Get time
            time = data_file.time;

            % Get NMI
            aNMI = data_file.aNMI;

            % Get number of simulations
            Nsim = length(data_file.est_errors);

            % NIS st data
            ub_st = chi2inv(0.975,3.*aNIS.st.N)./aNIS.st.N; % 3 scalar meas
            lb_st = chi2inv(0.025,3.*aNIS.st.N)./aNIS.st.N;

            NIS_st_noNaN = aNIS.st.Data(~isnan(aNIS.st.Data));
            ub_st_noNaN = ub_st(~isnan(ub_st));
            lb_st_noNaN = lb_st(~isnan(lb_st));

            NIS_st_within = length(NIS_st_noNaN(NIS_st_noNaN<=ub_st_noNaN &...
                NIS_st_noNaN>=lb_st_noNaN ))/length(NIS_st_noNaN) * 100;
            NIS_st_belowMax = length(NIS_st_noNaN(NIS_st_noNaN<=ub_st_noNaN))/...
                length(NIS_st_noNaN) * 100;
            NIS_st_aboveMin = length(NIS_st_noNaN(NIS_st_noNaN>=lb_st_noNaN))/...
                length(NIS_st_noNaN) * 100;

            % NIS radio data
            ub_radio = chi2inv(0.975,2.*aNIS.radio.N)./aNIS.radio.N; % 2 scalar meas
            lb_radio = chi2inv(0.025,2.*aNIS.radio.N)./aNIS.radio.N;

            NIS_radio_noNaN = aNIS.radio.Data(~isnan(aNIS.radio.Data));
            ub_radio_noNaN = ub_radio(~isnan(ub_radio));
            lb_radio_noNaN = lb_radio(~isnan(lb_radio));

            NIS_radio_within = length(NIS_radio_noNaN(NIS_radio_noNaN<=ub_radio_noNaN &...
                NIS_radio_noNaN>=lb_radio_noNaN ))/length(NIS_radio_noNaN) * 100;
            NIS_radio_belowMax = length(NIS_radio_noNaN(NIS_radio_noNaN<=ub_radio_noNaN))/...
                length(NIS_radio_noNaN) * 100;
            NIS_radio_aboveMin = length(NIS_radio_noNaN(NIS_radio_noNaN>=lb_radio_noNaN))/...
                length(NIS_radio_noNaN) * 100;

            % NMI data
            NMI_target_std = 1/Nsim;
            NMI_mean = mean([aNMI.st.Data;aNMI.radio.Data],2,'omitnan');
            NMI_std = std([aNMI.st.Data;aNMI.radio.Data],0,2,'omitnan');

            %% Plots

            % Plot NIS Star tracker

            x_data = {{time/3600}};
            y_data = {{aNIS.st.Data}};

            % remove nan for plot
            ub_plot = {{obj.fillForward(ub_st)}};
            lb_plot = {{obj.fillForward(lb_st)}};

            names = {{'NIS star Tracker','Bounds'}};
            obj.plot_scatterHist('x_data',x_data,'y_data',y_data,'ub',ub_plot,...
                'lb',lb_plot,'label_x',{{'Time [h]'}},'label_y',{{'NIS'}},...
                'names',names,'hist_bounds',false)

            % Plot NIS Radio
                        x_data = {{time/3600}};
            y_data = {{aNIS.radio.Data}};
            % remove nan for plot
            ub_plot = {{obj.fillForward(ub_radio)}};
            lb_plot = {{obj.fillForward(lb_radio)}};
            names = {{'NIS radio','Bounds'}};

            obj.plot_scatterHist('x_data',x_data,'y_data',y_data,'ub',ub_plot,...
                'lb',lb_plot,'label_x',{{'Time [h]'}},'label_y',{{'NIS'}},...
                'names',names,'hist_bounds',false);

            % Plot NMI st
            data = {{aNMI.st.Data(1,:)},{aNMI.st.Data(2,:)},{aNMI.st.Data(3,:)}};
            label_x = {{'x angle'},{'y angle'},{'z angle'}};
            obj.plot_histogram('data',data,'sub_cols',3,'sub_rows',1,'Nbins',20,...
                'fit_curve','Normal','label_x',label_x)

            % Plot NMI radio
            data = {{aNMI.radio.Data(1,:)},{aNMI.radio.Data(2,:)}};
            label_x = {{'range'},{'range rate'},};
            obj.plot_histogram('data',data,'sub_cols',2,'sub_rows',1,'Nbins',20,...
                'fit_curve','Normal','label_x',label_x)

            %% Write text file
            dataPath = data_file.Properties.Source;

            [folder_name, ~, ~] = fileparts(dataPath);
            % Open file
            fid = fopen(string(folder_name)+filesep+"InnovationTests.txt", 'w');
            % Write file
            fprintf(fid, 'NIS ST within bounds: %.2f %% \n',NIS_st_within);
            fprintf(fid, 'NIS ST above lower bound (not optimistic cases): %.2f %% \n',NIS_st_aboveMin);
            fprintf(fid, 'NIS ST below upper bound (not pessimistic cases): %.2f %% \n\n',NIS_st_belowMax);
            fprintf(fid, 'NIS radio within bounds: %.2f %% \n',...
                NIS_radio_within);
            fprintf(fid, 'NIS radio above lower bound (not optimistic cases): %.2f %% \n',...
                NIS_radio_aboveMin);
            fprintf(fid, 'NIS radio below upper bound (not pessimistic cases): %.2f %% \n\n',...
                NIS_radio_belowMax);
            fprintf(fid,'\n\n\n');
            fprintf(fid, 'NMI mean values: ');
            fprintf(fid, '%e ', NMI_mean);
            fprintf(fid, '\n');
            fprintf(fid, 'NMI std values: ');
            fprintf(fid, '%e ', NMI_std);
            fprintf(fid, '\n');
            fprintf(fid, 'NMI target std: %.4f \n',NMI_target_std);
            Close file
            fclose(fid);
        end

        function B = fillForward(obj, A)
            % fillForward - Forward-fill NaNs with the previous valid value.
            % Leading NaNs remain NaN.
            %
            % Example:
            %   A = [NaN NaN 1 NaN 2 NaN 4];
            %   B = fillForward(A);
            %   % B => [NaN NaN 1 1 2 2 4]

            % Make sure A is a vector
            if ~isvector(A)
                error('Input must be a vector.');
            end

            % Initialize index map
            idxMap = NaN(size(A));

            % Mark valid positions with their index
            idxMap(~isnan(A)) = find(~isnan(A));

            % Fill missing indices forward
            idxMap = fillmissing(idxMap, 'previous');

            % Initialize output as input
            B = A;

            % Overwrite valid positions with forward-filled values
            B(~isnan(idxMap)) = A(idxMap(~isnan(idxMap)));
        end


    end
end

