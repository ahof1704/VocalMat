function cmap=bipolar(varargin)

if nargin<1
  n=256;
else
  n=varargin{1};
end

% n is the number of colors
clr_pos=[0 1 0];
clr_neg=[1 0 0];

clr_pos_lab=srgb2lab(clr_pos);
clr_neg_lab=srgb2lab(clr_neg);

n_half=ceil(n/2);
scale=linspace(0,1,n_half)';
cmap_pos_lab=repmat(scale,[1 3]).*repmat(clr_pos_lab,[n_half 1]);
cmap_neg_lab=repmat(scale,[1 3]).*repmat(clr_neg_lab,[n_half 1]);
if mod(n,2)==0
  cmap_lab=[flipud(cmap_neg_lab);cmap_pos_lab];
else
  cmap_lab=[flipud(cmap_neg_lab); 0 0 0; cmap_pos_lab];
end
cmap=lab2srgb(cmap_lab);
cmap=max(min(cmap,1),0);
