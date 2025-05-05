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
            data = getParameters('Navigation.sldd',{'StartDate','Propagation',...
                'x0','statesBus','Q', 'R_sensor2body'});
            StartDate = data{1};
            Propagation = data{2};
            x0 = data{3};
            statesBus = data{4};
            Q = data{5};
            R_sensor2body = data{6};

            % Extract initial state components
            x_m = x0.value(1:3);            % Position of main satellite
            q_m = x0.value(7:10);           % Attitude quaternion of main satellite
            x_b = x0.value(11:13);          % Position of secondary body
            bias_acc = x0.value(17:19);     % Accelerometer bias
            bias_gyro = x0.value(20:22);    % Gyroscope bias

            % Convert quaternion to rotation matrix
            R_bi = quat2rotm(q_m([4,1:3])');

            % Define nominal accelerometer and gyroscope measurements
            a = ones(3,1)*1e-4;
            w = a;

            % Run Simulink model
            simulation = sim("process_noise.slx",'srcWorkspace','current');
            Phi = simulation.Phi(:,:,2); % STM from simulation
            actual_Q = simulation.process_noise(:,:,2); % Process noise from simulation

            % Helper function to convert block indices to actual row/col indices
            block = @(i) (3*(i-1)+1):(3*i);
            
            % Construct G matrix (input noise influence matrix)
            G = zeros(23,20);
            G(block(2), block(1)) = eye(3);
            G(block(2), block(3)) = R_bi*R_sensor2body.value;
            G(block(3), block(5)) = -R_sensor2body.value;
            G(block(5), block(2)) = eye(3);
            G(block(6), block(4)) = eye(3);
            G(block(7), block(6)) = eye(3);
            G(22,19) = 1;
            G(23,20) = 1;

            % Expected Q from STM and noise model
            expected_Q = (Phi*G)*Q.value*(Phi*G)'/Propagation.lf.value;

            % Verify that the computed Q matches the expected one
            testCase.verifyEqual(actual_Q,expected_Q,'AbsTol',1e-19);

        end
    end
end