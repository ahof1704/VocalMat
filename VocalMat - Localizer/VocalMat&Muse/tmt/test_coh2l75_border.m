% show the colormap a prettier way
theta=(-pi:pi/100:+pi)';
r=(0:0.01:1)';
[r_grid,theta_grid]=meshgrid(r,theta);
z_grid=r_grid.*exp(i*theta_grid);
im=coh2l75_border((r_grid.^2).*exp(i*theta_grid));

figure;
polar_grid_simple;
hold on;
surf(real(z_grid),imag(z_grid),zeros(size(z_grid)),...
     im,...
     'EdgeColor','none');
hold off;

