classdef questEigenvector < matlab.System
    % Compute the attitude quaternion given the S matrix and the Z vector, as
    % described by:
    % M. D. Shuster and S. D. Oh, "Three-axis attitude determination from vector
    % observations"

    methods (Access = protected)

        function [q, rot_flag] = stepImpl(obj, S, Z)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Compute Optimal Quaternion using Davenport's q-method
            %
            % This function estimates the optimal quaternion (q) for 
            % attitude determination using the eigenvalue-based solution 
            % to Wahba's problem.
            %
            % INPUT:
            %   S        - 3x3 matrix related to the measurements
            %   Z        - 3x1 vector related to the measurements
            %
            % OUTPUT:
            %   q        - 4x1 optimal quaternion representing the attitude
            %   rot_flag - Boolean flag indicating if the consecutive 
            %              rotations method need to be used rotation was 
            %              detected
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % Compute coefficients
            sigma = 0.5*trace(S);
            delta = det(S);

            % Compute the sum of principal minors (trace of adjugate of S)
            k = S(2,2)*S(3,3) - S(2,3)*S(3,2) + ...
                S(1,1)*S(3,3) - S(1,3)*S(3,1) + ...
                S(2,2)*S(1,1) - S(2,1)*S(1,2);

            % Compute maximum eigenvalue
            lambda = computeEigenvalue(obj, S, Z, sigma, k, delta);

            % Compute intermediate coefficients
            alpha = lambda^2 -sigma^2 + k;
            beta = lambda - sigma;
            gamma = alpha * (lambda + sigma) - delta;
            
            % Check if the solution is valid
            if gamma<1e-6
                % If gamma is too small, return the flag to use the
                % consecutive rotations method
                q = [0;0;0;1];
                rot_flag = true;
                return
            else
                % Compute the optimal quaternion
                X = (alpha*eye(3) + beta*S + S*S)*Z;
                q = 1/sqrt(gamma^2 + norm(X)^2) * [X; gamma];
                rot_flag = false;
            end

        end

    end

    methods

        function lambda = computeEigenvalue(obj, S, Z, sigma, k, delta)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Compute the biggest eigenvalue using Newton-Raphson Method
            %
            % This function computes the eigenvalue (lambda) by solving a
            % polynomial equation using the Newton-Raphson iterative method.
            %
            % INPUT:
            %   S      - Symmetric matrix related to the system
            %   Z      - Vector involved in the computation
            %   sigma  - Scalar parameter
            %   k      - Scalar parameter
            %   delta  - Scalar parameter
            %
            % OUTPUT:
            %   lambda - Computed eigenvalue
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % Compute coefficients
            a = sigma^2 - k;
            b = sigma^2 + Z'*Z;
            c = delta + Z'*S*Z;
            d = Z'*S*S*Z;

            % Initialize Newton-Raphson iteration
            lambda = 1;       % Initial guess
            i = 0;            % Iteration counter
            n_max = 100;      % Maximum number of iterations
            tol = 1e-10;      % Convergence tolerance
            error = 1;        % Initial error

            % Perform Newton-Raphson iterations
            while error>tol && i<n_max

                % Compute function value and its derivative
                f = lambda^4 - (a+b)*lambda^2 - c*lambda + a*b + c*sigma -d;
                df = 4*lambda^3 -2*(a+b)*lambda -c;

                % Update lambda using Newton-Raphson formula
                lambda_prev = lambda;
                lambda = lambda - f/df;

                % Compute error for convergence check
                error = abs(lambda_prev-lambda);

                % Increment iteration counter
                i = i+1;
            end

        end

    end

end
