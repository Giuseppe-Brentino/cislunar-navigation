classdef test_earthPosition < matlab.unittest.TestCase


    methods(Test)
        % Test methods

        function test_EPosition(testCase)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Test accuracy of Earth position estimation.
            % Verifies that angular direction error and distance error
            % are within acceptable limits.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % Run simulation
            simulation = sim('Earth_position.slx');

            % Extract outputs
            angular_error = simulation.angular_error;
            ideal_error = zeros(length(angular_error),1);

            expected_distance = simulation.real_dist;
            actual_distance = simulation.estimated_dist;

            % Verify angular error within 1 degree
            testCase.verifyEqual(angular_error,ideal_error,'absTol',1) 

            % Verify distance within 1% relative error
            testCase.verifyEqual(actual_distance,expected_distance,'relTol',1e-2);

        end

    end

end