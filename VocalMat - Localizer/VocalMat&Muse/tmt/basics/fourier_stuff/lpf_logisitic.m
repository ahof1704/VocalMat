function H_array=f(f,f_half,f_slope)

H_array=1./(1+exp((abs(f)-f_half)./f_slope));
