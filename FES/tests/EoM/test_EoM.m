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
            q0 = [0;0;0;1];
            w_check = true;
            tf = 2*pi*sqrt((a/1000)^3/testCase.mu);
            simulation = sim('Models\EoM_test.slx','SrcWorkspace','Current');

            w_actual = simulation.omega;
            w_exp = -v0(2)/x0(1) * [zeros(size(w_actual,1),1),ones(size(w_actual,1),1), zeros(size(w_actual,1),1)];
            testCase.verifyEqual(w_actual,w_exp,'AbsTol',1e-8)
        end

        function test_motion(testCase)
            x0 = [1;1;1];
            v0 = [1;1;1];

            tf = 10;
            vf_exp = v0 + testCase.acc*tf;
            xf_exp = x0 + v0*tf + 0.5*testCase.acc*tf^2;
            w_check = false;
            q0 = [0;0;0;1];
            simulation = sim('Models\EoM_test.slx','SrcWorkspace','Current');
            xf = simulation.pos(end,:)';
            vf = simulation.vel(end,:)';

            testCase.verifyEqual(xf,xf_exp,'RelTol',1e-6);
            testCase.verifyEqual(vf,vf_exp,'RelTol',1e-6);
        end

        function test_omega_quat(testCase)
            a = 7e6;
            e = 0.43;
            i = 23;
            OM = 235;
            om = 69;
            th = 42;
            [x0,v0] = keplerian2ijk(a,e,i,OM,om,th);
            x0 = x0/1000;
            v0 = v0/1000;
            w_check = true;
            tf = 2*pi*sqrt((a/1000)^3/testCase.mu);

            h = cross(x0,v0);
            A2 = -h'/norm(h);
            A3 = -x0'/norm(x0);
            A1 = cross(A2,A3);
            A = [A1;A2;A3];
            q0_t = dcm2quat(A)';
            q0 = [q0_t(2:4);q0_t(1)];

            simulation = sim('Models\EoM_test.slx','SrcWorkspace','Current');

            q = [simulation.quat(:,4), simulation.quat(:,1:3)];
            pos = simulation.pos;
            vel = simulation.vel;

            actual_attitude = quat2dcm(q);
            expected_attitude =  zeros(3,3,size(q,1));

            for i = 1:size(q,1)
                h = cross(pos(i,:),vel(i,:));
                A2 = -h/norm(h);
                A3 = -pos(i,:)/norm(pos(i,:));
                A1 = cross(A2,A3);
                expected_attitude(:,:,i) = [A1;A2;A3];
            end

            testCase.verifyEqual(actual_attitude,expected_attitude,'AbsTol',1e-8)

        end

    end

end