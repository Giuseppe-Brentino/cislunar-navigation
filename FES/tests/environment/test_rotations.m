classdef test_rotations < matlab.unittest.TestCase

    properties
        psi = deg2rad(30);
        theta = deg2rad(45);
        phi = deg2rad(60);
        tol = 1e-6;
        simulation;
    end

    methods (TestMethodSetup)

        function setup(testCase)
            % Run test model
            psi = testCase.psi;
            theta = testCase.theta;
            phi = testCase.phi;
            testCase.simulation = sim('./Models/rotations_test.slx','SrcWorkspace','current');
        end

    end


    methods(Test)
        % Test methods

        function test_R1(testCase)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Test Rotation Matrix R1
            % This test case verifies that the computed direction cosine
            % matrix (DCM) for a rotation about the X-axis from the
            % simulation matches the expected result calculated using
            % MATLAB's `angle2dcm` function.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % Expected DCM using rotation about X-axis
            expected = angle2dcm(testCase.psi,0,0,"XYZ");

            % Extract actual rotation matrix from simulation results
            actual = testCase.simulation.R1.signals.values;

            % Verify computed and expected matrices match within the specified tolerance
            verifyEqual(testCase,actual,expected,'RelTol',testCase.tol)
        end

        function test_R2(testCase)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Test Rotation Matrix R2
            % This test case verifies that the computed direction cosine
            % matrix (DCM) for a rotation about the Y-axis from the
            % simulation matches the expected result calculated using
            % MATLAB's `angle2dcm` function.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % Expected DCM using rotation about Y-axis
            expected = angle2dcm(testCase.theta,0,0,"YXZ");

            % Extract actual rotation matrix from simulation results
            actual = testCase.simulation.R2.signals.values;

            % Verify computed and expected matrices match within the specified tolerance
            verifyEqual(testCase,actual,expected,'RelTol',testCase.tol)
        end

        function test_R3(testCase)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Test Rotation Matrix R2
            % This test case verifies that the computed direction cosine
            % matrix (DCM) for a rotation about the Y-axis from the
            % simulation matches the expected result calculated using
            % MATLAB's `angle2dcm` function.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % Expected DCM using rotation about Z-axis
            expected = angle2dcm(testCase.phi,0,0,"ZXY");

            % Extract actual rotation matrix from simulation results
            actual = testCase.simulation.R3.signals.values;

            % Verify computed and expected matrices match within the specified tolerance
            verifyEqual(testCase,actual,expected,'RelTol',testCase.tol)
        end

        function test_R313(testCase)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Test Rotation Matrix R313
            % This test case checks the correctness of the rotation matrix
            % R313 by comparing the simulation result with the expected
            % result computed using MATLAB's `angle2dcm` function with the
            % "ZXZ" rotation sequence.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % Compute the expected DCM using "ZXZ" rotation sequence
            expected = angle2dcm(testCase.phi,testCase.theta,testCase.psi,"ZXZ");
            
            % Extract the actual rotation matrix from the simulation results
            actual = testCase.simulation.R313.signals.values;

            % Verify that the computed rotation matrix matches the expected one
            verifyEqual(testCase,actual,expected,'RelTol',testCase.tol)
        end

    end

end

