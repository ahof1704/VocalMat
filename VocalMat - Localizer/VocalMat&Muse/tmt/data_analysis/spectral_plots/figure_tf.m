function [h_fig,...
          h_mag_axes,h_phase_axes,...
          h_mag,h_phase,...
          h_mag_ci,h_phase_ci]=...
  figure_tf(f,H_mag,H_phase,...
            H_mag_ci,H_phase_ci,...
            f_lim,H_mag_lim,H_phase_lim,...
            title_str)

% figure_tf(f,H_mag,H_phase) plots the given transfer function
% in a new figure

% deal with args
if nargin<4
  H_mag_ci=[];
end
if nargin<5
  H_phase_ci=[];
end
if nargin<6 || isempty(f_lim)
  f_lim=[0 f(end)];
end
if nargin<7 || isempty(H_mag_lim)
  H_mag_lim=[0 1.05*max(H_mag)];
end
if nargin<8 || isempty(H_phase_lim)
  H_phase_lim=[-180 +180];
end
if nargin<9
  title_str='';
end

% make the figure
h_fig=figure;

% make the plots
h_mag_axes=subplot(2,1,1);
if ~isempty(H_mag_ci)
  h_mag_ci=patch_eb(f,...
                 H_mag_ci,...
                 [0.75 0.75 0.75],...
                 'EdgeColor','none');
  % line_eb(f,...
  %         H_mag_ci,...
  %         [0.75 0.75 0.75]);
else
  h_mag=[];
end
h_mag=line(f,H_mag,zeros(size(f)),'Color',[0 0 0]);
xlim(f_lim);
ylim(H_mag_lim);
set(gca,'Layer','Top');
set(gca,'Box','on');
set(gca,'XTickLabel',[]);
ylabel('Mag');
title(title_str,'interpreter','none');

h_phase_axes=subplot(2,1,2);
if ~isempty(H_phase_ci)
  h_phase_ci=patch_eb_wrap(f,...
                           180/pi*H_phase,...
                           180/pi*H_phase_ci,...
                           [-180 +180],...
                           0.75*[1 1 1]);
  % line_eb_wrap(f,...
  %              180/pi*H_phase,...
  %              180/pi*H_phase_ci,...
  %              [-180 +180],...
  %              0.75*[1 1 1]);
else
  h_phase_ci=[];
end
h_phase=line_wrap(f,180/pi*H_phase,...
                  [-180 +180],...
                  'Color',[0 0 0]);
xlim(f_lim);
ylim(H_phase_lim);
set(gca,'Layer','Top');
set(gca,'Box','on');
if all(H_phase_lim==[-180 +180])
  set(gca,'YTick',[-180 -90 0 +90 +180]);
end
ylabel('Phase');
xlabel('Frequency (Hz)');    
