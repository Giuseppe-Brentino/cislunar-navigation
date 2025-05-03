%% Get gravity data

% Run simulation
out = sim("GravityModel.slx");

% get gravity error
main_err = squeeze(out.main_diff);
beacon_err = squeeze(out.beacon_diff);

%% Define F

% Define symbolic 3x3 blocks
syms F12 F21 F23 F26 [3 3] real
syms F33 F37 F45 F54 [3 3] real

% Define symbolic scalar
syms F89 real

% Define timestep
syms dt real

% Initialize a 23x23 symbolic zero matrix
F = sym(zeros(23));

% Helper function to convert block indices to actual row/col indices
block = @(i) (3*(i-1)+1):(3*i);

% Insert 3x3 symbolic blocks in appropriate positions
F(block(1), block(2)) = F12;
F(block(2), block(1)) = F21;
F(block(2), block(3)) = F23;
F(block(2), block(6)) = F26;
F(block(3), block(3)) = F33;
F(block(3), block(7)) = F37;
F(block(4), block(5)) = F45;
F(block(5), block(4)) = F54;

% Insert scalar symbolic block
F(22,23) = F89;

PSI = sym(eye(23)) + F*dt;
%% Define Q
syms eta_gm eta_gb eta_acc eta_accB eta_gyro eta_gyroB eta_clockD eta_clockA real

Q = sym(zeros(19));

Q(block(1), block(1)) = diag(eta_gm*ones(3,1));
Q(block(2), block(2)) = diag(eta_gb*ones(3,1));
Q(block(3), block(3)) = diag(eta_acc*ones(3,1));
Q(block(4), block(4)) = diag(eta_accB*ones(3,1));
Q(block(5), block(5)) = diag(eta_gyro*ones(3,1));
Q(block(6), block(6)) = diag(eta_gyroB*ones(3,1));
Q(18,18) = eta_clockD;
Q(19,19) = eta_clockA;

%% Define G
syms R_bi R_sb [3 3] real

G = sym(zeros(23,19));

G(block(2), block(1)) = eye(3);
G(block(2), block(3)) = R_bi*R_sb;
G(block(3), block(5)) = -R_sb;
G(block(5), block(2)) = eye(3);
G(block(6), block(4)) = eye(3);
G(block(7), block(6)) = eye(3);
G(22,18) = 1;
G(23,19) = 1;
%% Process noise

process_noise = simplify((PSI*G)*Q*dt*(PSI*G)');
save process_noise process_noise


