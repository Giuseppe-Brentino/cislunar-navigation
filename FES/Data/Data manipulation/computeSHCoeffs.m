function [csi, eta, zeta, Cnm, Snm, TestData]= computeSHCoeffs(n_max,m_max)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute the spherical harmonics coefficients (csi, eta, zeta, Cnm, Snm) 
% based on the input maximum order and degree (n_max, m_max). The function 
% reads spherical harmonic data, computes necessary values, and organizes
% them for further use.
%
% Input:
% n_max: scalar - maximum degree of spherical harmonics
% m_max: scalar - maximum order of spherical harmonics
%
% Output:
% csi: (n_max+1) x (m_max+1) matrix - precomputed csi coefficients
% eta: (n_max+1) x (m_max+1) matrix - precomputed eta coefficients
% zeta: (n_max+1) x (m_max+1) matrix - precomputed zeta coefficients
% Cnm: (n_max+1) x (m_max+1) matrix - precomputed Cnm coefficients
% Snm: (n_max+1) x (m_max+1) matrix - precomputed Snm coefficients
% TestData: struct - contains precomputed spherical harmonic data for testing
%
% Source:
% R. G. Gottlieb, “Fast Gravity, Gravity Partials, Normalized Gravity, 
% Gravity Gradient Torque and Magnetic Field: Derivation, Code and Data.”
% https://ntrs.nasa.gov/api/citations/19940025085/downloads/19940025085.pdf
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Get the full path of the current function file
currentFile = mfilename('fullpath');

% Get the folder containing the function
functionFolder = fileparts(currentFile);

% Get the parent folder of that folder
folder = fileparts(functionFolder);

% Read the full table of spherical harmonic data
glgm3150_full = readmatrix(strcat(folder,'/gglp_glgm3150_sha.csv'));

% Filter the data based on the input maximum degrees and orders
glgm3150 = glgm3150_full( (glgm3150_full(:,1)<=m_max) & ...
    (glgm3150_full(:,2)<=n_max), 1:4);

% Initialize matrices for csi, eta, zeta, Cnm, Snm
csi = zeros(n_max+1,m_max+1);
eta = zeros(n_max+1,m_max+1);
zeta = zeros(n_max+1,m_max+1);
Cnm = zeros(n_max+1,m_max+1);
Snm = zeros(n_max+1,m_max+1);

% Compute csi, eta, zeta, and extract Cnm, Snm values
for i = 1:size(glgm3150,1)
    n = glgm3150(i,1);
    m = glgm3150(i,2);

    % Calculate csi and eta for m < n
    if m<n
        csi(n+1,m+1) = sqrt( (2*n-1)*(2*n+1) / ((n+m)*(n-m)) );
        eta(n+1,m+1) = sqrt( (n+m-1)*(2*n+1)*(n-m-1) / ...
            ( (n+m)*(n-m)*(2*n-3) ) );
    end

    % Calculate zeta for m = 0 or m > 0
    if m == 0
        zeta(n+1,1) = sqrt(n*(n+1)/2);
    else
        zeta(n+1,m+1) = sqrt( (n-m)*(n+m+1) );
    end

    % Extract Cnm and Snm coefficients
    Cnm(n+1,m+1) = glgm3150( glgm3150(:,1)==n & glgm3150(:,2)==m ,3);
    Snm(n+1,m+1) = glgm3150( glgm3150(:,1)==n & glgm3150(:,2)==m ,4);
end

%% Save data for unit test
% Store values for testing
n = 5; % Example degree for test data
m = 5;  % Example order for test data
TestData.SH.n.value = n;
TestData.SH.m.value = m;
TestData.SH.csi.value = csi(1:n+1,1:n+1);
TestData.SH.eta.value = eta(1:n+1,1:n+1);
TestData.SH.zeta.value = zeta(1:n+1,1:n+1);
TestData.SH.Pnm.value = [1, 0, sqrt(3)];
TestData.SH.mu.value = 398600.47*1e9;
TestData.SH.ref_radius.value = 6378139;

% Read data for the test
tab = readmatrix("GEM10_gfc.csv");
tab = tab(tab(:,2)<=n,2:5);

% Initialize matrices for test data Cnm and Snm
Ctest = zeros(n_max+1,m_max+1);
Stest = zeros(n_max+1,m_max+1);

% Extract test data for Cnm and Snm
for i = 1:size(tab,1)
    n = tab(i,1);
    m = tab(i,2);

    Ctest(n+1,m+1) = tab( tab(:,1)==n & tab(:,2)==m ,3);
    Stest(n+1,m+1) = tab( tab(:,1)==n & tab(:,2)==m ,4);
end

% Store the test coefficients in TestData
TestData.SH.Cnm.value = Ctest;
TestData.SH.Snm.value = Stest;

end
