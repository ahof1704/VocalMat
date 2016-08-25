function cmap = f(n_colors,hue0,value)

% this creates a sequence of colors to be used for traces
% the idea is that subsequent colors are quite distinct
% the sequence is specified in the HSV colorspace
% all traces have the same satuaration and brightness
% the hue sequence is determined by taking 256 evenly spaced samples
%   from 0 to 1, and then shuffling them in such a way that each
%   hue gets mapped to the 'bit-reversed' hue.
% this means that subsequent colors tend to be far apart in hue, 
%   which is the desired effect.

if nargin<1 || isempty(n_colors)
  n_colors=256;
end
if nargin<2 || isempty(hue0)
  hue0=0;
end
if nargin<3 || isempty(value)
  value=0.9;  % so they have decent contrast on a white background
end
n_really=2^nextpow2(n_colors);
indices=(0:n_really-1)';
indices=bitrevorder(indices);  % bitrevorder in SP toolbox
% for j=1:n_colors
%   indices(j)=bit_reverse(indices(j));
% end
cmap_hsv=...
  [ mod(hue0+double(indices)/n_really,1) ...
    repmat(1,[n_really 1]) ...
    repmat(value,[n_really 1]) ];
cmap_hsv=cmap_hsv(1:n_colors,:);
cmap=hsv2rgb(cmap_hsv);

% % let's see the colors
% figure;
% colormap(cmap);
% colorbar;

  