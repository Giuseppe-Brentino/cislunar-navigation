classdef sphericalHarmonics < matlab.System
    % Compute the detailed gravity field up to degree n and order m
    properties(Nontunable)
        body_coeffs;
        mu;
        ref_radius;
        nMax;
        mMax;
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

            % Initialize values
            obj.csi = obj.body_coeffs.csi.value;
            obj.eta = obj.body_coeffs.eta.value;
            obj.zeta = obj.body_coeffs.zeta.value;
            obj.P = obj.body_coeffs.Pnm.value;
            obj.Cnm = obj.body_coeffs.Cnm.value;
            obj.Snm= obj.body_coeffs.Snm.value;
            obj.r = norm(x);
            obj.eps = x(3)/obj.r;

            obj.Pnm = computeP(obj);
            [obj.Cm, obj.Sm] = getCS(obj,x);

            H = getH(obj);
            Gamma = getGamma(obj);
            J = getJ(obj);
            K = getK(obj);
            Lambda = Gamma + x(3)*H/obj.r;
            X = x/obj.r;
            g_sh = -obj.mu/obj.r^2*(Lambda*X - [J;K;H]);
            g_pm = -obj.mu/obj.r^2*X;

        end

    end
    %
    methods

        function [g, g_pm, g_sh] = getGravity(self,x)
            [g_pm, g_sh] = stepImpl(self,x);
            g = g_pm + g_sh;
        end

        function Pnm = computeP(obj)
            Pnm = zeros(obj.nMax+1,obj.mMax+2);
            Pnm(1,1) = obj.P(1);
            Pnm(1,2) = obj.P(2);
            Pnm(2,1) = obj.P(3)*obj.eps;
            Pnm(2,2) = obj.P(3);
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
            Cm = zeros(obj.mMax+1,1);
            Sm = zeros(obj.mMax+1,1);

            Cm(1) = 1;
            Sm(1) = 0;
            Cm(2) = x(1)/obj.r;
            Sm(2) = x(2)/obj.r;

            for m = 2:obj.mMax
                Cm(m+1) = Cm(2)*Cm(m) - Sm(2)*Sm(m);
                Sm(m+1) = Sm(2)*Cm(m) + Cm(2)*Sm(m);
            end
        end

        function H = getH(obj)
            H = 0;
            for n = 2:obj.nMax
                H_n = obj.zeta(n+1,1)*obj.Cnm(n+1,1)*obj.Pnm(n+1,2);
                for m = 1:n
                    H_n = H_n + obj.zeta(n+1,m+1)*obj.Pnm(n+1,m+2)*...
                        ( obj.Cm(m+1)*obj.Cnm(n+1,m+1) + obj.Sm(m+1)*obj.Snm(n+1,m+1) );
                end
                H = H + (obj.ref_radius/obj.r)^n*H_n;
            end
        end

        function Gamma = getGamma(obj)
            Gamma = 0;
            for n = 2:obj.nMax
                G_n = obj.Cnm(n+1,1)*(n+1)*obj.Pnm(n+1,1);
                for m = 1:n
                    G_n = G_n + (1+n+m)*obj.Pnm(n+1,m+1)*...
                        ( obj.Cm(m+1)*obj.Cnm(n+1,m+1) + obj.Sm(m+1)*obj.Snm(n+1,m+1) );
                end
                Gamma = Gamma + (obj.ref_radius/obj.r)^n*G_n;
            end
        end

        function J = getJ(obj)
            J=0;
            for n=2:obj.nMax
                J_n = 0;
                for m = 1:n
                    J_n = J_n + m*obj.Pnm(n+1,m+1) * ( obj.Cm(m)*obj.Cnm(n+1,m+1) + ...
                        obj.Sm(m)*obj.Snm(n+1,m+1) );
                end
                J = J + (obj.ref_radius/obj.r)^n*J_n;
            end
        end

        function K = getK(obj)
            K=0;
            for n=2:obj.nMax
                K_n = 0;
                for m = 1:n
                    K_n = K_n + m*obj.Pnm(n+1,m+1) * ( obj.Sm(m)*obj.Cnm(n+1,m+1) - ...
                        obj.Cm(m)*obj.Snm(n+1,m+1) );
                end
                K = K + (obj.ref_radius/obj.r)^n*(-K_n);
            end
        end
    end
end
