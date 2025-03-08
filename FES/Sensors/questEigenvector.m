classdef questEigenvector < matlab.System

    methods (Access = protected)

        function [q, rot_flag] = stepImpl(obj, S, Z)
          
            % Compute coefficients
            sigma = 0.5*trace(S);
            delta = det(S);
            k = S(2,2)*S(3,3) - S(2,3)*S(3,2) + ... 
                S(1,1)*S(3,3) - S(1,3)*S(3,1) + ...
                S(2,2)*S(1,1) - S(2,1)*S(1,2);    % tr(adj(S))

            % Compute maximum eigenvalue
            lambda = computeEigenvalue(obj, S, Z, sigma, k, delta);
            
            % Compute other coefficients
            alpha = lambda^2 -sigma^2 + k;
            beta = lambda - sigma;
            gamma = alpha * (lambda + sigma) - delta;

            if gamma<1e-6
                q = [0;0;0;1];
                rot_flag = true;
                return
            else
                X = (alpha*eye(3) + beta*S + S*S)*Z;
                q = 1/sqrt(gamma^2 + norm(X)^2) * [X; gamma];
                rot_flag = false;
            end

        end

    end

    methods
        
        function lambda = computeEigenvalue(obj, S, Z, sigma, k, delta)
            
            % Compute coefficients
            a = sigma^2 - k;
            b = sigma^2 + Z'*Z;
            c = delta + Z'*S*Z;
            d = Z'*S*S*Z;

            % Newton-Raphson
            lambda = 1;
            i = 0;
            n_max = 100;
            tol = 1e-10;
            error = 1;

            while error>tol && i<n_max
                f = lambda^4 - (a+b)*lambda^2 - c*lambda + a*b + c*sigma -d;
                df = 4*lambda^3 -2*(a+b)*lambda -c;
                lambda_prev = lambda;
                lambda = lambda - f/df;

                error = abs(lambda_prev-lambda);
                i = i+1;
            end

        end
    
    end

end
