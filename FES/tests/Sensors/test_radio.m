classdef test_radio < matlab.unittest.TestCase

    methods(TestClassSetup)
        % Shared setup for the entire test class
    end

    methods(TestMethodSetup)
        % Setup for each test
    end

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
    end

end