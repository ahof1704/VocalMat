function perturbed_x = f(x,scale)

sigma=scale*abs(x);
perturbed_x=normrnd(x,sigma);

