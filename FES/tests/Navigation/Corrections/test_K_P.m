classdef test_K_P < matlab.unittest.TestCase

    properties
        P
        H
        R
        data
    end

    methods(TestClassSetup)
        function run_sim(testCase)
            % Run simulation to get the necessary data to execute the tests
            testCase.P = eye(3);
            testCase.R = eye(2);
            testCase.H = ones(2,3);
            testCase.data = sim("test_KP.slx",'srcWorkspace','current');
        end
    end

    methods(Test)
        % Test methods

        function test_KalmanGain(testCase)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Test Kalman gain computation.
            % Verifies that the innovation covariance matrix S and the
            % Kalman gain K are correctly computed based on the state
            % covariance P, observation matrix H, and measurement noise R.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % Extract actual matrices from simulation
            actual_S = testCase.data.S;    % Innovation covariance from simulation
            actual_K = testCase.data.K;    % Kalman gain from simulation

            % Compute expected innovation covariance
            expected_S = testCase.H * testCase.P * testCase.H' + testCase.R;

            % Compute expected Kalman gain
            expected_K = testCase.P * testCase.H' / expected_S;

            % Verify both S and K are correct
            testCase.verifyEqual(actual_S, expected_S);
            testCase.verifyEqual(actual_K, expected_K);
        end

        function test_CovUpdate(testCase)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Test covariance matrix update.
            % Verifies that the posterior covariance matrix P⁺ is correctly
            % updated using the Kalman gain and that the result is 
            % symmetric and positive semi-definite.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Extract actual posterior covariance from simulation
            actual_P = testCase.data.P_plus;

            % Compute expected posterior covariance using Kalman filter update
            expected_P = ( eye( size(testCase.P,2) ) - ...
                testCase.data.K*testCase.H)*testCase.P;

             % Verify symmetry and positive semi-definiteness of the covariance matrix
            testCase.verifyTrue( issymmetric(actual_P) && ...
                all( eig(actual_P) >=0 ) )

            % Verify that the updated covariance matches the expected result
            testCase.verifyEqual(actual_P, expected_P,'AbsTol',eps);
        end

    end

end