classdef test_3rdBodyPert < matlab.unittest.TestCase

    methods(Test)
        % Test methods

        function test_pert(testCase)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Test Third-Body Perturbation
            % This test case verifies that the third-body perturbation 
            % acceleration is correctly computed in the simulation. The 
            % expected acceleration is a constant vector [0.75, 0.75, 0.75]
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Run the simulation for the third-body perturbation model
            simulation = sim("Models\thirdBodyPert_test.slx");

            % Verify that the simulation output matches the expected acceleration
            testCase.verifyEqual(simulation.acc,[0.75,0.75,0.75])
        end
    end

end