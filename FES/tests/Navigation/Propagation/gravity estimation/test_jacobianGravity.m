classdef test_jacobianGravity < matlab.unittest.TestCase

    methods(Test)
        % Test methods

        function test_jacobian(testCase)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Test accuracy of gravity acceleration and Jacobian
            % computed using the spherical harmonics model.
            % Verifies both gravity vector and Jacobian matrix match
            % expected values within high numerical precision.
            % Source:
            % R. G. Gottlieb, “Fast Gravity, Gravity Partials, Normalized
            % Gravity, Gravity Gradient Torque and Magnetic Field:
            % Derivation, Code and Data.”
            % https://ntrs.nasa.gov/api/citations/19940025085/downloads/19940025085.pdf
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % Create an instance of the SH_nav class
            fun = SH_nav;

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

            % Compute the actual derivatives using the spherical harmonics model

            [actual_g, actual_dg] = fun.getDerivative(position);

            % Expected Jacobian matrix
            expected_dg = [
                1.87773230503190e-06,  4.99259374934480e-07,  1.96507472112557e-06;
                4.99259374934480e-07, -1.46513564895359e-06,  2.87208844531796e-07;
                1.96507472112557e-06,  2.87208844531796e-07, -4.12596656078305e-07
                ];

            % Expected gravity acceleration values
            expected_g = [-8.44260633555472;-1.23393243051834; -4.84652486332608];

            % Verify that the computed gravity matches the expected values within a tolerance
            verifyEqual(testCase,actual_g,expected_g,'RelTol',1e-14)
            verifyEqual(testCase,actual_dg,expected_dg,'RelTol',1e-14)

        end
    end

end