function Pn = computeProcessNoise(dt,PSI, R_bi, R_sb, Q)
% computeProcessNoise  Symbolic process noise via per-channel rank-1 updates
% Input:
%   dt    - timestep (symbolic)
%   F12,...,F54, F89 - symbolic 3×3 block matrices and scalar
%   R_bi, R_sb       - symbolic 3×3 rotation matrices
%   q     - 19×1 symbolic vector of noise variances
% Output:
%   Pn - 23×23 symbolic process noise matrix

    % --- Construct G symbolically ---
    G = sym(zeros(23,20));
    G(4:6,7:9)     = R_bi * R_sb;
    G(7:9,13:15)   = -R_sb;

    % --- Compute A = F*G via nonzero blocks ---
    H = sym(zeros(23,20));
    H(1:3,1:3) = PSI(1:3,4:6);
    H(1:3,7:9) = PSI(1:3,4:6)*G(4:6,7:9);      %3x3
    H(4:6,1:3) = eye(3);            %3x3
    H(4:6,7:9) = G(4:6,7:9);               %3x3
    H(4:6,10:12) = PSI(4:6,16:18);          %3x3
    H(4:6,13:15) = PSI(4:6,7:9)*G(7:9,13:15);      %3x3
    H(7:9,13:15) = PSI(7:9,7:9)*G(7:9,13:15);   %3x3
    H(7:9,16:18) = PSI(7:9,19:21);          %3x3
    H(10:12,4:6) = PSI(10:12,13:15);          %3x3
    H(13:15,4:6) = eye(3);            %3x3 
    H(16:18,10:12) = eye(3);            %3x3
    H(19:21,16:18) = eye(3);            %3x3
    H(22:23,19:20) = PSI(22:23,22:23);  

    % --- Build process noise via rank-1 updates ---
  
    Pn = sym(zeros(23,23));

    for i = 1:size(Q,1)
        h = H(:,i);
        Pn= Pn + Q(i,i) * (h * h');
    end

    Pn = simplify(dt * Pn);

 

end

