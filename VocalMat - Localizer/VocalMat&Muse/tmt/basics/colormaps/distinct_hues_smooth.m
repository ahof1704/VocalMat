function cmap = f(n_colors,hue0)

% this creates a sequence of colors to be used for labeling distinct 
% "classes" of things
% the idea is that subsequent colors are quite distinct
% the sequence is specified in the HSV colorspace
% all traces have the same satuaration and brightness
% the hue sequence is determined by taking 256 evenly spaced samples
%   from 0 to 1, and then shuffling them in such a way that each
%   hue gets mapped to the 'bit-reversed' hue.
% this means that subsequent colors tend to be far apart in hue, 
%   which is the desired effect.
%
% this version uses the Lab colorspace to make the colormap more
% perceptually smooth.
% right now, there's no way to darken the colors, e.g. to get good contrast
% on a white background

if nargin<1 || isempty(n_colors)
  n_colors=256;
end
if nargin<2 || isempty(hue0)
  hue0=0;
end
n_really=2^nextpow2(n_colors);
indices=(0:n_really-1)';
indices=bitrevorder(indices);  % bitrevorder in SP toolbox
cmap=hsv_smooth(n_really,hue0);
cmap=cmap(indices+1,:);
cmap=cmap(1:n_colors,:);

% % let's see the colors
% figure;
% colormap(cmap);
% colorbar;
