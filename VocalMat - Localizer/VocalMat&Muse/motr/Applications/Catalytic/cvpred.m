function [xpred,ypred,thetapred] = cvpred(x2,y2,theta2,x1,y1,theta1)

dx = x1 - x2;
dy = y1 - y2;
dtheta = modrange(theta1-theta2,-pi,pi);
xpred = x1 + dx;
ypred = y1 + dy;
thetapred = modrange(theta1+dtheta,-pi,pi);