classdef SH_gradient < matlab.System
    % Compute the gradient of gravity field up to degree n and order m
    % Source:
    % R. G. Gottlieb, “Fast Gravity, Gravity Partials, Normalized Gravity,
    % Gravity Gradient Torque and Magnetic Field: Derivation, Code and Data.”
    % https://ntrs.nasa.gov/api/citations/19940025085/downloads/19940025085.pdf

    properties(Nontunable)
        body_coeffs;    % Gravity coefficients
        mu;             % Gravitational parameter
        ref_radius;     % Reference radius of the body
        nMax;           % Max degree of spherical harmonics
        mMax;           % Max order of spherical harmonics
    end

    properties(Access = private)
        eps;
        r;
        Pnm;
        Cm;
        Sm;
        csi;
        eta;
        zeta;
        P_coeffs;
        Cnm;
        Snm;
        Znm;
    end

    methods (Access = protected)

        function dg_dx = stepImpl(obj,x)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Compute the gradient of the gravity field using spherical
            % harmonics.
            %
            % Input:
            % obj: sphericalHarmonics - instance of the spherical harmonics
            %                           class
            % x: 3x1 double - position vector in the fixed frame
            %
            % Output:
            % dg_dx: 3x1 double - derivative of the gravity field with
            % respect to position
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % Extract coefficients
            obj.csi = obj.body_coeffs.csi.value;
            obj.eta = obj.body_coeffs.eta.value;
            obj.zeta = obj.body_coeffs.zeta.value;
            obj.P_coeffs = obj.body_coeffs.Pnm.value;
            obj.Cnm = obj.body_coeffs.Cnm.value;
            obj.Snm = obj.body_coeffs.Snm.value;
            obj.Znm = obj.body_coeffs.Znm.value;
            obj.r = norm(x);
            obj.eps = x(3)/obj.r;

            % Compute associated Legendre polynomials and cosine/sine terms
            obj.Pnm = computeP(obj);
            [obj.Cm, obj.Sm] = getCS(obj,x);

            % Compute coefficients
            H = getH(obj);
            Gamma = getGamma(obj);
            Lambda = Gamma + x(3)*H/obj.r;
            L = getL(obj);
            M = getM(obj);
            N = getN(obj);
            Omega = getOmega(obj);
            P = getP(obj);
            Q = getQ(obj);
            R = getR(obj);
            S = getS(obj);
            T = getT(obj);
            
            alpha = [Q;R;0];
            Y = [S;T;0];

            F = L + obj.eps*( M*obj.eps + 2*(P+H) ) + Lambda;
            G = -(M*obj.eps + P + H);
            d = obj.eps*alpha + Y;

            X = x/obj.r;

            % Compute derivatives
            dg_dx = obj.mu/obj.r^3 * ( [X, alpha]*[F G; G M] * [X';alpha'] + ...
                [X, d]*[0 -1;-1 0]*[X'; d'] + ...
                [N-Lambda, -Omega, Q; -Omega, -N-Lambda, R; Q, R, -Lambda ] );

        end

    end

    methods

        function [dg_dx] = getDerivative(self,x)
            % Wrapper for the stepImpl function

            dg_dx = stepImpl(self,x);
           

        end

        function Pnm = computeP(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Compute the associated Legendre polynomials up to degree nMax and
            % order mMax.
            %
            % Input:
            % obj: sphericalHarmonics - instance of the spherical harmonics class
            %
            % Output:
            % Pnm: (nMax+1) x (mMax+2) double - matrix of normalized associated
            %      Legendre polynomials
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % Initialize Legendre polynomial matrix
            Pnm = zeros(obj.nMax+1,obj.mMax+3);

            % Base cases
            Pnm(1,1) = obj.P_coeffs(1);
            Pnm(1,2) = obj.P_coeffs(2);
            Pnm(2,1) = obj.P_coeffs(3)*obj.eps;
            Pnm(2,2) = obj.P_coeffs(3);

            % Compute Legendre polynomials using recurrence relation
            for n = 2:obj.nMax
                for m = 0:obj.mMax
                    if n~=m
                        Pnm(n+1,m+1) = obj.csi(n+1,m+1)*obj.eps*Pnm(n,m+1) - ...
                            obj.eta(n+1,m+1)*Pnm(n-1,m+1);
                    else
                        Pnm(n+1,m+1) = Pnm(n,m)*sqrt( (2*n+1)/(2*n) );
                    end
                end
            end
        end

        function [Cm, Sm] = getCS(obj,x)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Compute the cosine and sine coefficients for spherical
            % harmonics expansion.
            %
            % Input:
            % obj: sphericalHarmonics - instance of the spherical harmonics
            %                           class
            % x  : 3x1 double - position vector in the fixed reference
            %                   frame
            %
            % Output:
            % Cm: (mMax+1) x 1 double - cosine coefficients
            % Sm: (mMax+1) x 1 double - sine coefficients
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % Initialize cosine and sine coefficient vectors
            Cm = zeros(obj.mMax+1,1);
            Sm = zeros(obj.mMax+1,1);

            % Base cases
            Cm(1) = 1;
            Sm(1) = 0;
            Cm(2) = x(1)/obj.r;
            Sm(2) = x(2)/obj.r;

            % Compute coefficients using recurrence relation
            for m = 2:obj.mMax
                Cm(m+1) = Cm(2)*Cm(m) - Sm(2)*Sm(m);
                Sm(m+1) = Sm(2)*Cm(m) + Cm(2)*Sm(m);
            end

        end

        function H = getH(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Compute the radial component H of the gravitational potential
            % expansion.
            %
            % Input:
            % obj: sphericalHarmonics - instance of the spherical harmonics
            %                           class
            %
            % Output:
            % H: double - component of the gravitational field
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % Initialize H to zero
            H = 0;

            % Compute H
            for n = 2:obj.nMax
                % Compute the first term of the sum
                H_n = obj.zeta(n+1,1)*obj.Cnm(n+1,1)*obj.Pnm(n+1,2);

                % Compute the remaining terms for m = 1 to n
                for m = 1:n
                    H_n = H_n + obj.zeta(n+1,m+1)*obj.Pnm(n+1,m+2)*...
                        ( obj.Cm(m+1)*obj.Cnm(n+1,m+1) + obj.Sm(m+1)*obj.Snm(n+1,m+1) );
                end

                % Accumulate the scaled sum into H
                H = H + (obj.ref_radius/obj.r)^n*H_n;
            end
        end

        function Gamma = getGamma(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Compute the vertical component Gamma of the gravitational
            % potential expansion.
            %
            % Input:
            % obj: sphericalHarmonics - instance of the spherical harmonics
            %                           class
            %
            % Output:
            % Gamma: double - vertical component of the gravitational
            %                 potential
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % Initialize Gamma to zero
            Gamma = 0;

            % Compute the summation for Gamma
            for n = 2:obj.nMax
                % Compute the first term of the sum
                G_n = obj.Cnm(n+1,1)*(n+1)*obj.Pnm(n+1,1);

                % Compute the remaining terms for m = 1 to n
                for m = 1:n
                    G_n = G_n + (1+n+m)*obj.Pnm(n+1,m+1)*...
                        ( obj.Cm(m+1)*obj.Cnm(n+1,m+1) + obj.Sm(m+1)*obj.Snm(n+1,m+1) );
                end

                % Accumulate the sum into Gamma
                Gamma = Gamma + (obj.ref_radius/obj.r)^n*G_n;
            end
        end

        function L = getL(obj)

            L = 0;
            for n = 2:obj.nMax

                Ln=0;
                for m = 0:n
                    Ln = Ln + (n+m+1)*(n+m+2)*obj.Pnm(n+1,m+1)*...
                        ( obj.Cm(m+1)*obj.Cnm(n+1,m+1) + obj.Sm(m+1)*obj.Snm(n+1,m+1) )/...
                        obj.r^m;
                end
                L = L + (obj.ref_radius/obj.r)^n*Ln;
            end

            L = L+2;

        end
        
        function M = getM(obj)

            M = 0;
            for n = 2:obj.nMax

                Mn=0;
                for m = 0:n
                    Mn = Mn + obj.Znm(n+1,m+1)*obj.Pnm(n+1,m+3)*...
                        ( obj.Cm(m+1)*obj.Cnm(n+1,m+1) + obj.Sm(m+1)*obj.Snm(n+1,m+1) )/...
                        obj.r^m;
                end
                M = M + (obj.ref_radius/obj.r)^n*Mn;
            end

        end
    
        function N = getN(obj)

            N = 0;
            for n = 2:obj.nMax

                Nn=0;
                for m = 2:n
                    Nn = Nn + obj.Pnm(n+1,m+1) * m*(m-1) *...
                        ( obj.Cm(m-1)*obj.Cnm(n+1,m+1) + obj.Sm(m-1)*obj.Snm(n+1,m+1) )/...
                        obj.r^(m-2);
                end
                N = N + (obj.ref_radius/obj.r)^n*Nn;
            end

        end

        function Omega = getOmega(obj)

            Omega = 0;
            for n = 2:obj.nMax

                Omega_n=0;
                for m = 2:n
                    Omega_n = Omega_n + obj.Pnm(n+1,m+1) * m*(m-1) *...
                        ( obj.Sm(m-1)*obj.Cnm(n+1,m+1) - obj.Cm(m-1)*obj.Snm(n+1,m+1) )/...
                        obj.r^(m-2);
                end
                Omega = Omega + (obj.ref_radius/obj.r)^n*Omega_n;
            end

        end

        function P = getP(obj)

            P = 0;
            for n = 2:obj.nMax

                Pn=0;
                for m = 0:n
                    Pn = Pn + obj.Pnm(n+1,m+2) * (m+n+1) * ...
                        ( obj.Cm(m+1)*obj.Cnm(n+1,m+1) + obj.Sm(m+1)*obj.Snm(n+1,m+1) )/...
                        obj.r^m;
                end
                P = P + (obj.ref_radius/obj.r)^n*Pn;
            end

        end
        
        function Q = getQ(obj)

            Q = 0;
            for n = 2:obj.nMax

                Qn=0;
                for m = 1:n
                    Qn = Qn + obj.Pnm(n+1,m+2) * m *...
                        ( obj.Cm(m)*obj.Cnm(n+1,m+1) + obj.Sm(m)*obj.Snm(n+1,m+1) )/...
                        obj.r^(m-1);
                end
                Q = Q + (obj.ref_radius/obj.r)^n*Qn;
            end

        end
        
        function R = getR(obj)

            R = 0;
            for n = 2:obj.nMax

                Rn=0;
                for m = 1:n
                    Rn = Rn + obj.Pnm(n+1,m+2) * m *...
                        ( obj.Sm(m)*obj.Cnm(n+1,m+1) - obj.Cm(m)*obj.Snm(n+1,m+1) )/...
                        obj.r^(m-1);
                end
                R = R + (obj.ref_radius/obj.r)^n*Rn;
            end
            R = -R;
        end
        
        function S = getS(obj)

            S = 0;
            for n = 2:obj.nMax

                Sn=0;
                for m = 1:n
                    Sn = Sn + obj.Pnm(n+1,m+1) * m * (m+n+1) *...
                        ( obj.Sm(m)*obj.Cnm(n+1,m+1) - obj.Cm(m)*obj.Snm(n+1,m+1) )/...
                        obj.r^(m-1);
                end
                S = S + (obj.ref_radius/obj.r)^n*Sn;
            end

        end
        
         function T = getT(obj)

            T = 0;
            for n = 2:obj.nMax

                Tn=0;
                for m = 1:n
                    Tn = Tn + obj.Pnm(n+1,m+1) * m * (m+n+1) *...
                        ( obj.Sm(m)*obj.Cnm(n+1,m+1) - obj.Cm(m)*obj.Snm(n+1,m+1) )/...
                        obj.r^(m-1);
                end
                T = T + (obj.ref_radius/obj.r)^n*Tn;
            end
            T= - T;

        end
    end

end
