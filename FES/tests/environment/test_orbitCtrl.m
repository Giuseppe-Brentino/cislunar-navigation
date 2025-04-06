classdef test_orbitCtrl < matlab.unittest.TestCase

    properties
        OrbitCtrl
    end

    methods(TestClassSetup)

        function get_data(testCase)
            % Load parameters from dictionary
            data = getParameters('Scenario.sldd',{'OrbitCtrl'});
            testCase.OrbitCtrl = data{1};
        end

    end


    methods(Test)
        % Test methods

        function test_orbitParameters(testCase)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Test orbital parameter extraction
            % This test validates the inclination (i), specific angular
            % momentum (h) and argument of latitude (u) computed to control
            % the orbit inclination.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % Define Keplerian elements
            a = 7e6;         % Semi-major axis [m]
            e = 0.2;         % Eccentricity
            i = 45;          % Inclination [deg]
            RAAN = 120;      % Right Ascension of Ascending Node [deg]
            om = 100;        % Argument of Perigee [deg]
            th = 0;          % True Anomaly [deg]

            % Convert to ECI position and velocity vectors [km]
            [x0,v0] = keplerian2ijk(a,e,i,RAAN,om,th);
            x0 = x0/1e3;
            v0 = v0/1e3;

            % Run the simulation
            simulation = sim('Models\orbitCtrl_params_test.slx','srcWorkspace','current');

            % Extract simulation outputs
            actual_i = simulation.i;
            actual_h = simulation.h;
            actual_u = simulation.u;

            % Expected inclination (constant)
            expected_i = i*ones(length(actual_i),1);

            % Expected unit angular momentum vector
            h_vec = cross(x0, v0);
            expected_h = repmat(h_vec ./ norm(h_vec), 1, length(actual_h));

            % Expected argument of latitude (u = om + th)
            expected_u = zeros(length(actual_i),1);
            for j = 1:length(expected_i)
                [~,~,~,~,om,th] = ijk2keplerian(simulation.x(j,:)*1e3,...
                    simulation.v(j,:)*1e3);
                expected_u(j) = deg2rad(om+th);
            end

            % Assertions
            testCase.verifyEqual(actual_i,expected_i,'RelTol',1e-12)
            testCase.verifyEqual(actual_h',expected_h,'RelTol',1e-12)

            u_diff = angdiff(actual_u,expected_u);
            testCase.verifyEqual(u_diff,zeros(length(u_diff),1),'absTol',2e-8)
        end

        function test_uCheck(testCase)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Test orbit controller u-bound checking logic
            % Validates that the flag output correctly identifies
            % violations of the minimum and maximum target_u limits.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % Load orbit controller parameters
            OrbitCtrl = testCase.OrbitCtrl;

            % Define a timeseries of argument of latitude (u)
            u_values = [1.5*pi, OrbitCtrl.target_uMax.value, pi, ...
                OrbitCtrl.target_uMin.value, 0];
            time_values = 0:4;
            u = timeseries(u_values, time_values);

            % Run the orbit control check model
            simulation = sim('Models/orbitCtrl_check_test.slx','srcWorkspace','current');

            % Expected flag vector (0 indicates out-of-bounds condition)
            expected_flags = [0, 0, 1, 0, 0];

            % Verify the simulation output flags match expected behavior
            testCase.verifyEqual(simulation.flag', expected_flags);
        end

    end

end