classdef test_EoM < matlab.unittest.TestCase

    properties
        acc = [1;1;1]; % constant acceleration for test_motion
        mu = 398600; % Gravitational parameter
    end

    methods(Test)
        % Test methods

        function test_omega(testCase)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Test the angular velocity computation based on the initial
            % velocity in a given orbit. This function compares the actual
            % angular velocity from the simulation with the expected
            % angular velocity computed from orbital parameters.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % Define orbital elements
            a = 7e6;      % semi-major axis in meters
            e = 0;        % eccentricity (circular orbit)
            i = 0;        % inclination in radians
            OM = 0;       % longitude of ascending node in radians
            om = 0;       % argument of periapsis in radians
            th = 0;       % true anomaly in radians

            % Convert Keplerian orbital elements to position and velocity
            [x0,v0] = keplerian2ijk(a,e,i,OM,om,th,'truelon',0);
            x0 = x0/1000; % Convert position to km
            v0 = v0/1000; % Convert velocity to km/s

            % Initial quaternion (identity quaternion)
            q0 = [0;0;0;1];

            % check to test angular rates related blocks
            w_check = true;

            % Simulation time equal to an orbital period
            tf = 2*pi*sqrt((a/1000)^3/testCase.mu);

            % Run the simulation
            simulation = sim('Models\EoM_test.slx','SrcWorkspace','Current');

            % Actual angular velocity from the simulation
            w_actual = simulation.omega;

            % Expected angular velocity from
            % F. L. Markley and J. L. Crassidis, Fundamentals of Spacecraft
            % Attitude Determination and Control
            w_exp = -v0(2)/x0(1) * [zeros(size(w_actual,1),1),ones(size(w_actual,1),1), zeros(size(w_actual,1),1)];

            % Verify if the actual angular velocity matches the expected one within tolerance
            testCase.verifyEqual(w_actual,w_exp,'AbsTol',1e-8)
        end

        function test_motion(testCase)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Test the motion of an object based on its initial position,
            % velocity and constant acceleration. The function compares the
            % actual position and velocity from the simulation with the
            % expected ones computed from kinematic equations.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % Define initial conditions (initial position, velocity)
            x0 = [1;1;1];
            v0 = [1;1;1];

            % Final time of simulation (seconds)
            tf = 10;

            % Calculate expected velocity and position after time tf
            vf_exp = v0 + testCase.acc*tf;
            xf_exp = x0 + v0*tf + 0.5*testCase.acc*tf^2;

            % test blocks not related to the angular rates
            w_check = false;

            % Define initial quaternion it's necessary to run the simulink
            % model
            q0 = [0;0;0;1];

            % Run the simulation
            simulation = sim('Models\EoM_test.slx','SrcWorkspace','Current');

            % Extract final position and velocity from the simulation results
            xf = simulation.pos(end,:)';
            vf = simulation.vel(end,:)';

            % Verify if the final position and velocity match the expected values
            testCase.verifyEqual(xf,xf_exp,'RelTol',1e-6);
            testCase.verifyEqual(vf,vf_exp,'RelTol',1e-6);
        end

        function test_omega_quat(testCase)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Test the quaternion propagation.
            % This function compares the attitude from the simulation with 
            % the expected orientation computed deriving the rotation 
            % matrix from the LVLH to the inertial frame.
            %
            % Sources:
            % F. L. Markley and J. L. Crassidis, Fundamentals of Spacecraft
            % Attitude Determination and Control
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Define orbital parameters
            a = 7e6;
            e = 0.43;
            i = 23;
            OM = 235;
            om = 69;
            th = 42;

            % Convert orbital elements to position and velocity 
            [x0,v0] = keplerian2ijk(a,e,i,OM,om,th);
            x0 = x0/1000;  % convert to kilometers
            v0 = v0/1000; % convert to kilometers per second

            % check to test angular rates related blocks
            w_check = true;

            % Simulation time (orbital period)
            tf = 2*pi*sqrt((a/1000)^3/testCase.mu);
            
            % Initial attitude in DCM form
            h = cross(x0,v0);
            A2 = -h'/norm(h);
            A3 = -x0'/norm(x0);
            A1 = cross(A2,A3);
            A = [A1;A2;A3];

            % Convert DCM to quaternion for initial orientation
            q0_t = dcm2quat(A)';
            q0 = [q0_t(2:4);q0_t(1)];
            
            % Run the simulation
            simulation = sim('Models\EoM_test.slx','SrcWorkspace','Current');
            
            % Extract quaternion, position, and velocity from the 
            % simulation results
            q = [simulation.quat(:,4), simulation.quat(:,1:3)];
            pos = simulation.pos;
            vel = simulation.vel;
            
            % Convert the quaternions from the simulation to DCM
            actual_attitude = quat2dcm(q);

            % Initialize matrix for expected attitude (DCM)
            expected_attitude =  zeros(3,3,size(q,1));
            
            % Compute expected attitude from position and velocity
            for i = 1:size(q,1)
                h = cross(pos(i,:),vel(i,:));
                A2 = -h/norm(h);
                A3 = -pos(i,:)/norm(pos(i,:));
                A1 = cross(A2,A3);
                expected_attitude(:,:,i) = [A1;A2;A3];
            end
            
            % Verify if the actual attitude matches the expected attitude
            testCase.verifyEqual(actual_attitude,expected_attitude,'AbsTol',1e-8)

        end

    end

end