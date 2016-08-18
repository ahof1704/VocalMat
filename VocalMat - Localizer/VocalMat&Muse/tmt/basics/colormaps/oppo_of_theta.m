function clr=f(theta)

% theta should a row vector, and in units of radians

persistent n_colors n_samples clr_samples theta_grid;

if isempty(n_colors)
  n_colors=4000;
  clr_samples=oppo_cmap(n_colors);
  n_samples=n_colors+1;
  clr_samples=[clr_samples ; clr_samples(1,:)];
  theta_grid=linspace(-pi,+pi,n_samples)';
end
theta=angle(exp(i*theta));  % want theta between -pi and +pi
clr=interp1(theta_grid,clr_samples,theta,'*linear');

