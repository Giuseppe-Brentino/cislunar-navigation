classdef test_radio < matlab.unittest.TestCase

    methods(Test)
        % Test methods

        function test_delay(testCase)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Test Signal Delay
            % This function verifies that the delay in the signal is
            % correctly applied by comparing specific time instances in the
            % simulation output.
            %
            % The expected delayed signal values should match the
            % predefined expected values at the given time points.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % Run simulation
            simulation = sim("Models\Radio\test_delay.slx");

            % Extract simulation output signal and time values
            signal = simulation.simout.Data;
            time = simulation.simout.Time;

            % Extract actual signal values at specified time points
            actual_points = [signal(time==11) signal(time==11.1)...
                signal(time==22) signal(time==22.1)];

            % Define expected signal values at the same time points
            expected_points = [1 11 11 21];

            % Verify that actual values match expected values
            testCase.verifyEqual(actual_points,expected_points)
        end

        function test_measurementUpdate(testCase)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Test Measurement Update
            % The function checks whether the timestamp and range values 
            % are properly computed and updated when the signal is 
            % received, ensuring consistency with expected results.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % Define timestamps of the spacecrafts positions
            time = 0:6;

            % Define the position of the transmitting spacecraft over time
            TX_data = [0 -101 0 0 0 0 -101;
                       0 0 101 101 101 101 0;
                       0 0 0 0 0 0 0];
            
            % Define the position of the receiving spacecraft over time
            RX_data = [zeros(3,1), [1000*ones(1,6);zeros(2,6)]];

            % Save the data into timeseries format
            RX = timeseries(RX_data,time);
            TX = timeseries(TX_data,time);

            % Moon radius
            R_M = 100;

            % Run simulation
            simulation = sim('Models\Radio\test_update.slx','srcWorkspace','current');

            % Extract simulation outputs
            timestamp = simulation.timestamp;
            range = simulation.range;

            % Verify timestamp updates correctly
            testCase.verifyTrue(all(timestamp.Data(timestamp.Time>=2)==2));
            testCase.verifyTrue(all(timestamp.Data(timestamp.Time<2)==0));

            % Verify range calculations are correct
            testCase.verifyTrue(all(range.Data(range.Time>=2)==sqrt(101^2+1000^2)));
            testCase.verifyTrue(all(range.Data(range.Time<2)==0));

        end

    end

end