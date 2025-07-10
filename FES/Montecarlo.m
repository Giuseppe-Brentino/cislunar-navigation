close all;
clearvars;
clc;

rng('default')

%% Define number of workers

% Find number of workers available
delete(gcp('nocreate'))
temp_pool = parpool;
max_poolsize = temp_pool.NumWorkers;

% Close parpool
delete(temp_pool)

% Start parpool with the right amount of workers
poolsize = max(4,max_poolsize-1);
parpool(poolsize);

%% Define number of simulations and batches

N_sim = 4;
N_remaining = N_sim;
N_batches = ceil(N_sim/poolsize);

%% Downsampling coefficient

decimation = 5; %save one sample every 5 for some of the parameters

%% Inizialize mat file

% Get current date
current_date = datetime;
current_date.Format = 'yyyy_MM_dd_HHmmss';

% Initialize data stricture
emptyStruct = struct;

% Create data file
file_path = "../Simulations results/montecarloRun_"+string(current_date)+".mat";
save(file_path,'-struct', 'emptyStruct', '-mat', '-v7.3');

% Create mat file object
data_file = matfile(file_path, "Writable", true);

%% Run simulations

load_system('Simulator.slx')

for i = 1:N_batches

    try
        run_size = size(data_file,'est_errors');
    catch ME
        if strcmp(ME.identifier, 'MATLAB:MatFile:VariableNotInFile')
            run_size = 0;
        else
            rethrow(ME);
        end
    end
    run_size = max(run_size)+1;

    batch_size = min(N_remaining, poolsize);

    % Initialize simulation objects
    simIn(1:batch_size) = Simulink.SimulationInput('Simulator');

    % Run simulations
    simulation = parsim(simIn,UseFastRestart="on");

    % Update number of remaining simulations
    N_remaining = N_remaining-batch_size;

    %%% Save data
    for j = 1:batch_size

        % Estimation error
        data_file.est_errors(run_size+j-1,1) = saveRawData(simulation(j).errors, decimation);

        if N_remaining == 0 && j == batch_size % Save the full error for the last simulation
            decimation = 1;
            data_file.full_error = saveRawData(simulation(j).errors, decimation);
        end

        % Estimated 3 sigma boundaries
        data_file.est_three_sigma(run_size+j-1,1) = saveRawData(simulation(j).threeSigma, decimation);

        % ST innovation
        data_file.st_innovation(run_size+j-1,1) = saveInnovation ...
            (simulation(j).innovation_ST,simulation(j).NIS_ST_flag.Data);

        % Radio innovation
        data_file.radio_innovation(run_size+j-1,1) = saveInnovation ...
            (simulation(j).innovation_Radio,simulation(j).NIS_Radio_flag.Data);

        % Normalized Estimation Error Squared
        if isfield(data_file,'aNEES')
            data_file.aNEES = data_file.NEES + simulation(j).NEES.Data;
        else
            data_file.aNEES = simulation(j).NEES.Data;
        end

        % Normalized Mean Estimation Error
        if isfield(data_file,'aNMEE')
            data_file.aNMEE = data_file.aNMEE + simulation(j).aNMEE.Data;
        else
            data_file.aNMEE = simulation(j).NMEE.Data;
        end

        % Normalized Innovation Squated
        if exist('aNIS','var') == 1

            % Star tracker
            aNIS.st.Data = aNIS.st.Data + simulation(j).NIS_ST.Data;
            aNIS.st.N = aNIS.st.N + simulation(j).NIS_ST_flag.Data;

            % Radio
            aNIS.radio.Data = aNIS.radio.Data +...
                simulation(j).NIS_Radio.Data;
            aNIS.radio.N = aNIS.radio.N +...
                simulation(j).NIS_Radio_flag.Data;

        else

            %Star tracker
            aNIS.st.Data = simulation(j).NIS_ST.Data;
            aNIS.st.N = simulation(j).NIS_ST_flag.Data;

            % Radio
            aNIS.radio.Data = simulation(j).NIS_Radio.Data;
            aNIS.radio.N = simulation(j).NIS_Radio_flag.Data;

        end

        % Normalized Mean Innovation
        if exist('aNMI','var') == 1

            % Star tracker
            aNMI.st.Data = aNMI.st.Data + simulation(j).NMI_ST.Data;

            % Radio
            aNMI.radio.Data = aNMI.radio.Data +...
                simulation(j).NMI_Radio.Data;

        else

            %Star tracker
            aNMI.st.Data = simulation(j).NMI_ST.Data;
            
            % Radio
            aNMI.radio.Data = simulation(j).NMI_Radio.Data;
          
        end

    end

    %%% clear simIn
    clear simIn
end

%% Final computation of performance parameters

% aNEES
data_file.aNEES = squeeze(data_file.aNEES / N_sim);

% aNMEE
data_file.aNMEE = squeeze(data_file.aNMEE / N_sim);

% aNIS
aNIS.st.Data = squeeze(aNIS.st.Data);
aNIS.radio.Data = squeeze(aNIS.radio.Data);
aNIS.st.N = squeeze(aNIS.st.N);
aNIS.radio.N = squeeze(aNIS.radio.N);
aNIS.st.Data = aNIS.st.Data ./ aNIS.st.N;
aNIS.radio.Data = aNIS.radio.Data ./ aNIS.radio.N;

data_file.aNIS = aNIS;

% aNMI
aNMI.st.Data = squeeze(aNMI.st.Data);
aNMI.radio.Data = squeeze(aNMI.radio.Data);
aNMI.st.Data = aNMI.st.Data ./ aNIS.st.N';
aNMI.radio.Data = aNMI.radio.Data ./ aNIS.radio.N';

data_file.aNMI = aNMI;

% filter Time
data_file.time = simulation(1).errors.xm.Time;


PostProcess(data_file)

%% Auxiliary functions

function out = saveRawData(data, decimation)
out.Time = data.xm.Time(1:decimation:end);
out.xm = squeeze(data.xm.Data(:,1,1:decimation:end));
out.vm = squeeze(data.vm.Data(:,1,1:decimation:end));
out.attitude = squeeze(data.attitude.Data(:,1,1:decimation:end));
out.xb = squeeze(data.xb.Data(:,1,1:decimation:end));
out.vb = squeeze(data.vb.Data(:,1,1:decimation:end));
out.bias_gyro = squeeze(data.bias_gyro.Data(:,1,1:decimation:end));
out.bias_clock = squeeze(data.bias_clock.Data(:,1,1:decimation:end));
out.drift_clock = squeeze(data.drift_clock.Data(:,1,1:decimation:end));
out.aging_clock = squeeze(data.aging_clock.Data(:,1,1:decimation:end));
end

function out = saveInnovation(innovation_data,flag)
out.data=squeeze(innovation_data.Data(:,1,flag));
out.time=squeeze(innovation_data.Time(flag));
end