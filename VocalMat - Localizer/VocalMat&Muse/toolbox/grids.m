function [x_grid,y_grid]=grids(R,dx)

% figure grid bounds
x_min=dx*floor(min(R(1,:))/dx);
x_max=dx*ceil(max(R(1,:))/dx);
y_min=dx*floor(min(R(2,:))/dx);
y_max=dx*ceil(max(R(2,:))/dx);

% make some grids and stuff
xl=[x_min x_max];  % m
yl=[y_min y_max];  % m
x_line=(xl(1):dx:xl(2))';
y_line=(yl(1):dx:yl(2))';
n_x=length(x_line);
n_y=length(y_line);
x_grid=repmat(x_line ,[1 n_y]);
y_grid=repmat(y_line',[n_x 1]);

end
