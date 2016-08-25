function clr=f(r,theta)

% r, theta should be col vectors, with theta in units of radians

persistent n_colors n_samples clr_samples_lab theta_grid;

if isempty(n_colors)
  n_colors=4000;
  clr_samples_lab=srgb2lab(l75_border(n_colors));
  n_samples=n_colors+1;
  clr_samples_lab=[clr_samples_lab ; clr_samples_lab(1,:)];
  theta_grid=linspace(-pi,+pi,n_samples)';
end
theta=angle(exp(1i*theta));  % want theta between -pi and +pi
clr_lab=interp1(theta_grid,clr_samples_lab,theta,'*linear');
clr_lab=clr_lab.*repmat(r,[1 3]);
clr=lab2srgb(clr_lab);
clr=max(0,min(1,clr));
