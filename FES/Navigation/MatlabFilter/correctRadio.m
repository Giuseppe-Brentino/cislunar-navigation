function [x,P] = correctRadio(x_prev,P_prev,R,y_meas)

% expected range
dx = x_prev(1:3) - x_prev(7:9);
y_hat(1) = norm(dx);

% expected range rate
dv = x_prev(4:6)-x_prev(10:12);
u = dx/y_hat(1);
y_hat(2) = dx'*dv/norm(dx);

H = zeros(2,12);

H(1,:) = [dx'./y_hat(1), zeros(1,3), -dx'./y_hat(1), zeros(1,3)];
H(2,1:3) = dv/y_hat(1) - y_hat(2)/y_hat(1)^2*dx;
H(2,4:6) = u;
H(2,7:9) = -H(2,1:3);
H(2,10:12) = -u;

K = P_prev*H'/(H*P_prev*H'+ R);
x = x_prev + K*(y_meas*1e-3 - y_hat)';
P = (eye(12)-K*H)*P_prev*(eye(12)-K*H)' + K*R*K';

end

