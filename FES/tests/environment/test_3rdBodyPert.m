classdef test_3rdBodyPert < matlab.unittest.TestCase
    
    methods(Test)
        % Test methods
        
        function test_pert(testCase)
            simulation = sim("Models\thirdBodyPert_test.slx");
            testCase.verifyEqual(simulation.acc,[0.75,0.75,0.75])
        end
    end
    
end