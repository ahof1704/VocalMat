function [h,h_a,h_cb]=figure_powgram(t,f,S,...
                                     t_lim,f_lim,S_lim,...
                                     plot_what,z_lim,...
                                     title_str,...
                                     units_str)

% plots the spectrogram in S, which should be in units of (native
% units)^2/Hz.  plot_what is a string that should be one of: 'power',
% 'amplitude', 'log-power', 'log-amplitude', or 'dB'.  If one of the log
% options, logs are base 10.  The limits of the the color scale can be
% set by either specifying S_lim or z_lim.  If z_lim is non-empty, it
% overrides S_lim, and specifies the limits in the units specified by
% plow_what.  If z_lim is empty, S_lim is used, which specifies the
% limits in the same units as S, which are then transformed according
% to plot_what.

% units_str contains the units of the original signal, for labeling
% the colorbar

% the plot is placed in a new figure, and a colorbar is added.

  
% deal with arguments
if nargin<4 || isempty(t_lim)
  dt=(t(end)-t(1))/(length(t)-1);
  t_lim=[t(1)-dt/2 t(end)+dt/2];
end
if nargin<5 || isempty(f_lim)
  f_lim=[f(1) f(end)];
end
if nargin<6
  S_lim=[];
end
if nargin<7 || isempty(plot_what)
  plot_what='power';
end
if nargin<8 
  z_lim=[];
end
if nargin<9
  title_str='';
end
if nargin<10 || isempty(units_str)
  % assume original units were pure
  units_str='1';
end

% figure out the colorbar label
if strcmpi(plot_what,'amplitude')
  colorbar_label=sprintf('Amplitude density (%s/Hz^{0.5})',units_str);
elseif strcmpi(plot_what,'log-power')
  colorbar_label=sprintf('Log power density (%s^2/Hz)',units_str);
elseif strcmpi(plot_what,'log-amplitude')
  colorbar_label=sprintf('Log amplitude density (%s/Hz^{0.5})',units_str);
elseif strcmpi(plot_what,'db')
  colorbar_label=sprintf('Power density (%s^2/Hz, dB)',units_str);
else
  % default to just plotting power
  colorbar_label=sprintf('Power density (%s^2/Hz)',units_str);
end  

% make the figure
h=figure;
h_a=axes;
plot_powgram(t,f,S,...
             t_lim,f_lim,S_lim,...
             plot_what,z_lim,...
             title_str)
h_cb=colorbar;
set(gcf,'CurrentAxes',h_cb);
ylabel(colorbar_label);
