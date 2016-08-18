function path_xy= ...
  path_xy_from_path_ij(path_ij,x_grid,y_grid)

[m,n]=size(x_grid);
x_min=x_grid(1,1);
x_max=x_grid(m,1);
y_min=y_grid(1,1);
y_max=y_grid(1,n);

n_paths=length(path_ij);
path_xy=cell(n_paths,1);
for i=1:n_paths
  path_ij_this=path_ij{i};
  [n_pts,~]=size(path_ij_this);
  path_xy_this=zeros(2,n_pts);
  path_xy_this(1,:)=interp1([1 m],[x_min x_max],path_ij_this(:,1))';
  path_xy_this(2,:)=interp1([1 n],[y_min y_max],path_ij_this(:,2))';
  path_xy{i}=path_xy_this;
end

end
