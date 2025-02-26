classdef test_tbp < matlab.unittest.TestCase

    methods(Test)
        % Test methods

        function test_2bp(testCase)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Test the Two-Body Problem (2BP) propagation.
            % This function verifies whether the position and velocity at
            % the end of the simulation match the  initial values, as the
            % simulation time is set to be equal to the orbital period.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Gravitational parameter (Earth) in km^3/s^2
            mu = 398600;

            % Define initial orbital element
            a = 6786230;
            ecc = .01;
            incl = 52;
            RAAN = 95;
            argp = 93;
            nu = 10;

            % Convert orbital elements to position and velocity vectors
            [r0,v0] = keplerian2ijk(a,ecc,incl,RAAN,argp,nu);
            r0=r0/1000; % Convert position to kilometers
            v0=v0/1000; % Convert velocity to km/s

            % Compute orbital period (seconds)
            period = 2*pi*sqrt((a/1000)^3/mu);

            % Run the simulation
            model = sim("./Models/tbp_test.slx",'SrcWorkspace','current');
            
            % Extract final position and velocity from the simulation
            rf = model.pos.Data(end,:);
            vf = model.vel.Data(end,:);

            % Verify that the final state matches the initial state within tolerance
            verifyEqual(testCase,[r0;v0],[rf';vf'],'RelTol',1e-4)
        end

    end

end

