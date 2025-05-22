function [x,P] = correctRange(x_prev,P_prev,R,y_meas)

coord_diff = x_prev(1:3) - x_prev(7:9);
y_hat = norm(x_prev(1:3) - x_prev(7:9));

H = [coord_diff'./y_hat, zeros(1,3), -coord_diff'./y_hat, zeros(1,3)];

% Underweight
u = coord_diff./y_hat;
M =  eye(3)-u*u';
Hess = 1/y_hat * [M zeros(3) -M zeros(3);zeros(3,12); -M zeros(3) M zeros(3); zeros(3,12)];
c = 3*norm(Hess)^2;
tP = c/2 * trace(P_prev([1:3,7:9],[1:3,7:9]))^2;
if tP > 0.2*R
    beta =  1e1*tP / (trace(H*P_prev*H'));
else
    beta = 0;
end
beta = 0;

% % check for outliers
% if (y_meas*1e-3 - y_hat)^2/( (1+beta)*H*P_prev*H'+ R) <= chi2inv(0.99,10)
    K = P_prev*H'/( (1+beta)*H*P_prev*H'+ R);
    x = x_prev + K*(y_meas*1e-3 - y_hat);
    P = (eye(12)-K*H)*P_prev*(eye(12)-K*H)' + K*(R+beta*H*P_prev*H')*K';
% else
%     x = x_prev;
%     P = P_prev;

end

