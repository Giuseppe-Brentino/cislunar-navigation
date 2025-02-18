function [csi, eta, zeta, Cnm, Snm, TestData]= computeSHCoeffs(n_max,m_max)

% Get the full path of the current function file
currentFile = mfilename('fullpath');
% Get the folder containing the function
functionFolder = fileparts(currentFile);
% Get the parent folder of that folder
folder = fileparts(functionFolder);

% Read table
glgm3150_full = readmatrix(strcat(folder,'/gglp_glgm3150_sha.csv'));
glgm3150 = glgm3150_full( (glgm3150_full(:,1)<=m_max) & ...
    (glgm3150_full(:,2)<=n_max), 1:4);

% compute csi, eta and extract Cnm, Snm
csi = zeros(n_max+1,m_max+1);
eta = zeros(n_max+1,m_max+1);
zeta = zeros(n_max+1,m_max+1);
Cnm = zeros(n_max+1,m_max+1);
Snm = zeros(n_max+1,m_max+1);

for i = 1:size(glgm3150,1)
    n = glgm3150(i,1);
    m = glgm3150(i,2);

    % csi, eta
    if m<n
        csi(n+1,m+1) = sqrt( (2*n-1)*(2*n+1) / ((n+m)*(n-m)) );
        eta(n+1,m+1) = sqrt( (n+m-1)*(2*n+1)*(n-m-1) / ...
            ( (n+m)*(n-m)*(2*n-3) ) );
    end

    % zeta
    if m == 0
        zeta(n+1,1) = sqrt(n*(n+1)/2);
    else
        zeta(n+1,m+1) = sqrt( (n-m)*(n+m+1) );
    end
    %Cnm, Snm
    Cnm(n+1,m+1) = glgm3150( glgm3150(:,1)==n & glgm3150(:,2)==m ,3);
    Snm(n+1,m+1) = glgm3150( glgm3150(:,1)==n & glgm3150(:,2)==m ,4);
end

%% Save data for unit test
n = 5;
m = 5;
TestData.SH.n.value = n;
TestData.SH.m.value = m;
TestData.SH.csi.value = csi(1:n+1,1:n+1);
TestData.SH.eta.value = eta(1:n+1,1:n+1);
TestData.SH.zeta.value = zeta(1:n+1,1:n+1);
TestData.SH.Pnm.value = [1, 0, sqrt(3)];
TestData.SH.mu.value = 398600.47*1e9;
TestData.SH.ref_radius.value = 6378139;

tab = readmatrix("GEM10_gfc.csv");
tab = tab(tab(:,2)<=n,2:5);
Ctest = zeros(n_max+1,m_max+1);
Stest = zeros(n_max+1,m_max+1);

for i = 1:size(tab,1)
    n = tab(i,1);
    m = tab(i,2);
    %Cnm, Snm
    Ctest(n+1,m+1) = tab( tab(:,1)==n & tab(:,2)==m ,3);
    Stest(n+1,m+1) = tab( tab(:,1)==n & tab(:,2)==m ,4);
end
TestData.SH.Cnm.value = Ctest;
TestData.SH.Snm.value = Stest;


