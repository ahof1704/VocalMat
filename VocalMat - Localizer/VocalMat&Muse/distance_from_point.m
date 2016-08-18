function d=distance_from_point(x_grid,y_grid,r)
x=r(1);
y=r(2);
d=hypot(x_grid-x,y_grid-y);
end
