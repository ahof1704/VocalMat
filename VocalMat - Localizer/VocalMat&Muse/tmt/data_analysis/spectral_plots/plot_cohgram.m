function plot_cohgram(t,f,C_mag,C_phase,...
                      t_lim,f_lim,...
                      title_str,...
                      C_mag_thresh)

% plot a cohereogram in the current axes                          
                          
% deal with arguments
if nargin<5 || isempty(t_lim)
  dt=(t(end)-t(1))/(length(t)-1);
  t_lim=[t(1)-dt/2 t(end)+dt/2];
end
if nargin<6 || isempty(f_lim)
  f_lim=[f(1) f(end)];
end
if nargin<7
  title_str='';
end
if nargin<8 || isempty(C_mag_thresh)
  C_mag_thresh=0;
end

% convert to complex coherence
C=C_mag.*exp(1i*C_phase);  

% do the cohereogram itself
%figure;
%axes;
im=coh2l75_border(C,C_mag_thresh);
image(t,f,im);
axis xy;
ylim([f_lim]);
xlim([t_lim]);
ylabel('Frequency (Hz)');
xlabel('Time (s)');
title(title_str,'interpreter','none');

% % draw the colorbar
% cmap_phase=l75_border(256);  % to show abs(C)==1 colors
% colorbar_axes_h=colorbar;
% colorbar_image_h=findobj(colorbar_axes_h,'Tag','TMW_COLORBAR');
% set(colorbar_image_h,'YData',[-180 +180]);
% set(colorbar_axes_h,'YLim',[-180 +180]);
% set(colorbar_image_h,'CData',reshape(cmap_phase,[256 1 3]));
% set(colorbar_axes_h,'YTick',[-180 -90 0 +90 +180]);
% set(gcf,'CurrentAxes',colorbar_axes_h);
% ylabel('Phase (deg), for |C|=1');
