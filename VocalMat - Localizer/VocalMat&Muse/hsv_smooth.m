function cmap=f(n_colors,hue0);

% deal w/ args
if nargin<2 || isempty(hue0)
  hue0=0;
end

% generate a non-smooth colormap on a very fine grid
% calculate the path length, and from that get the phase for each
% point on the fine grid
n_samples=4002;  % want divisible by 6
x=mod(linspace(hue0,hue0+1,n_samples+1)',1);
clr=hsv_of_x(x);
clr_lab=srgb2lab(clr);
ds=dist_lab(clr_lab(1:end-1,:),clr_lab(2:end,:));
s=[0 ; cumsum(ds)];
phase=s/s(end);  % normalized path length == phase in cycles

% make a colormap with inter-color spacings equal to circum/n_colors
phase_samples=linspace(0,1,n_colors+1)';
phase_samples=phase_samples(1:end-1);
x_samples=interp1(phase,x,phase_samples,'linear');
cmap=hsv_of_x(x_samples);

