function [x,P] = correctRangeRate(x_prev,P_prev,R,y_meas)

dx = x_prev(1:3)-x_prev(7:9);
dv = x_prev(4:6)-x_prev(10:12);
u = dx/norm(dx);
y_hat = dx'*dv/norm(dx);

H = zeros(1,12);
H(1:3) = dv/norm(dx) - y_hat/norm(dx)^2*dx;
H(4:6) = u;
H(7:9) = -H(1:3);
H(10:12) = -u;


K = P_prev*H'/(H*P_prev*H'+ R);
x = x_prev + K*(y_meas*1e-3 - y_hat);
P = (eye(12)-K*H)*P_prev*(eye(12)-K*H)' + K*R*K';


end

