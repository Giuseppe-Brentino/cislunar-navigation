classdef test_EoM < matlab.unittest.TestCase
    
    properties
        acc = [1;1;1];
        mu = 398600;
    end
    
    methods(Test)
        % Test methods
        
        function test_omega(testCase)
            a = 7e6;
            e = 0;
            i = 0;
            OM = 0;
            om = 0;
            th = 0;
            [x0,v0] = keplerian2ijk(a,e,i,OM,om,th,'truelon',0);
            x0 = x0/1000;
            v0 = v0/1000;
            w_check = true;
            tf = 2*pi*2*pi*sqrt((a/1000)^3/testCase.mu);
            simulation = sim('Models\EoM_test.slx','SrcWorkspace','Current');
            
            w_actual = simulation.omega;
            w_exp = v0(2)/x0(1) * [zeros(size(w_actual,1),2),ones(size(w_actual,1),1)];
            testCase.verifyEqual(w_actual,w_exp,'AbsTol',1e-8)
        end

        function test_motion(testCase)
            x0 = [1;1;1];
            v0 = [1;1;1];

            tf = 10;
            vf_exp = v0 + testCase.acc*tf;
            xf_exp = x0 + v0*tf + 0.5*testCase.acc*tf^2;
            w_check = false;
            simulation = sim('Models\EoM_test.slx','SrcWorkspace','Current');
            xf = simulation.pos(end,:)';
            vf = simulation.vel(end,:)';
            
            testCase.verifyEqual(xf,xf_exp,'RelTol',1e-6);
            testCase.verifyEqual(vf,vf_exp,'RelTol',1e-6);
        end
    end
    
end