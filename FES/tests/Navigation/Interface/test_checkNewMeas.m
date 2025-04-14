classdef test_checkNewMeas < matlab.unittest.TestCase


    methods(Test)
        % Test methods

        function test_newMeas(testCase)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Test detection and handling of new measurement inputs.
            % Verifies that the system correctly flags and updates
            % time and measurement values when a new usable value appears.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % Setup test input time series
            t = 0:6;
            time_data = [0;0;1;2;3;3;4];
            meas_data = [1,1; 1,1; 2,2; -1,-1; -2,-2; -3,-3; 4,4];

            time = timeseries(time_data,t);
            meas = timeseries(meas_data,t);

            % Run the simulation
            simulation = sim('check_for_update.slx','srcWorkspace','current');

            % Extract outputs
            actual_time = simulation.time;
            actual_measure = simulation.measure;
            actual_flag = simulation.flag;

            % Expected results
            expected_flag = [false false true false false false true]';
            expected_time = [0;0;1;1;1;1;4];
            expected_measure = [0,0;0,0;2,2;2,2;2,2;2,2;4,4];

            % Assertions
            testCase.verifyEqual(actual_flag,expected_flag)
            testCase.verifyEqual(actual_time,expected_time)
            testCase.verifyEqual(actual_measure,expected_measure)
        end

    end

end