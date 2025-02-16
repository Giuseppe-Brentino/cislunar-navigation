classdef test_tbp < matlab.unittest.TestCase

    methods(Test)
        % Test methods

        function test_2bp(testCase)
            %orbital elements
            mu = 398600;
            a = 6786230;
            ecc = .01;
            incl = 52;
            RAAN = 95;
            argp = 93;
            nu = 10;
            [r0,v0] = keplerian2ijk(a,ecc,incl,RAAN,argp,nu);
            r0=r0/1000;
            v0=v0/1000;
            period = 2*pi*sqrt((a/1000)^3/mu);
            model = sim("./Models/tbp_test.slx",'SrcWorkspace','current');
            rf = model.pos.Data(end,:);
            vf = model.vel.Data(end,:);
            verifyEqual(testCase,[r0;v0],[rf';vf'],'RelTol',1e-4)
        end

    end
    
end

