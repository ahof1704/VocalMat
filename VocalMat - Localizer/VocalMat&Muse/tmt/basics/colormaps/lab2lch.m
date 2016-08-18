function lch=f(lab)

L=lab(:,1);
a=lab(:,2);
b=lab(:,3);
c=sqrt(a.^2+b.^2);  % the radius
h=atan2(b,a);  % the angle
lch=[L c h];
