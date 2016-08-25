function fDist = fnEllipseEllipseDist(x1,y1,a1,b1,t1,x2,y2,a2,b2,t2)
% Compute an approximated distance between two ellipses by quantization...
if isnan(x1) || isnan(x2)
    fDist = NaN;
    return;
end;
N = 60;

% Generate points on circle
%fTheta = fTheta + pi/2;
afTheta = linspace(0,2*pi,N);%2*pi*[0:N]/N;

apt2f1 = [a1 * cos(afTheta); b1 * sin(afTheta)];
apt2f2 = [a2 * cos(afTheta); b2 * sin(afTheta)];

R1 = [ cos(t1), sin(t1);
    -sin(t1), cos(t1)];

R2 = [ cos(t2), sin(t2);
    -sin(t2), cos(t2)];

apt2fFinal1 = R1*apt2f1 + repmat([x1;y1],1,N);
apt2fFinal2 = R2*apt2f2 + repmat([x2;y2],1,N);
[afDist,aiMinIndex] = fndllPointPointDist(double(apt2fFinal1),double(apt2fFinal2));
fDist = single(min(afDist));
return;

figure(11);
clf;hold on;
plot(apt2fFinal1(1,:),apt2fFinal1(2,:),'b.');
plot(apt2fFinal2(1,:),apt2fFinal2(2,:),'b.');
axis equal
