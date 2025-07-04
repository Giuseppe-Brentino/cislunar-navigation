classdef test_srp < matlab.unittest.TestCase

    methods(Test)
        % Test methods

        function test_a_srp(testCase)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Test Solar Radiation Pressure (SRP) Acceleration
            % This function verifies whether the SRP acceleration 
            % components from the simulation match the expected value.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Run the simulation
            simulation = sim("Models\srp_test.slx");

            % Extract acceleration components from simulation results
            a_srp_x = simulation.a_x;
            a_srp_y = simulation.a_y;
            a_srp_z = simulation.a_z;

            % Retrieve environment parameters from the scenario data dictionary
            env = getParameters('Scenario.sldd',{'Environment'});

              % Compute expected acceleration due to SRP
            expected_a = env{1}.Sun.P.value*env{1}.AU.value^2*eye(3)*1e-3;

            % Verify that the simulated acceleration matches the expected values
            testCase.verifyEqual(a_srp_x',expected_a(:,1))
            testCase.verifyEqual(a_srp_y',expected_a(:,2))
            testCase.verifyEqual(a_srp_z',expected_a(:,3))
        end
    end

end