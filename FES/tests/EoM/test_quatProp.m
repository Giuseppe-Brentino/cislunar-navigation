classdef test_quatProp < matlab.unittest.TestCase


    methods(Test)
        % Model from Spacecraft Attitude Determination and Control, James R.
        % Wertz, 2002

        function test_propagation(testCase)
            q0 = [0;0;0;1];
            tf = 50;
            w = [0.1;0.2;0.3];
            simulation = sim("Models\quat_prop_test.slx",'SrcWorkspace','Current');

            time = simulation.tout;
            Omega = [0 w(3) -w(2) w(1);
                -w(3) 0 w(1) w(2);
                w(2) -w(1) 0 w(3);
                -w(1) -w(2) -w(3) 0];

            expected_quat = zeros(size(simulation.quat,1),4);
            for i = 1:size(simulation.quat,1)
                expected_quat(i,:) = expm(Omega*time(i)/2)*q0;
            end
            
            testCase.verifyEqual(simulation.quat,expected_quat,'RelTol',1e-6);
        end
    end

end