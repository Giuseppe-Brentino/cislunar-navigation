classdef test_srp < matlab.unittest.TestCase
    
    methods(Test)
        % Test methods
      
        function test_a_srp(testCase)
            simulation = sim("Models\srp_test.slx");
            a_srp_x = simulation.a_x;
            a_srp_y = simulation.a_y;
            a_srp_z = simulation.a_z;
            env = getParameters('Scenario.sldd',{'Environment'});
            expected_a = env{1}.Sun.P.value*env{1}.AU.value*eye(3);

            testCase.verifyEqual(a_srp_x',expected_a(:,1))
            testCase.verifyEqual(a_srp_y',expected_a(:,2))
            testCase.verifyEqual(a_srp_z',expected_a(:,3))
        end
    end
    
end