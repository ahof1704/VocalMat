function [t_extrema,sign_extrema,i_extrema]=f(t,y,T_sigma_filter)

% y should be a col vector
n_t=length(t);
dt=(t(end)-t(1))/(n_t-1);
sigma_filter=T_sigma_filter/dt;
extrema_array=extrema(y,sigma_filter);
[i_extrema,dummy,sign_extrema]=find(extrema_array);
t_extrema=t(i_extrema);
