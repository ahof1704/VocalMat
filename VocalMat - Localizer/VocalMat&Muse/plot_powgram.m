function plot_powgram(t,f,S,...
                      t_lim,f_lim,S_lim,...
                      plot_what,z_lim,...
                      title_str)

% plots the spectrogram in S, which should be in units of (native
% units)^2/Hz.  plot_what is a string that should be one of: 'power',
% 'amplitude', 'log-power', 'log-amplitude', or 'dB'.  If one of the log
% options, logs are base 10.  The limits of the the color scale can be
% set by either specifying S_lim or z_lim.  If z_lim is non-empty, it
% overrides S_lim, and specifies the limits in the units specified by
% plow_what.  If z_lim is empty, S_lim is used, which specifies the
% limits in the same units as S, which are then transformed according
% to plot_what.

% the plot is placed in the current axes

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

% convert to what they want plotted
if strcmpi(plot_what,'amplitude')
  z=sqrt(S);
  if isempty(z_lim)
    if isempty(S_lim)
      z_lim=[0 max(max(z))];
    else
      z_lim=sqrt(S_lim);
    end
  end    
elseif strcmpi(plot_what,'log-power')
  z=log10(S);
  if isempty(z_lim)
    if isempty(S_lim)
      z_lim=[min(min(z)) max(max(z))];
    else
      z_lim=log10(S_lim);
    end
  end    
elseif strcmpi(plot_what,'log-amplitude')
  z=0.5*log10(S);
  if isempty(z_lim)
    if isempty(S_lim)
      z_lim=[min(min(z)) max(max(z))];
    else
      z_lim=0.5*log10(S_lim);
    end
  end    
elseif strcmpi(plot_what,'db')
  z=10*log10(S);
  if isempty(z_lim)
    if isempty(S_lim)
      z_lim=[min(min(z)) max(max(z))];
    else
      z_lim=10*log10(S_lim);
    end
  end    
else
  % default to just plotting power
  z=S;
  if isempty(z_lim)
    if isempty(S_lim)
      z_lim=[0 max(max(S))];
    else
      z_lim=S_lim;
    end
  end    
end  

% make the plot
imagesc(t,f,z,z_lim);
axis xy;
%colormap(gray(256));
colormap(blue_to_yellow(256));
ylabel('Frequency (Hz)');
xlim(t_lim);
ylim(f_lim);
%h_cb=colorbar;
title(title_str,'interpreter','none');
xlabel('Time (s)');
%set(gcf,'CurrentAxes',h_cb);
%ylabel(sprintf('SD density (%s/Hz^{0.5})',units_str));
