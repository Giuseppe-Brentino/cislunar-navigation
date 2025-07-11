classdef PostProcess
    % POSTPROCESS class: run the postprocess of the simulation

    properties
        data_file
    end

    methods

        function obj = PostProcess(varargin)
            if isempty(varargin)
                [name,path] = uigetfile;
                data = strcat(path,name);
                obj.data_file = matfile(data);
            else
                obj.data_file = varargin{1};
            end
        end

        function run_all(obj)
            % Method to run all the analysis scripts.

            % Get the full path of the current function file
            currentFile = mfilename('fullpath');

            % Get the folder containing the function
            functionFolder = fileparts(currentFile);

            % Get all analysis scripts
            analysis_files = dir(functionFolder+"/"+"*AN*.m");
            analysis = {analysis_files.name};

            %Initialize error messages
            errors = cell(1,length(analysis));

            % Run all analysis scripts
            for i = 1:length(analysis)
                fun = str2func(erase(analysis{i},'.m'));
                try
                    feval(fun,obj.data_file);
                    close all;
                catch ME
                    errors{i} = ME;
                end
            end
        end

        function plot_2D (obj,varargin)
            %% Parse input
            p = inputParser;

            addParameter(p, 'sub_rows',1);
            addParameter(p, 'sub_cols',1);
            addParameter(p, 'label_x',cell(1));
            addParameter(p, 'label_y',cell(1));
            addParameter(p, 'x_data',cell(1));
            addParameter(p, 'y_data',cell(1));
            addParameter(p, 'names',cell(1));
            addParameter(p, 'lim_x',{});
            addParameter(p, 'lim_y',{});
            addParameter(p, 'DMS_angles',false,@islogical);

            parse(p, varargin{:});

            sub_rows = p.Results.sub_rows;
            sub_cols = p.Results.sub_cols;
            label_x = p.Results.label_x;
            if length(label_x)<sub_rows*sub_cols
                temp = cat(2,label_x,cell(1,sub_cols*sub_rows-length(label_x)));
                label_x = temp;
            end
            label_y = p.Results.label_y;
            if length(label_y)<sub_rows*sub_cols
                temp = cat(2,label_y,cell(1,sub_cols*sub_rows-length(label_y)));
                label_y = temp;
            end
            x_data = p.Results.x_data;
            y_data = p.Results.y_data;
            names = p.Results.names;
            DMS_angles = p.Results.DMS_angles;
            lim_x = p.Results.lim_x;
            lim_y = p.Results.lim_y;

            %% Make plot
            figure
            hold on
            grid on

            for i = 1:sub_rows % Iterate over the rows of the subplot
                for j = 1:sub_cols % Iterate over the columns of the subplot

                    current_element = (i-1)*sub_cols+j; % Compute current element in the grid

                    subplot(sub_rows,sub_cols,current_element) % create subplot
                    hold on
                    grid on

                    % Plot data
                    for k = 1:length(x_data{current_element})
                        % Plot
                        plot(x_data{current_element}{k},y_data{current_element}{k})
                    end
                    try
                        legend(names{current_element});
                    catch
                    end
                    xlabel(label_x{current_element})
                    ylabel(label_y{current_element})
                    if DMS_angles
                        % Initial DMS label update
                        obj.updateDMSLabels(gca);

                        % Add listener for dynamic updates on zoom/pan/resize
                        addlistener(gca, 'MarkedClean', @(src, evt) obj.updateDMSLabels(src));
                    end
                    if ~isempty(lim_x)
                        xlim(lim_x{current_element})
                    end
                    if ~isempty(lim_y)
                        ylim(lim_y{current_element})
                    end
                end
            end

        end

        function updateDMSLabels(obj,ax)
            yt = get(ax, 'YTick')*180/pi;  % Get current y-axis ticks
            ylabels = arrayfun(@(x) obj.deg2dmsstr(x), yt, 'UniformOutput', false);
            set(ax, 'YTickLabel', ylabels);
        end

        function dmsStr = deg2dmsstr(obj,deg)
    % Convert decimal degrees to string with degrees, minutes, seconds
    signStr = '';
    if deg < 0
        signStr = '-';
        deg = abs(deg);
    end

    d = floor(deg);
    remainder = (deg - d) * 60;
    m = floor(remainder);
    s = round((remainder - m) * 60);

    % Correct rounding overflow
    if s == 60
        s = 0;
        m = m + 1;
    end
    if m == 60
        m = 0;
        d = d + 1;
    end

    dmsStr = sprintf('%s%d°%02d''%02d"', signStr, d, m, s);
end


    end

end
