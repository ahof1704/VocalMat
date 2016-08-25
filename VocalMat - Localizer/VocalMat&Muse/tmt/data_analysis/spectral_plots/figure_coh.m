function [h_fig,...
          h_mag_axes,h_phase_axes,...
          h_mag,h_phase,...
          h_mag_ci,h_phase_ci,...
          h_mag_thresh]=...
  figure_coh(f,C_mag,C_phase,...
             C_mag_ci,C_phase_ci,...
             f_lim,C_mag_lim,C_phase_lim,...
             title_str,...
             C_mag_thresh)

% figure_coh(f,C_mag,C_phase) plots the given coherency
% in a new figure

% deal with args
if nargin<4
  C_mag_ci=[];
end
if nargin<5
  C_phase_ci=[];
end
if nargin<6 || isempty(f_lim)
  f_lim=[0 f(end)];
end
if nargin<7 || isempty(C_mag_lim)
  C_mag_lim=[0 1.05];
end
if nargin<8 || isempty(C_phase_lim)
  C_phase_lim=[-180 +180];
end
if nargin<9
  title_str='';
end
if nargin<10 
  C_mag_thresh=[];
end

% make the figure
h_fig=figure;

% make the plots
h_mag_axes=subplot(2,1,1);
if ~isempty(C_mag_ci)
  h_mag_ci=patch_eb(f,...
                    C_mag_ci,...
                    [0.75 0.75 0.75],...
                    'EdgeColor','none');
  % line_eb(f,...
  %         C_mag_ci,...
  %         [0.75 0.75 0.75]);
else
  h_mag_ci=[];
end
h_mag=line(f,C_mag,zeros(size(f)),'Color',[0 0 0]);
if ~isempty(C_mag_thresh)
  h_mag_thresh=line(f,repmat(C_mag_thresh,size(f)),'Color',[0 0 0],...
                    'linestyle','--');
else
  h_mag_thresh=[];
end
xlim(f_lim);
ylim(C_mag_lim);
set(gca,'Layer','Top');
set(gca,'Box','on');
set(gca,'XTickLabel',[]);
ylabel('Coh magnitude');
title(title_str,'interpreter','none');

h_phase_axes=subplot(2,1,2);
if ~isempty(C_phase_ci)
  h_phase_ci=patch_eb_wrap(f,...
                           180/pi*C_phase,...
                           180/pi*C_phase_ci,...
                           [-180 +180],...
                           0.75*[1 1 1]);
  % line_eb_wrap(f,...
  %              180/pi*C_phase,...
  %              180/pi*C_phase_ci,...
  %              [-180 +180],...
  %              0.75*[1 1 1]);
else
  h_phase_ci=[];
end
h_phase=line_wrap(f,180/pi*C_phase,...
                  [-180 +180],...
                  'Color',[0 0 0]);
xlim(f_lim);
ylim(C_phase_lim);
set(gca,'Layer','Top');
set(gca,'Box','on');
if all(C_phase_lim==[-180 +180])
  set(gca,'YTick',[-180 -90 0 +90 +180]);
end
ylabel('Coh phase (deg)');
xlabel('Frequency (Hz)');    
