classdef test_quat2DCM < matlab.unittest.TestCase

    methods(Test)

        function test_qToDCM(testCase)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Test Quaternion to Direction Cosine Matrix (DCM) Conversion
            % This function verifies that the dcm computed by the custom
            % quat2DCM simulink block matches the one computed using the
            % built in quat2rotm function.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % Generate a random quaternion
            q = rand(1,4);
            q = q/norm(q);

            % Compute expected DCM using MATLAB's quaternion to rotation matrix function
            expected_DCM = (quat2rotm([q(4) q(1:3)]))';
            
            % Run the quaternion to DCM conversion simulation
            simulation = sim("Models\quatToDCM.slx","srcWorkspace",'current');
            
            % Extract actual DCM from simulation results
            actual_DCM = simulation.dcm;
            
            % Verify the computed DCM matches expected values within tolerance
            testCase.verifyEqual(actual_DCM,expected_DCM,'relTol',1e-10)

        end
    end

end