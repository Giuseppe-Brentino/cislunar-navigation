classdef SH_nav < matlab.System
    % Compute the gravity field and its gradient up to degree n and order m
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


    methods (Access = protected)

        function [gravity, dgdx] = stepImpl(obj,x)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Compute the gradient of the gravity field using spherical
            % harmonics.
            %
            % Input:
            % obj: sphericalHarmonics - instance of the spherical harmonics
            %                           class
            % x: 3x1 double - position vector in the planet-fixed frame
            %
            % Output:
            % gravity: 3x1 double - gravity vector
            % dg_dx: 3x3 double - derivative of the gravity field with
            % respect to position
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % Extract data for better readability
            xi = obj.body_coeffs.csi.value;
            eta = obj.body_coeffs.eta.value;
            zeta = obj.body_coeffs.zeta.value;
            c = obj.body_coeffs.Cnm.value;
            s = obj.body_coeffs.Snm.value;
            upsilon = obj.body_coeffs.Znm.value;
            nax = obj.nMax;
            max = obj.mMax;

            % Initialize variables
            re = obj.ref_radius;% reference radius of the planet 
            r = norm(x);        % distance from the center of the planet

            % Zero norm protection
            if r<=0
                x = [1e-6;1e-6;1e-6;];
                r = norm(x);
            end

            ri = 1/r;           % inverse if the distance
            xovr = x(1)*ri;     % x position over radius
            yovr = x(2)*ri;     % y position over radius
            zovr = x(3)*ri;     % z position over radius
            ep = zovr;
            reor = re*ri;       % reference radius over distance
            reorn = reor;       % reference radius over distance to the power of n
            muor = obj.mu*ri;       % mu over distance
            muor2 = muor*ri;    % mu over distance, squared
            muor3 = muor2*ri;   % mu over distance, cubed

            % Compute legendre polynomials
            pol = obj.computePol(nax,max,ep,xi,eta);

            % Initialize coefficients
            ctil = zeros(nax+1,1);
            stil = zeros(nax+1,1);
            ctil(1) = 1;
            ctil(2) = xovr;
            stil(1) = 0;
            stil(2) = yovr;

            % Initialize parameters
            sum_init = 1;

            V = sum_init;
            H = 0;
            J = 0;
            K = 0;
            G = sum_init;
            M = 0;
            N = 0;
            O = 0;
            P = 0;
            Q = 0;
            R = 0;
            S = 0;
            T = 0;
            L = 2*sum_init;

            % Iterate over the degrees
            for n = 2:nax

                ni = n+1; % index corresponding to n

                reorn = reorn*reor; % update reorn

                pn = pol(ni,:);     % n-th row of the legendre polynomials matrix
                cn = c(ni,:);       % n-th row of the cosine coefficients matrix
                sn = s(ni,:);       % n-th row of the sine coefficients matrix
                zn = zeta(ni,:);    % n-th row of the zeta parameters matrix

                upsn = upsilon(ni,:); % n-th row of the upsilon parameters matrix
                np1 = n+1;            % n+1 set as variable for convinience
                cn0 = cn(1);          % first element of the cn array

                % Initialize components of each terms of the summation over m
                V_n = pn(1)*cn0;
                H_n = pn(2)*cn0*zn(1);
                M_n = pn(3)*cn0*upsn(1);
                G_n = V_n*np1;
                P_n = H_n * np1;
                L_n = G_n * (np1+1);
                J_n = 0;
                K_n = 0;
                N_n = 0;
                O_n = 0;
                Q_n = 0;
                R_n = 0;
                S_n = 0;
                T_n = 0;

                % compute n-dependent values of the ctil, stil arraus
                ctil(ni) = ctil(2)*ctil(n)-stil(2)*stil(n);
                stil(ni) = stil(2)*ctil(n) + ctil(2)*stil(n);

                % Iterate over m, remembering that m must be always lower than n
                if n<max
                    lim = n;
                else
                    lim = max;
                end

                for m = 1:lim
                    mi = m+1;  % index corresponding to m

                    % define as variables some recurring operations
                    mm1 = m-1;
                    mp1 = m+1;
                    mp2 = m+2;
                    npmp1 = n+mp1;

                    pnm = pn(mi);       % m-th element of the pn array
                    cnm = cn(mi);       % m-th element of the cn array
                    snm = sn(mi);       % m-th element of the sn array
                    ctmm1 = ctil(m);    % (m-1)-th element of the ctil array
                    stmm1 = stil(m);    % (m-1)-th element of the stil array

                    % define as variables some recurring operations
                    mxpnm = m*pnm;
                    bnmtil = cnm*ctil(mi) + snm*stil(mi);
                    bnmtm1 = cnm*ctmm1 + snm*stmm1;
                    anmtm1 = cnm*stmm1 - snm*ctmm1;
                    pnmbnm = pnm*bnmtil;

                    % Increment parameters that change for every m
                    V_n = V_n + pnmbnm;
                    G_n = G_n + npmp1*pnmbnm;
                    J_n = J_n + mxpnm*bnmtm1;
                    K_n = K_n - mxpnm*anmtm1;
                    L_n = L_n + npmp1*(mp1+np1)*pnmbnm;
                    M_n = M_n + pn(mp2+1)*bnmtil*upsn(mi);
                    S_n = S_n + npmp1*mxpnm*bnmtm1;
                    T_n = T_n - npmp1*mxpnm*anmtm1;
                    

                    % Increment parameters that change if m is less then n
                    if m<n
                        z_pnmp1 = zn(mi)*pn(mp1+1);
                        H_n = H_n + z_pnmp1*bnmtil;
                        P_n = P_n + npmp1*z_pnmp1*bnmtil;
                        Q_n = Q_n + m*z_pnmp1*bnmtm1;
                        R_n = R_n - m*z_pnmp1*anmtm1;
                    end

                    % Increment parameters that change if m is at greater or equal then 2
                    if m>=2
                        mm2 = m-2;
                        N_n = N_n + mm1*mxpnm*(cnm*ctil(mm2+1)+snm*stil(mm2+1));
                        O_n = O_n + mm1*mxpnm*(cnm*stil(mm2+1)-snm*ctil(mm2+1));
                    end

                end

                % Update each term
                G = G + reorn * G_n;
                H = H + reorn * H_n;
                J = J + reorn * J_n;
                K = K + reorn * K_n;
                L = L + reorn * L_n;
                M = M + reorn * M_n;
                N = N + reorn * N_n;
                O = O + reorn * O_n;
                P = P + reorn * P_n;
                Q = Q + reorn * Q_n;
                R = R + reorn * R_n;
                S = S + reorn * S_n;
                T = T + reorn * T_n;
                V = V + reorn * V_n;

            end

            lambda = G + ep*H;

            % ------------------- Compute gravity vector ------------------

            gravity = zeros(3,1);
            gravity(1) = -muor2 * (lambda*xovr-J);
            gravity(2) = -muor2 * (lambda*yovr-K);
            gravity(3) = -muor2 * (lambda*zovr-H);

            % ------ Compute first derivatives of the gravity vector ------

            % define some useful parameters
            gg = -(M*ep+P+H);
            ff = L+lambda+ep*(P+H-gg);
            d1 = ep*Q+S;
            d2 = ep*R+T;

            % Initialize Jacobian matrix
            dgdx = zeros(3);

            % Populate the Jacobian matrix
            dgdx(1,1) = muor3*((ff*xovr-2*d1)*xovr-lambda+N);
            dgdx(2,2) = muor3*((ff*yovr-2*d2)*yovr-lambda-N);
            dgdx(3,3) = muor3*((ff*zovr+2*gg)*zovr-lambda+M);
            temp = muor3*((ff*yovr-d2)*xovr-d1*yovr-O);
            dgdx(1,2) = temp;
            dgdx(2,1) = temp;
            temp = muor3*((ff*xovr-d1)*zovr+gg*xovr+Q);
            dgdx(1,3) = temp;
            dgdx(3,1) = temp;
            temp = muor3*((ff*yovr-d2)*zovr+gg*yovr+R);
            dgdx(2,3) = temp;
            dgdx(3,2) = temp;

        end

    end

    methods

        function [g, dg_dx] = getDerivative(self,x)
            % Wrapper for the stepImpl function

            [g,dg_dx] = stepImpl(self,x);


        end

        function pol = computePol(obj,nax,max,ep,xi,eta)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Compute the associated Legendre polynomials up to degree nMax and
            % order mMax.
            %
            % Input:
            % obj: sphericalHarmonics - instance of the spherical harmonics class
            %
            % Output:
            % pol: (nMax+1) x (mMax+2) double - matrix of normalized associated
            %      Legendre polynomials
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % Initialize Legendre polynomial matrix
            pol = zeros(nax+1,max+3);

            % Base cases
            pol(1,1) = 1;
            pol(1,2) = 0;
            pol(2,2) = sqrt(3);
            pol(2,1) = pol(2,2)*ep;
            
            % Compute Legendre polynomials using recurrence relation
            for n = 2:nax
                for m = 0:max
                    if n~=m
                        pol(n+1,m+1) = xi(n+1,m+1)*ep*pol(n,m+1) - ...
                            eta(n+1,m+1)*pol(n-1,m+1);
                    else
                        pol(n+1,m+1) = pol(n,m)*sqrt( (2*n+1)/(2*n) );
                    end
                end
            end
        end

    end

end
