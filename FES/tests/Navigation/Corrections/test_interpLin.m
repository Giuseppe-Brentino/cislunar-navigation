classdef test_interpLin < matlab.unittest.TestCase

    methods(Test)
        % Test methods

        function test_linearInterpolation(testCase)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Test linear interpolation block.
            % Verifies that the output of a custom linear interpolation
            % matches the expected result for a simple time-value dataset.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % Define inputs as timeseries objects for simulation
            xk1 = timeseries([1; 2], [0; 1]);     % Value at t_k+1
            xk  = timeseries([1; 1], [0; 1]);     % Value at t_k
            tk  = timeseries([0; 1], [0; 1]);     % Time at t_k
            tk1 = timeseries([0; 2], [0; 1]);     % Time at t_k+1
            t   = timeseries([0; 1.5], [0; 1]);   % Time at interpolation point

            % Run Simulink model
            output = sim("test_interpolation.slx", 'srcWorkspace', 'current');

            % Extract interpolated output
            actual_x = output.x;

            % Expected linear interpolation result
            expected_x = [1; 1.5];

            % Verify that the output matches expected result
            testCase.verifyEqual(actual_x, expected_x);
        end

    end

end