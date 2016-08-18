function cmap=blue_to_yellow(n)

% deal with args
if nargin<1 || isempty(n)
  n=256;
end

% n is the number of colors
clr_pos=[1 1 0];  % yellow
clr_neg=[0 0 1];  % blue

clr_one_lab=srgb2lab(clr_pos);
clr_zero_lab=srgb2lab(clr_neg);

scale=linspace(0,1,n)';
cmap_lab=interp1([0;1],[clr_zero_lab;clr_one_lab],scale);
cmap=lab2srgb(cmap_lab);
cmap=max(min(cmap,1),0);
