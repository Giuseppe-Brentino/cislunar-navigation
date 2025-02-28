classdef sphericalHarmonics < matlab.System
    % Compute the detailed gravity field up to degree n and order m
    % Source:
    % R. G. Gottlieb, “Fast Gravity, Gravity Partials, Normalized Gravity,
    % Gravity Gradient Torque and Magnetic Field: Derivation, Code and Data.”
    % https://ntrs.nasa.gov/api/citations/19940025085/downloads/19940025085.pdf

    properties(Nontunable)
        body_coeffs;     % Gravity coefficients
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
        P;
        Cnm;
        Snm;
    end

    methods (Access = protected)

        function [g_pm, g_sh] = stepImpl(obj,x)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Compute the gravity field contributions using spherical
            % harmonics.
            %
            % Input:
            % obj: sphericalHarmonics - instance of the spherical harmonics
            %                           class
            % x: 3x1 double - position vector in the fixed frame
            %
            % Output:
            % g_pm: 3x1 double - acceleration due to the point mass gravity
            % g_sh: 3x1 double - acceleration due to spherical harmonics
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % Extract coefficients
            obj.csi = obj.body_coeffs.csi.value;
            obj.eta = obj.body_coeffs.eta.value;
            obj.zeta = obj.body_coeffs.zeta.value;
            obj.P = obj.body_coeffs.Pnm.value;
            obj.Cnm = obj.body_coeffs.Cnm.value;
            obj.Snm= obj.body_coeffs.Snm.value;
            obj.r = norm(x);
            obj.eps = x(3)/obj.r;

            % Compute associated Legendre polynomials and cosine/sine terms
            obj.Pnm = computeP(obj);
            [obj.Cm, obj.Sm] = getCS(obj,x);

            % Compute gravity components
            H = getH(obj);
            Gamma = getGamma(obj);
            J = getJ(obj);
            K = getK(obj);

            % Compute acceleration due to spherical harmonics and point mass
            Lambda = Gamma + x(3)*H/obj.r;
            X = x/obj.r;

            g_sh = -obj.mu/obj.r^2*(Lambda*X - [J;K;H]);
            g_pm = -obj.mu/obj.r^2*X;

        end

    end

    methods

        function [g, g_pm, g_sh] = getGravity(self,x)
            % Wrapper for the stepImpl function

            [g_pm, g_sh] = stepImpl(self,x);
            g = g_pm + g_sh;

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
            Pnm = zeros(obj.nMax+1,obj.mMax+2);

            % Base cases
            Pnm(1,1) = obj.P(1);
            Pnm(1,2) = obj.P(2);
            Pnm(2,1) = obj.P(3)*obj.eps;
            Pnm(2,2) = obj.P(3);

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

        function J = getJ(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Compute the J component of the gravitational potential
            % expansion.
            %
            % Input:
            % obj: sphericalHarmonics - instance of the spherical harmonics
            %                           class
            %
            % Output:
            % J: double - J component of the gravitational acceleration
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % Initialize J to zero
            J=0;

            % Compute the summation for J
            for n=2:obj.nMax

                % Initialize J_n for the current degree n
                J_n = 0;

                % Compute the summation for order m
                for m = 1:n
                    J_n = J_n + m*obj.Pnm(n+1,m+1) * ( obj.Cm(m)*obj.Cnm(n+1,m+1) + ...
                        obj.Sm(m)*obj.Snm(n+1,m+1) );
                end

                % Accumulate the scaled sum into J
                J = J + (obj.ref_radius/obj.r)^n*J_n;

            end
        end

        function K = getK(obj)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Compute the K component of the gravitational potential
            % expansion.
            %
            % Input:
            % obj: sphericalHarmonics - instance of the spherical harmonics
            %                           class
            %
            % Output:
            % K: double - K component of the gravitational acceleration
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % Initialize K to zero
            K=0;

            % Compute the summation for K
            for n=2:obj.nMax
                % Initialize K_n for the current degree n
                K_n = 0;

                % Compute the summation for order m
                for m = 1:n
                    K_n = K_n + m*obj.Pnm(n+1,m+1) * ( obj.Sm(m)*obj.Cnm(n+1,m+1) - ...
                        obj.Cm(m)*obj.Snm(n+1,m+1) );
                end
                % Accumulate the scaled sum into K
                K = K + (obj.ref_radius/obj.r)^n*(-K_n);
            end
        end

    end

end
