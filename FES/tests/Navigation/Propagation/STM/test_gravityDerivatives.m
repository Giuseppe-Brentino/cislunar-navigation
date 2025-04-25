classdef test_gravityDerivatives < matlab.unittest.TestCase



    methods(Test)
        % Test methods

        function test_2bp(testCase)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Test correctness of the Two-Body Problem (2BP) Jacobian.
            % Compares the symbolic Jacobian of gravitational acceleration
            % against the output from the "2bp gravity derivative wrt x"
            % custom block.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % Initialize symbolic variables
            syms mu_s real
            syms x_s [3,1] real

            % Define symbolic gravitational acceleration
            g = -mu_s * (x_s / norm(x_s)^3);

            % Compute Jacobian symbolically
            expected_sym = simplify(jacobian(g, x_s));

            % Assign numerical values
            mu = 398600;
            x = [1e4; 7e3; -8e3];

            % Substitute symbolic variables with numbers
            expected_dgdx_sym = subs(expected_sym, [mu_s, x_s.'], [mu, x.']);

            % Convert symbolic matrix to double
            expected_dgdx = double(expected_dgdx_sym);

            % Run simulation
            simulation = sim('Models/TBPDerivative.slx','srcWorkspace','current');
            actual_dgdx = simulation.dgdx;

            % Verify the Jacobian matches the symbolic computation
            testCase.verifyEqual(actual_dgdx, expected_dgdx,'AbsTol',eps)
        end

        function test_3rdBody(testCase)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Test correctness of third-body gravitational Jacobian.
            % Compares the symbolic Jacobian of the third-body gravity
            % model with the result from the "3rd body gravity derivative 
            % wrt x" custom block.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % Initialize symbolic variables
            syms mu_s real
            syms x_s xe_s [3,1] real

            % Define symbolic gravitational acceleration
            g = -mu_s*((x_s-xe_s)/norm(x_s-xe_s)^3 + xe_s/norm(xe_s)^3);

            % Compute Jacobian symbolically
            expected_sym = simplify(jacobian(g, x_s));

            % Assign numerical values
            mu = 398600;
            x = [1e4; 7e3; -8e3];
            x_e = [1e6; 2e6; -1e6];

            % Substitute symbolic variables with numbers
            expected_dgdx_sym = subs(expected_sym, [mu_s, x_s.',xe_s.'], [mu, x.', x_e.']);

            % Convert symbolic matrix to double
            expected_dgdx = double(expected_dgdx_sym);

            % Run simulation
            simulation = sim('Models/thirdBodyGDerivative.slx','srcWorkspace','current');
            actual_dgdx = simulation.dgdx;

            % Verify the Jacobian matches the symbolic computation
            testCase.verifyEqual(actual_dgdx, expected_dgdx,'AbsTol',eps)
        end

    end

end