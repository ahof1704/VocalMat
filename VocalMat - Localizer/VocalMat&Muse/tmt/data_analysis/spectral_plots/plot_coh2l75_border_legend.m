function plot_coh2l75_border_legend(C_mag_thresh)

% make the image
theta=(-pi:pi/100:+pi)';
r=(0:0.01:1)';
[r_grid,theta_grid]=meshgrid(r,theta);
z_grid=r_grid.*exp(1i*theta_grid);
im=coh2l75_border(r_grid.*exp(1i*theta_grid),C_mag_thresh);

% plot it
plot_polar_grid_simple;
hold on;
surf(real(z_grid),imag(z_grid),repmat(-1,size(z_grid)),...
     im,...
     'EdgeColor','none');
hold off;
if isunix() && ~ismac()
  view(0,89.999);  % workaround for matlab linux opengl bug
end

% % make a circle to show significance
% theta=(-pi:pi/50:+pi)';
% r=repmat(C_mag_thresh,size(theta));
% x=r.*cos(theta);
% y=r.*sin(theta);
% line(x,y,'linestyle','--','color',0.75*[1 1 1]);
