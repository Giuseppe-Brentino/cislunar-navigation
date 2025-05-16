function [x,P] = correctRange(x_prev,P_prev,R,y_meas)

coord_diff = x_prev(1:3) - x_prev(7:9);
y_hat = norm(x_prev(1:3) - x_prev(7:9));

H = [coord_diff'./y_hat, zeros(1,3), -coord_diff'./y_hat, zeros(1,3)];

K = P_prev*H'/(H*P_prev*H'+R);

x = x_prev + K*(y_meas*1e-3 - y_hat);

P = (eye(12)-K*H)*P_prev*(eye(12)-K*H)' + K*R*K';


end

