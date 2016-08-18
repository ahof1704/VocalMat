function [h_fig,h_a]=figure_coh_polar(r,theta,...
                                      r_eb,theta_eb,...
                                      roi_labels,...
                                      r_show_thresh,...
                                      r_color_thresh,...
                                      r_max_equals_one,...
                                      clr_thing,...
                                      clr_subthresh)

% this function can also be used to plot other vector quatities, 
% not just coherence

% we assume r, theta are col vectors of length n
% we assume r_eb, theta_eb are of shape n x 2

% create a color sequence if this is the first run
persistent color_sequence;
if isempty(color_sequence)
%  color_sequence=spaced_colors(256);
  color_sequence=distinct_hues_simple(256);
end

% arg processing
if nargin<3
  r_eb=[r r];
  theta_eb=[theta theta];
end
if nargin<6
  roi_labels=cell(length(r),1);
  for j=1:length(r)
    roi_labels{j}=int2str(j);
  end
end
if nargin<7
  r_show_thresh=-1;
elseif isempty(r_show_thresh)
  r_show_thresh=-1;
end  
if nargin<9
  r_color_thresh=-1;
elseif isempty(r_color_thresh)
  r_color_thresh=-1;
end

% prelims
h_fig=figure;
set(h_fig,'color',[1 1 1]);
h_a=...
  axes('DataAspectRatio',[1 1 1],...
       'Box','off',...
       'Visible','off',...
       'XTick',[],...
       'YTick',[],...
       'XColor',[0.95 0.95 0.95],...
       'YColor',[0.95 0.95 0.95],...
       'Position',[0 0 1 1]);
hold on;

% define a unit circle
th = 0:pi/50:2*pi;
xunit = cos(th);
yunit = sin(th);
% now really force points on x/y axes to lie on them exactly
inds = 1:(length(th)-1)/4:length(th);
xunit(inds(2:2:4)) = zeros(2,1);
yunit(inds(1:2:5)) = zeros(3,1);

% the max r value we expect
if nargin<11
  r_max=1;
elseif isempty(r_max_equals_one)
  r_max=1;
elseif r_max_equals_one
  r_max=1;
else
  r_max=1.05*max(r);
end

% plot spokes
th=[0 pi/2 pi 3*pi/2];
th_labels={'0' '+90' '\pm180' '-90'};
costh=[1 0 -1 0];
sinth=[0 1 0 -1];
for j=1:length(th)
  line([0 r_max*costh(j)],[0 r_max*sinth(j)],...
       'color',[0.75 0.75 0.75]);
end

% draw unit circle
line(r_max*xunit,r_max*yunit,'color',[0 0 0]);

% draw threshold circles
if length(r_show_thresh)==1
  if r_show_thresh>0
    line(r_show_thresh*xunit,...
         r_show_thresh*yunit,...
         repmat(2*length(r),size(xunit)),...
         'Color',[0 0 0],...
         'LineStyle','--');
  end
end  
if length(r_color_thresh)==1
  if r_color_thresh>0
    line(r_color_thresh*xunit,...
         r_color_thresh*yunit,...
         repmat(2*length(r),size(xunit)),...
         'Color',clr_subthresh,...
         'LineStyle','--');
  end  
end

% annotate spokes in degrees
rt = 1.05*r_max;
for j = 1:length(th)
  [ha,va]=angle_to_alignment(th(j));
  text(rt*costh(j),rt*sinth(j),th_labels{j},...
       'horizontalalignment',ha,...
       'verticalalignment',va,...
       'Clipping','on');
end

% label the radius
if r_max~=1
  r_label_angle=pi/4;
  [ha,va]=angle_to_alignment(r_label_angle);
  text(rt*cos(r_label_angle),...
       rt*sin(r_label_angle),...
       sprintf('%0.2g',r_max),...
       'horizontalalignment',ha,...
       'verticalalignment',va,...
       'Clipping','on');
end

% set axis limits
axis(r_max*[-1.5 +1.5 -1.2 +1.2]);

% calculate the color for each ROI
% is clr_thing the name of a function or a matrix?
if isa(clr_thing,'char') || isa(clr_thing,'function_handle')
  clr=feval(clr_thing,r,theta);
else
  % better be an n_roi x 3 matrix of colors
  clr=clr_thing;
end
clr(r<=r_color_thresh,:)=...
  repmat(clr_subthresh,[sum(r<=r_color_thresh) 1]);

% plot each data point and error bars
for j=length(r):-1:1
  % only plot if it shows some evidence of being interesting
  if length(r_show_thresh)==1
    show_this_one=(r(j)>r_show_thresh);
  else
    show_this_one=(r(j)>r_show_thresh(j));
  end     
  if show_this_one
    % calc cart coords of point
    x=r(j)*cos(theta(j));
    y=r(j)*sin(theta(j));  
    % calc cart coords of mag CI
    x_lo=r_eb(j,1)*cos(theta(j));
    y_lo=r_eb(j,1)*sin(theta(j));
    x_hi=r_eb(j,2)*cos(theta(j));
    y_hi=r_eb(j,2)*sin(theta(j));
    % calc cart coords of phase CI
    r_arc=r(j);
    theta_arc=linspace(theta_eb(j,1),...
                       theta_eb(j,2),...
                       round((theta_eb(j,2)-theta_eb(j,1))/(pi/180)));
    x_arc=r_arc*cos(theta_arc);
    y_arc=r_arc*sin(theta_arc);
    % plot data point
    line(x,y,r(j),...
         'MarkerFaceColor',clr(j,:),...
         'MarkerEdgeColor','none',...
         'Marker','o','MarkerSize',6,...
         'LineStyle','none');
    % plot magnitude CI
    line([x_lo x_hi],[y_lo y_hi],[r(j) r(j)],'Color',clr(j,:));
    % plot phase CI
    line(x_arc,y_arc,repmat(r(j),size(x_arc)),'Color',clr(j,:));
    % plot index
    h=text('String',roi_labels{j},'interpreter','none');
    text_extent=get(h,'Extent'); shim_size=max(text_extent(3:4))/2;
    dr_hat=[cos(theta(j)) sin(theta(j))];
    dtheta_hat=[-dr_hat(2) dr_hat(1)];
    pos_text=(r(j)+shim_size)*dr_hat+shim_size*dtheta_hat;
    set(h,...
        'Position',[pos_text r(j)],...
        'HorizontalAlignment','center',...
        'VerticalAlignment','middle',...
        'Color',clr(j,:),...
        'Clipping','on');
  end
end 

% change the size so that two fit comfortably on a page
set(h_fig,'PaperPosition',[1.5833 3.5 5.3333 4]);

% free the plot
hold off;

