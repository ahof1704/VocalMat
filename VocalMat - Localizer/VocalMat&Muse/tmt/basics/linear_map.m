function y=f(xi,yi,x)

m=(yi(end)-yi(1))/(xi(end)-xi(1));
y=m*(x-xi(1))+yi(1);
