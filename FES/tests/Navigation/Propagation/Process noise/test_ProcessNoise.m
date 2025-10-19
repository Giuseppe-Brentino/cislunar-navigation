classdef test_ProcessNoise < matlab.unittest.TestCase
    methods(Test)
        % Test methods
        function test_process_noise(testCase)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Test propagation of process noise covariance.
            % Verifies that the discrete-time process noise covariance
            % matrix Q is correctly computed using the state transition
            % matrix (STM) and noise input matrix G.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % Load parameters from the data dictionary
            data = getParameters('Navigation.sldd',{'Q', 'R_sensor2body',...
                'Propagation'});

            Q = data{1};
            R_sensor2body = data{2};
            Propagation = data{3};

            % accelerometer uncertainty
            P_acc = eye(3)*1e-8;

            % Define rotation and STM matrices
            R_bi = eye(3);
            Phi = eye(21);

            % Run Simulink model
            simulation = sim("process_noise.slx",'srcWorkspace','current');
            
            actual_Q = simulation.process_noise; % Process noise from simulation
            
            % Construct G matrix (input noise influence matrix)
            G = zeros(21,15);
            G(4:6,1:3) = eye(3);
            G(13:15,4:6) = eye(3);
            G(16:21,10:15) = eye(6);
            G(7:9,7:9) = -R_sensor2body.value;
            % Expected Q from STM and noise model
            Q.value(1:3,1:3) = Q.value(1:3,1:3) + R_bi*P_acc*R_bi';
            expected_Q = (Phi*G)*Q.value*(Phi*G)'/Propagation.lf.value;

            % Verify that the computed Q matches the expected one
            testCase.verifyEqual(actual_Q,expected_Q,'AbsTol',1e-19);

        end
    end
end