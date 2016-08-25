function BW=fnEllipseToBinary(X,Y,A,B,Theta,ImSize)
N =10;
afTheta = linspace(0,2*pi,N);

fTheta = Theta + pi/2;
apt2f = [A * cos(afTheta); B * sin(afTheta)];
R = [ cos(fTheta), sin(fTheta);
    -sin(fTheta), cos(fTheta)];
apt2fFinal = double(R*apt2f + repmat([X;Y],1,N));
x=double(apt2fFinal(1,:));
y=double(apt2fFinal(2,:));

[xe,ye] = fnPrv_poly2edgelist(x,y);
BW = fnPrv_edgelist2mask(double(ImSize(1)),double(ImSize(2)),xe,ye);

return;

end