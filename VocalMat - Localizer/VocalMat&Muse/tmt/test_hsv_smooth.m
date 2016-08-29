% generate the full colormap
n_colors=256;
x=linspace(0,1,n_colors+1)';
x=x(1:end-1);
cmap=hsv_of_x(x);

% show it
figure;
colormap(cmap);
colorbar;

% make a colormap with inter-color spacings equal
n_colors=256;
cmap=hsv_smooth(n_colors);

% show the colormap
figure;
colormap(cmap);
colorbar;

