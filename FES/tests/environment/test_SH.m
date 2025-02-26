classdef test_SH < matlab.unittest.TestCase

    methods(Test)
        % Test methods

        function test_sphericalHarmonics(testCase)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Test Spherical Harmonics Gravity Model
            % This function verifies that the computed gravity acceleration
            % using the spherical harmonics model matches the expected
            % values.
            % Test data from R. G. Gottlieb, ‘Fast Gravity, Gravity
            % Partials, Normalized Gravity, Gravity Gradient Torque and
            % Magnetic Field: Derivation, Code and Data’.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % Create an instance of the sphericalHarmonics class
            fun = sphericalHarmonics;

            % Retrieve test data parameters from the scenario data dictionary
            p = getParameters('Scenario.sldd',{'TestData'});
            TestData = p{1};

            % Set spherical harmonics parameters
            fun.body_coeffs = TestData.SH;
            fun.mu = TestData.SH.mu.value;
            fun.ref_radius = TestData.SH.ref_radius.value;
            fun.nMax = TestData.SH.n.value;
            fun.mMax = TestData.SH.m.value;

            % Define the test position (ECEF coordinates)
            position = [5489150, 802222, 3140916]';

            % Compute the actual gravity acceleration using the spherical harmonics model
            [actual_g,~,~] = fun.getGravity(position);

            % Expected gravity acceleration values
            expected_g = [-8.44260633555472;-1.23393243051834; -4.84652486332608];

            % Verify that the computed gravity matches the expected values within a tolerance
            verifyEqual(testCase,actual_g,expected_g,'RelTol',1e-15)

        end
    end

end