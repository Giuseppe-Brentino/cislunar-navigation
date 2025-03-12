classdef test_IMU < matlab.unittest.TestCase

    methods(Test)
        % Test methods

        function test_gErrors(testCase)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Test Gyroscope g-related Errors
            % This function verifies that the simulated gyroscope g-related
            % errors match the expected values.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % Retrieve IMU gyroscope parameters
            data = getParameters('Sensors.sldd',{'IMU'});
            gyro = data{1}.gyroscope;

            % Run the gyroscope error simulation
            simulation = sim("Models\IMU\g_errors.slx",'srcWorkspace','current');

            % Extract simulated gyroscope errors
            actual_errors = simulation.simout;

            % Compute expected gyroscope errors
            expected_error = gyro.biasG.value + 2*gyro.scaleFactorG.value;
            expected_errors = expected_error*ones(1,3);

            % Verify that the actual errors match expected values
            testCase.verifyEqual(actual_errors,expected_errors)
        end

    end

end