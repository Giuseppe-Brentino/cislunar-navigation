function [g,dgdx] = gottliebDgDx(mu, re, x, c, s, nax, max)


[xi,eta,zeta,upsilon,p,alpha,beta,nrdiag]  = getcoeffs(nax);


r = norm(x);
ri = 1/r;
xovr = x(1)*ri;
yovr = x(2)*ri;
zovr = x(3)*ri;
ep = zovr;
reor = re*ri;
reorn = reor;
muor = mu*ri;
muor2 = muor*ri;
muor3 = muor2*ri;

sum_init = 1;

ctil(1) = 1;
ctil(2) = xovr;
stil(1) = 0;
stil(2) = yovr;

sumv = sum_init;
sumh = 0;
sumj = 0;
sumk = 0;
sumgam = sum_init;
summ = 0;
sumn = 0;
sumo = 0;
sump = 0;
sumq = 0;
sumr = 0;
sums = 0;
sumt = 0;
suml = 2*sum_init;

p(2,1) = sqrt(3)*ep;

for n = 2:nax

    ni = n+1;

    reorn = reorn*reor;

    pn = p(ni,:);
    cn = c(ni,:);
    sn = s(ni,:);
    zn = zeta(ni,:);
    xin = xi(ni,:);
    etn = eta(ni,:);

    nm1 = n-1;
    nm1i = nm1+1;
    nm2 = n-2;
    nm2i = nm2+1;

    pnm1 = p(nm1i,:);
    pnm2 = p(nm2i,:);

    pn(1) = alpha(ni)*ep*pnm1(1) - beta(ni)*pnm2(1);
    pn(nm1i) = ep*nrdiag(ni);
    pn(2) = xin(2)*ep*pnm1(2)-etn(2)*pnm2(2);
    upsn = upsilon(ni,:);
    np1 = n+1;
    cn0 = cn(1);

    sumv_n = pn(1)*cn0;
    sumh_n = pn(2)*cn0*zn(1);
    summ_n = pn(3)*cn0*upsn(1);
    sumgam_n = sumv_n*np1;
    sump_n = sumh_n * np1;
    suml_n = sumgam_n * (np1+1);

    if max > 0
        for m = 2:nm2
            mi = m+1;
            pn(mi) = xin(mi)*ep*pnm1(mi)-etn(mi)*pnm2(mi);
        end

        sumj_n = 0;
        sumk_n = 0;
        sumn_n = 0;
        sumo_n = 0;
        sumq_n = 0;
        sumr_n = 0;
        sums_n = 0;
        sumt_n = 0;
        ctil(ni) = ctil(2)*ctil(nm1i)-stil(2)*stil(nm1i);
        stil(ni) = stil(2)*ctil(nm1i) + ctil(2)*stil(nm1i);

        if n<max
            lim = n;
        else
            lim = max;
        end

        for m = 1:lim
            mi = m+1;
            mm1 = m-1;
            mp1 = m+1;
            mp2 = m+2;
            npmp1 = n+mp1;

            pnm = pn(mi);
            pnmp1 = pn(mp1+1);
            cnm = cn(mi);
            snm = sn(mi);
            ctmm1 = ctil(mm1+1);
            stmm1 = stil(mm1+1);

            mxpnm = m*pnm;
            bnmtil = cnm*ctil(mi) + snm*stil(mi);
            bnmtm1 = cnm*ctmm1 + snm*stmm1;
            anmtm1 = cnm*stmm1 - snm*ctmm1;

            pnmbnm = pnm*bnmtil;
            sumv_n = sumv_n + pnmbnm;

            if m<n
                z_pnmp1 = zn(mi)*pn(mp1+1);
                sumh_n = sumh_n + z_pnmp1*bnmtil;
                sump_n = sump_n + npmp1*z_pnmp1*bnmtil;
                sumq_n = sumq_n + m*z_pnmp1*bnmtm1;
                sumr_n = sumr_n - m*z_pnmp1*anmtm1;
            end
            sumgam_n = sumgam_n + npmp1*pnmbnm;
            sumj_n = sumj_n + mxpnm*bnmtm1;
            sumk_n = sumk_n - mxpnm*anmtm1;
            suml_n = suml_n + npmp1*(mp1+np1)*pnmbnm;
            summ_n = summ_n + pn(mp2+1)*bnmtil*upsn(mi);
            sums_n = sums_n + npmp1*mxpnm*bnmtm1;
            sumt_n = sumt_n - npmp1*mxpnm*anmtm1;

            if m>=2
                mm2 = m-2;
                sumn_n = sumn_n + mm1*mxpnm*(cnm*ctil(mm2+1)+snm*stil(mm2+1));
                sumo_n = sumo_n + mm1*mxpnm*(cnm*stil(mm2+1)-snm*ctil(mm2+1));
            end

        end

        sumj = sumj + reorn * sumj_n;
        sumk = sumk + reorn * sumk_n;
        sumn = sumn + reorn * sumn_n;
        sumo = sumo + reorn * sumo_n;
        sumq = sumq + reorn * sumq_n;
        sumr = sumr + reorn * sumr_n;
        sums = sums + reorn * sums_n;
        sumt = sumt + reorn * sumt_n;
    end

    sumv = sumv+reorn*sumv_n;
    sumh = sumh + reorn*sumh_n;
    sumgam = sumgam + reorn*sumgam_n;
    suml = suml + reorn*suml_n;
    summ = summ + reorn*summ_n;
    sump = sump + reorn*sump_n;
