classdef test_STM < matlab.unittest.TestCase



    methods(Test)
        % Test methods

        function test_stateTransitionMatrix(testCase)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Test state transition matrix computation.
            % Validates that the Jacobian matrix (F) computed by the
            % "Compute STM" simulink block.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % Load parameters from the data dictionary
            data = getParameters('Navigation.sldd',{'StartDate','Propagation','x0','statesBus'});
            StartDate = data{1};
            Propagation = data{2};
            x0 = data{3};
            statesBus = data{4};

            % Extract initial state components
            x_m = x0.value(1:3);            % Position of main satellite
            q_m = x0.value(7:10);           % Attitude quaternion of main satellite
            x_b = x0.value(11:13);          % Position of secondary body
            bias_acc = x0.value(17:19);     % Accelerometer bias
            bias_gyro = x0.value(20:22);    % Gyroscope bias

            % Define simulation step and test accelerations/rotations
            dt = 0.2;
            a = ones(3,1)*1e-4;
            w = a;

            % Run Simulink model
            simulation = sim("Models\STM.slx",'srcWorkspace','current');
            x_e = simulation.x_e(:,:,2);    % Earth's position at t+dt
            actual_F = simulation.F(:,:,2); % STM from simulation

            % Compute required rotation matrices
            R = quat2rotm(q_m([4,1:3])');

            % Bias-corrected measurements
            acc = a-bias_acc;
            omega = w-bias_gyro;

            % Skew-symmetric matrix of acceleration
            ax = [0, -acc(3), acc(2);
                acc(3), 0, -acc(1);
                -acc(2), acc(1), 0];

            % Skew-symmetric matrix of angular velocity
            wx = [0, -omega(3), omega(2);
                omega(3), 0, -omega(1);
                -omega(2), omega(1), 0];

            % Initialize gravity model object
            fun = SH_nav;

            % Configure SH_nav with Moon's gravity field
            fun.body_coeffs = Propagation.Moon.SH;
            fun.mu = Propagation.Moon.mu.value;
            fun.ref_radius = Propagation.Moon.radius.value;
            fun.nMax = Propagation.Moon.SH.n.value;
            fun.mMax = Propagation.Moon.SH.m.value;
            % Compute Moon rotation matrix

            moon_orientation = Propagation.Moon.eul0.value + ...
                Propagation.Moon.eul_dot.value;
            moon_rotm = eul2rotm(flip(moon_orientation),'ZXZ')';

            % Rotate main satellite position into Moon-fixed frame
            pos = moon_rotm*x_m;

            % Get Moon gravity gradient in MPA frame, transform to MCI
            [~, dgm_dxm_MPA] = fun.getDerivative(pos);
            dgm_dxm = moon_rotm'*dgm_dxm_MPA*moon_rotm;

            % Compute Earth gravity gradient w.r.t. main satellite position
            dge_dxm = Propagation.Earth.mu.value*...
                (3*(x_m-x_e)*(x_m-x_e)'/norm(x_m-x_e)^5 - eye(3)/norm(x_m-x_e)^3);

            % Compute Earth gravity gradient w.r.t. beacon satellite position
            dge_dxb = Propagation.Earth.mu.value*...
                (3*(x_b-x_e)*(x_b-x_e)'/norm(x_b-x_e)^5 - eye(3)/norm(x_b-x_e)^3);

            % Compute Moon gravity gradient w.r.t. beacon satellite position
            dgm_dxb = Propagation.Moon.mu.value*...
                (3*(x_b)*(x_b)'/norm(x_b)^5 - eye(3)/norm(x_b)^3);

            % Initialize and populate Jacobian (F matrix)
            F = zeros(23);
            F(1:3,4:6) = eye(3);                      % d(velocity_m)/d(velocity_m)
            F(4:6,7:9) = -R * ax*1e-3;                % d(acceleration_m)/d(attitude_m)
            F(7:9,7:9) = -wx;                         % d(angular velocity_b)/d(attitude_m)
            F(10:12,13:15) = eye(3);                  % d(velocity_b)/d(velocity_b)
            F(22,23) = 1;                             % d(clock drift)/d(clock drift)
            F(4:6,16:18) = -R;                        % d(acceleration_m)/d(acc bias)
            F(7:9,19:21) = -eye(3);                   % d(angular vel_m)/d(gyro bias)
            F(4:6,1:3) = dgm_dxm + dge_dxm;           % d(velocity_m)/d(position_m)
            F(13:15,10:12) = dgm_dxb + dge_dxb;       % d(velocity_b)/d(position_b)

            % Compute expected STM using Euler discretization
            expected_F = F*dt + eye(23);

            % Verify simulation output matches expected result
            testCase.verifyEqual(actual_F,expected_F,'AbsTol',eps)

        end
    end

end