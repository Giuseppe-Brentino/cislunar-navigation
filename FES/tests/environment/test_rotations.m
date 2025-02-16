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
            expected = angle2dcm(testCase.psi,0,0,"XYZ");
            actual = testCase.simulation.R1.signals.values;
            verifyEqual(testCase,actual,expected,'RelTol',testCase.tol)
        end

         function test_R2(testCase)
            expected = angle2dcm(testCase.theta,0,0,"YXZ");
            actual = testCase.simulation.R2.signals.values;
            verifyEqual(testCase,actual,expected,'RelTol',testCase.tol)
         end

          function test_R3(testCase)
            expected = angle2dcm(testCase.phi,0,0,"ZXY");
            actual = testCase.simulation.R3.signals.values;
            verifyEqual(testCase,actual,expected,'RelTol',testCase.tol)
          end

          function test_R313(testCase)
            % angle2dcm is weird and the multiplication order is inverted
            expected = angle2dcm(testCase.phi,testCase.theta,testCase.psi,"ZXZ");
            actual = testCase.simulation.R313.signals.values;
            verifyEqual(testCase,actual,expected,'RelTol',testCase.tol)
        end
    end
    
end