end

pot = muor*sumv;
lambda = sumgam + ep*sumh;

% force
g(1) = -muor2 * (lambda*xovr-sumj);
g(2) = -muor2 * (lambda*yovr-sumk);
g(3) = -muor2 * (lambda*zovr-sumh);

% derivative
gg = -(summ*ep+sump+sumh);
ff = suml+lambda+ep*(sump+sumh-gg);
d1 = ep*sumq+sums;
d2 = ep*sumr+sumt;

dgdx = zeros(3);

dgdx(1,1) = muor3*((ff*xovr-2*d1)*xovr-lambda+sumn);
dgdx(2,2) = muor3*((ff*yovr-2*d2)*yovr-lambda-sumn);
dgdx(3,3) = muor3*((ff*zovr+2*gg)*zovr-lambda+summ);
temp = muor3*((ff*yovr-d2)*xovr-d1*yovr-sumo);
dgdx(1,2) = temp;
dgdx(2,1) = temp;
temp = muor3*((ff*xovr-d1)*zovr+gg*xovr+sumq);
dgdx(1,3) = temp;
dgdx(3,1) = temp;
temp = muor3*((ff*yovr-d2)*zovr+gg*yovr+sumr);
dgdx(2,3) = temp;
dgdx(3,2) = temp;

end

function [xi,eta,zeta,upsilon,p,alpha,beta,nrdiag] = getcoeffs(nax)
xi = zeros(nax+1,nax);
eta = zeros(nax+1,nax);
zeta = zeros(nax+1,nax+1);
upsilon = zeros(nax+1,nax+1);
p = zeros(nax+1,nax+3);
alpha = zeros(nax+1,1);
beta = zeros(nax+1,1);
nrdiag = zeros(nax+1,1);

% xi
for n = 2:nax
    for m = 0:n-1
        num = (2*n-1)*(2*n+1);
        den = (n+m)*(n-m);
        xi(n+1,m+1) = sqrt(num/den);
    end
end

% eta
for n = 2:nax
    for m = 0:n-1
        num = (2*n+1)*(n+m-1)*(n-m-1);
        den = (n+m)*(n-m)*(2*n-3);
        if num == 0
            eta(n+1,m+1) = 0;
        else
            eta(n+1,m+1) = sqrt(num/den);
        end
    end
end

% zeta
for n = 2:nax
    for m = 0:n
        if m==0
            num = n*(n+1);
            zeta(n+1,1) = sqrt(num/2);
        else
            num = (n-m)*(n+m+1);
            if num == 0
                zeta(n+1,m+1) = 0;
            else
                zeta(n+1,m+1) = sqrt(num);
            end
        end
    end
end

%upsilon
for n = 2:nax
    for m = 0:n
        if m==0
            num = n*(n-1)*(n+1)*(n+2);
            upsilon(n+1,1) = sqrt(num/2);
        else
            num = (n-m)*(n+m+1)*(n-m-1)*(n+m+2);
            if num == 0
                upsilon(n+1,m+1) = 0;
            else
                upsilon(n+1,m+1) = sqrt(num);
            end
        end
    end
end

% p, alpha, beta, nrdiag
p(1,1) = 1; 
p(1,2) = 0;
p(1,3) = 0;
p(2,2) = sqrt(3);
p(2,3) = 0;
p(2,4) = 0;

for n = 2:nax
    ni = n+1;
    p(ni,ni) = sqrt((2*n+1)/(2*n))*p(n,n);
    nrdiag(ni) = sqrt(2*n+1)*p(n,n);
    num = (2*n+1)*(2*n-1);
    alpha(ni) = sqrt(num)/n;
    num = 2*n+1;
    den = 2*n-3;
    beta(ni) = sqrt(num/den)*(n-1)/n;
end

end











