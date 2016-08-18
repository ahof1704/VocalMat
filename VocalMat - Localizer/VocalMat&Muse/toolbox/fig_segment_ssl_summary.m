function [fig_h,axes_h,axes_cb_h]= ...
  fig_segment_ssl_summary(r_est,Covariance_matrix, ...
                          r_est_per_snippet,is_outlier, ...
                          R,r_corners, ...
                          r_head,r_tail, ...
                          colorbar_max, ...
                          are_mice_beyond_first_fake)

% A function to make a figure showing the per-snippet position estimates 
% for a single segment, along with the "likelihood" density.

% r_est is a 2x1 vector giving the position estimate for the segment, in
% meters.  A traditional Cartesian coordinate system is assumed.
%
% Covariance_matrix is a 2x2 matrix giving the covariance matrix associated
% with the estimate.  Elements are in units of m^2.
%
% r_est_per_snippet is a 2 x n_snippets matrix, where n_snippets is the
% number of snippets derived from the segment, giving the per-snippet
% position estimates, in meters.
%
% is_outlier is a n_snippets x 1 logical vector indicating which snippets
% were declared outliers.
%
% R is a 3 x n_mics matrix of microphone positions, where n_mics is the
% number of microphones.  The microphone positions include the
% z-coordinate, although it is not used.  In meters.
%
% r_corners is a 2x4 matrix giving the positions of the four corners of the
% arena floor, in meters.
% 
% r_head is a 2 x n_mice matrix, where n_mice is the number of mice, giving
% the head position of each of the mice.  In meters.
%
% r_tail is like r_head, but for the tails.
%
% colorbar_max gives the probability density (in 1/m^2) that is set to the
% darkest color shown.  It is optional, and can be empty, in which case the
% largest density in the floor area is used.
%
% are_mice_beyond_first_fake is a n_mice x 1 logical array indicating which
% of the mice are real, and which are fake mice with randomly generated
% positions.  Fake mice are shown in gray, real mice in color.  This is
% optional, and can be empty, in which case all mice are assumed real.
%
%
% On return:
%
% fig_h is the figure handle.
%
% axes_h is the main axes handle.
%
% axes_cb_h is the colorbar axes handle.


% deal with args
if ~exist('colorbar_max','var') ,
  colorbar_max=[];
end
if ~exist('are_mice_beyond_first_fake','var') || isempty(are_mice_beyond_first_fake) ,
  are_mice_beyond_first_fake=false;
end


% sort per-snippet position estimates
is_keeper=~is_outlier;
r_est_keepers=r_est_per_snippet(:,is_keeper);
r_est_outliers=r_est_per_snippet(:,is_outlier);

% set the grid resolution
%dx=0.001*1;  % m
dx=0.001*0.25;  % m, the resolution we really want

% figure grid bounds
x_min=dx*floor(min(r_corners(1,:))/dx);
x_max=dx*ceil(max(r_corners(1,:))/dx);
y_min=dx*floor(min(r_corners(2,:))/dx);
y_max=dx*ceil(max(r_corners(2,:))/dx);

