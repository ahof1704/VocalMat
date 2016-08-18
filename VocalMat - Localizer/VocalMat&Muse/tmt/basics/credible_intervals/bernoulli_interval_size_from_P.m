function result=f(Fl,p_grid,cdf,perunityity_of_ci)

Fu=Fl+perunityity_of_ci;
l=interp1(cdf,p_grid,Fl,'linear');
u=interp1(cdf,p_grid,Fu,'linear');
result=(u-l).^2;
