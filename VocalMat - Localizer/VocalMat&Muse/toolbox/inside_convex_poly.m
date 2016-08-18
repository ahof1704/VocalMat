function in=inside_convex_poly(x_grid,y_grid,r_poly)

% Returns a logical 2d array of the same size as x_grid and y_grid that
% is true if the point is inside or on the boundary of the 2d convex polygon
% with vertices in the cols of r_poly.  It is assumed that the vertices are
% listed in counterclockwise order.

in=true(size(x_grid));
n_vertex=size(r_poly,2);
r_poly=[r_poly r_poly(:,1)];
for i=1:n_vertex
%for i=1
  r=r_poly(:,i);
  v=r_poly(:,i+1)-r;
  dx=x_grid-r(1);
  dy=y_grid-r(2);
  dot=-dx*v(2)+dy*v(1);
  in_left_half_plane= dot>=0;
  in=in&in_left_half_plane;
end

% % make a plot
% xl=[x_grid(1,1) x_grid(end,1)];
% yl=[y_grid(1,1) y_grid(1,end)];  
% figure('color','w');
% axes;
% imagesc(100*xl,100*yl,in',[0 1]);
% colormap(gray);
% hold on;
% plot(100*r_poly(1,:),100*r_poly(2,:),'.r','markersize',6*3);
% hold off;
% colorbar;
% xlim(xl);
% ylim(yl);
% axis image;
% axis xy;
% xlabel('x (cm)');
% ylabel('y (cm)');
% drawnow;

end