% make some grids and stuff
x_line=(x_min:dx:x_max)';
y_line=(y_min:dx:y_max)';
n_x=length(x_line);
n_y=length(y_line);
x_grid=repmat(x_line ,[1 n_y]);
y_grid=repmat(y_line',[n_x 1]);

% calculate the pdf at all grid points, so we can show it on the figure
x_grid_serial=x_grid(:);
y_grid_serial=y_grid(:);
r_grid_serial=[x_grid_serial';y_grid_serial'];
%n_grid_pts=size(r_grid_serial,2);
pdf_grid_serial=mvnpdf(r_grid_serial',r_est',Covariance_matrix);  % density, units: 1/(m^2)
pdf_grid=reshape(pdf_grid_serial,size(x_grid));
pdf_grid_max=max(max(pdf_grid));
if isempty(colorbar_max)
  colorbar_max=pdf_grid_max;
end

% Set dimensions, colors, etc.
w_fig=4.5; % in
h_fig=3; % in
w_axes=1.8;  % in
h_axes=1.8;  % in
w_colorbar=0.1;  % in
w_colorbar_spacer=0.08;  % in
color_mice=[ 0     0     0.57 ; ...
             0     0.8   0.8  ; ...
             0.8   0.22  0    ; ...
             0.8   0.67  0    ];   
if are_mice_beyond_first_fake ,
  % make them gray
  color_mice(2:end,:)=0.7;
end
color_function=@(n)(flipud(0.7+0.3*gray(n)));
colorbar_label_str='Probability density (1/m^2)';         
padding=0.045;  % m, amount of space to add around microphones

% Determine axis limits
xl=[min(R(1,:))-padding max(R(1,:))+padding];
yl=[min(R(2,:))-padding max(R(2,:))+padding];

% make the figure
fig_h=figure('color','w');
colormap(fig_h,feval(color_function,256));
set_figure_size_explicit(fig_h,[w_fig h_fig]);

% make the main axes
axes_h=axes('parent',fig_h);
set(axes_h,'fontsize',7);
set(axes_h,'box','on', ...
           'visible','off', ...
           'layer','top', ...
           'dataaspectratio',[1 1 1], ...
           'xlim',100*xl, ...
           'ylim',100*yl);
set(axes_h,'clim',[0 colorbar_max]);
set_axes_size_fixed_center_explicit(axes_h,[w_axes h_axes])

% make the image of the pdf
xd=[x_grid(1,1) x_grid(end,1)];
yd=[y_grid(1,1) y_grid(1,end)];  
image('parent',axes_h, ...
      'cdata',pdf_grid', ...
      'xdata',1e2*xd, ...
      'ydata',1e2*yd, ...
      'cdatamapping','scaled');
%xlabel(axes_h,'x (cm)');
%ylabel(axes_h,'y (cm)');
%title(axes_h,title_str,'interpreter','none')
%set(axes_h,'xtick',[]);
%set(axes_h,'ytick',[]);

% draw the mask, which covers the part of the density that extends beyond
% the floor outline
%r_corners=sortrows(r_corners')';  % make sure sorted by x, then y
%r_corners(:,3:4)=fliplr(r_corners(:,3:4));  
r_corners=sort_corners(r_corners);
  % now they're in clockwise order, starting with the one near the origin
r_mask_part_1= ...
  [xl(1) xl(2) xl(2) xl(1) xl(1) ; ...
   yl(1) yl(1) yl(2) yl(2) yl(1) ];  % outer loop, counterclockwise
r_mask_part_2=[r_corners r_corners(:,1)];  % inner loop, clockwise
r_mask_part_3=[ xl(1) ; ...
                yl(1) ];
r_mask=[r_mask_part_1 r_mask_part_2 r_mask_part_3];
patch('parent',axes_h, ...
      'xdata',100*r_mask(1,:), ...
      'ydata',100*r_mask(2,:), ...
      'facecolor','w', ...
      'edgecolor','none');
% just to make sure the seam doesn't show
rc=r_corners(:,1);
r_lip=[ xl(1) xl(1) rc(1) rc(1) xl(1) ; ...
        yl(1) rc(2) rc(2) yl(1) yl(1) ];
patch('parent',axes_h, ...
      'xdata',100*r_lip(1,:), ...
      'ydata',100*r_lip(2,:), ...
      'facecolor','w', ...
      'edgecolor','none');
    
% Draw the microphone symbols and labels
n_mics=size(R,2);
mic_circle_radius=0.02;  % m
for i_mic=1:n_mics
  switch i_mic ,
    case 1,
      v=[0;1];
    case 2,
      v=[1;0];
    case 3,
      v=[0;-1];
    case 4,
      v=[-1;0];
  end
  mic_symbol(axes_h,100*R(1:2,i_mic),v,100*mic_circle_radius, ...
             sprintf('%d',i_mic));
end

% draw the outline of the floor
line('parent',axes_h, ...
     'xdata',100*[r_corners(1,:) r_corners(1,1)], ...
     'ydata',100*[r_corners(2,:) r_corners(2,1)], ...
     'color','k');

% draw the mice
n_mice=size(r_head,2);
z_mice=0;
do_draw_center=false;
for i_mouse=1:n_mice
  % extrapolate a mouse ellipse
  r_center_this=(r_head(:,i_mouse)+r_tail(:,i_mouse))/2;
  a_vec_this=r_head(:,i_mouse)-r_center_this;  % vector
  b_this=norm(a_vec_this)/2;  % scalar, and a guess at the half-width of the mouse
%   r_mouse_shape_this=mouse_shape_from_ellipse(r_center_this,a_vec_this,b_this);
%   line('parent',axes_h, ...
%        'xdata',100*r_mouse_shape_this(1,:), ...
%        'ydata',100*r_mouse_shape_this(2,:), ...
%        'color','k');
  mouse_body_alt(axes_h, ...
                 [100*r_center_this(1,:) ...
                  100*r_center_this(2,:) ...
                  100*norm(a_vec_this) ...
                  100*b_this ...
                  atan2(a_vec_this(2),a_vec_this(1))], ...
                 z_mice , ... 
                 do_draw_center, ...
                 'color',color_mice(i_mouse,:));
end
                    
% draw the per-snippet position estimates
line('parent',axes_h, ...
     'xdata',100*r_est_keepers(1,:), ...
     'ydata',100*r_est_keepers(2,:), ...
     'marker','+', ...
     'linestyle','none', ...
     'color','k');
line('parent',axes_h, ...
     'xdata',100*r_est_outliers(1,:), ...
     'ydata',100*r_est_outliers(2,:), ...
     'marker','o', ...
     'markersize',3, ...
     'linestyle','none', ...
     'color','k');

% draw the per-segment position estimate   
line('parent',axes_h, ...
     'xdata',100*r_est(1,:), ...
     'ydata',100*r_est(2,:), ...
     'marker','.', ...
     'markersize',6*3, ...
     'linestyle','none', ...
     'color','k');

% draw the scale bar
x=0.4*R(1,1)+0.6*R(1,4);
y=R(2,1)-mic_circle_radius;
line('parent',axes_h, ...
     'xdata',100*x+[-5 5], ...
     'ydata',100*y*[1 1], ...
     'color','k', ...
     'linewidth',2);
% text('parent',axes_h, ...
%      'position',[21 -25], ...
%      'string','10 cm', ...
%      'horizontalalignment','center', ...
%      'fontsize',7);
   
% draw the colorbar   
axes_cb_h=add_colorbar(axes_h,w_colorbar,w_colorbar_spacer);
set(axes_cb_h,'fontsize',7);
ylabel(axes_cb_h,colorbar_label_str);
set(axes_cb_h,'ytick',[0 colorbar_max]);
scale_colorbar_to_corners(axes_cb_h, ...
                          axes_h, ...
                          100*r_corners);


end
