function in=in_ellipse(x_grid,y_grid,r_center,a_vec,b)

in=false(size(x_grid));
x_grid_cent=x_grid-r_center(1);
y_grid_cent=y_grid-r_center(2);
a=norm(a_vec);
a_hat=a_vec/a;
b_hat=[-a_hat(2);a_hat(1)];  % rotate a_hat +90 deg
a_proj=a_hat(1)*x_grid_cent+a_hat(2)*y_grid_cent;
b_proj=b_hat(1)*x_grid_cent+b_hat(2)*y_grid_cent;
in= (a_proj/a).^2+(b_proj/b).^2<1 ;

end
