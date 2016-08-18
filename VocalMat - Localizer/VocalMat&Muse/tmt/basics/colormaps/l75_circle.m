function color_map=f(n_colors)

% generates a MATLAB colormap that is a circle in CIE Lab/Lch
% colorspace.  The circle has constant L (Lightness) and constant c
% (chroma), and raster-scans all values of h (hue).
%
% It's an interesting colormap, which actually seems to have constant
% "brightness" and very gradual and uniform change of color.
% However, it isn't very saturated, so the colors all look a bit
% washed-out.

if nargin<1
  n_colors=256;
end

n_samples=n_colors+1;
L=75; c=38;
L_grid=repmat(L,[n_samples 1]); 
c_grid=repmat(c,[n_samples 1]);  % chroma
h_grid=linspace(0,2*pi,n_samples)';  % hue
Lch_grid=[L_grid c_grid h_grid];
Lab_grid=[L_grid c_grid.*cos(h_grid) c_grid.*sin(h_grid)];
sRGB_grid=lab2srgb(Lab_grid);
color_map=sRGB_grid(1:end-1,:);

