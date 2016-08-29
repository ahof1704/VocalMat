% generate the full colormap
n_colors=256;
x=linspace(0,1,n_colors)';
cmap=hv_of_x(x);

% show it
figure;
colormap(cmap);
colorbar;

% make a colormap with inter-color spacings equal
n_colors=256;
cmap=hv_smooth(n_colors);

% show the colormap
figure;
colormap(cmap);
colorbar;
