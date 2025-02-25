classdef test_quatProp < matlab.unittest.TestCase

    methods(Test)
        % Source: J. R. Wertz, Spacecraft Attitude Determination and Control

        function test_propagation(testCase)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Test the propagation of a quaternion using a constant angular
            % velocity.
            % This function compares the propagated quaternion from the
            % simulation with the expected quaternion derived from
            % analytical quaternion propagation.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % Initial quaternion (identity)
            q0 = [0;0;0;1];

            % Final time (seconds)
            tf = 50;

            % Constant angular velocity [w_x; w_y; w_z] in rad/s
            w = [0.1;0.2;0.3];

            % Run the simulation
            simulation = sim("Models\quat_prop_test.slx",'SrcWorkspace','Current');

            % Time vector from simulation
            time = simulation.tout;

            % Skew-symmetric matrix of angular velocity (Omega)
            Omega = [0 w(3) -w(2) w(1);
                -w(3) 0 w(1) w(2);
                w(2) -w(1) 0 w(3);
                -w(1) -w(2) -w(3) 0];

            % Preallocate array for expected quaternions
            expected_quat = zeros(size(simulation.quat,1),4);

            % Compute analytically the expected quaternions for each time step
            for i = 1:size(simulation.quat,1)
                expected_quat(i,:) = expm(Omega*time(i)/2)*q0;
            end

            % Verify that the simulated quaternions match the expected ones within tolerance
            testCase.verifyEqual(simulation.quat,expected_quat,'RelTol',1e-6);

        end

    end

end