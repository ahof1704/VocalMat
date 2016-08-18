% % load pre-calculated stuff
% load('r_est_for_single_mouse_data_snippetized.mat');
% % r_est_blob_per_segment_per_trial and overhead_per_trial are now in the
% % scope
% 
% % Unpack the blob, and flatten across trials
% [date_str, ...
%  letter_str, ...
%  i_trial, ...
%  i_segment_within_trial, ...
%  is_localized, ...
%  r_est, ...
%  Covariance_matrix, ...
%  p_head, ...
%  r_head, ...
%  r_tail] = ...
%   flatten_trials_given_r_est_blob_per_segment_per_trial(r_est_blob_per_segment_per_trial);
% % r_head and r_tail are from the video
[date_str, ...
 letter_str, ...
 i_trial, ...
 i_segment_within_trial, ...
 is_localized_jpn, ...
 r_est_jpn, ...
 r_head, ...
 r_tail, ...
 posterior_chest_jpn_with_fake, ...
 pdf_chest_jpn_with_fake, ...
 r_chest_jpn_with_fake ] = ...
  gather_jpn_single_mouse_pos_est_with_nearby_fake_mouse();

% Check that all the segments are there
n_segments_total=length(is_localized_jpn)  %#ok
n_segments_localized=sum(double(is_localized_jpn))  %#ok

% Calculate fraction localized
frac_localized=mean(double(is_localized_jpn))  %#ok

% filter out unlocalized segments
date_str=date_str(is_localized_jpn);
letter_str=letter_str(is_localized_jpn);
i_trial=i_trial(is_localized_jpn);
i_segment_within_trial=i_segment_within_trial(is_localized_jpn);
r_est_jpn=r_est_jpn(:,is_localized_jpn);
%Covariance_matrix=Covariance_matrix(:,:,is_localized);
%p_head=p_head(is_localized);
r_head=r_head(:,is_localized_jpn);
r_tail=r_tail(:,is_localized_jpn);
posterior_chest_jpn_with_fake=posterior_chest_jpn_with_fake(:,is_localized_jpn);
pdf_chest_jpn_with_fake=pdf_chest_jpn_with_fake(:,is_localized_jpn);
r_chest_jpn_with_fake=r_chest_jpn_with_fake(:,:,is_localized_jpn);
clear is_localized

% calculate errors
r_chest=3/4*r_head+1/4*r_tail;
  % r_chest is what Josh uses in the multi-mouse code
dr_est=r_est_jpn-r_chest;

% make a histogram of the error magnitudes
e2=sum(dr_est.^2,1);  % m
e_mag=sqrt(e2);  % m
dist_edges=(0:0.005:1)';
dist_bin_counts=histc(e_mag,dist_edges);
dist_bin_counts=dist_bin_counts(1:end-1);
dist_centers=(dist_edges(1:end-1)+dist_edges(2:end))/2;

% calc RMS error, other measures
e_mag_mean=mean(e_mag)  %#ok
e_mag_rms=rms(e_mag)  %#ok
e_mag_median=median(e_mag)  %#ok
frac_less_than_1_cm=mean(e_mag<0.01)  %#ok<NOPTS>
frac_less_than_2_cm=mean(e_mag<0.02)  %#ok<NOPTS>
frac_less_than_3_cm=mean(e_mag<0.03)  %#ok<NOPTS>
frac_less_than_4_cm=mean(e_mag<0.04)  %#ok<NOPTS>
frac_less_than_5_cm=mean(e_mag<0.05)  %#ok<NOPTS>
frac_less_than_6_cm=mean(e_mag<0.06)  %#ok<NOPTS>
frac_less_than_7_cm=mean(e_mag<0.07)  %#ok<NOPTS>
frac_less_than_8_cm=mean(e_mag<0.08)  %#ok<NOPTS>
frac_less_than_9_cm=mean(e_mag<0.09)  %#ok<NOPTS>
frac_less_than_10_cm=mean(e_mag<0.10)  %#ok<NOPTS>
save('e_mag.mat','e_mag');  % save the numbers for Josh

% % plot that histogram
% figure('color','w');
% j=bar(100*dist_centers,dist_bin_counts);
% set(j,'edgecolor','none');
% set(j,'facecolor','k');
% xlabel('Error (cm)');
% ylabel('Frequency (counts)');
% xlim([0 30]);
% ylim([0 300]);
% title(sprintf('Error histogram for %d localized segments',n_segments_localized));
%text(20,275   ,sprintf('Median error: %0.1f cm',100*e_mag_median));
%text(20,275-15,sprintf('RMS error: %0.1f cm',100*e_mag_rms));
% drawnow;

% % calculate center of each mouse
% r_center=(r_head+r_tail)/2;

% translate so that r_chest is in the center
dr_head=r_head-r_chest;
dr_tail=r_tail-r_chest;
%dr_center=r_center-r_chest;

% calulate the mean length
len=normcols(r_head-r_tail);
len_mean=mean(len);
a_mean=len_mean/2;
b_mean=1/2*a_mean;  % made-up

% rotate around so mouse butt is to the bottom
theta=atan2(dr_tail(2,:),dr_tail(1,:));
dr_est_rot=zeros(size(dr_est));
dr_tail_rot=zeros(size(dr_tail));
dr_head_rot=zeros(size(dr_head));
for k=1:n_segments_localized 
  A=[cos(-theta(k)-pi/2) -sin(-theta(k)-pi/2) ; ...
     sin(-theta(k)-pi/2)  cos(-theta(k)-pi/2)];  % rotation matrix for -theta rotation, then pi
  dr_est_rot(:,k)=A*dr_est(:,k);
  dr_tail_rot(:,k)=A*dr_tail(:,k);
  dr_head_rot(:,k)=A*dr_head(:,k);
  %dr_center_rot(:,k)=A*dr_center(:,k);  
end

% make a 2-d histogram of the estimates in the chest-centered coord system
dx=0.01;  % m
dy=dx;
x_hist_centers_want=(-2:dx:2)';
y_hist_centers_want=(-1:dy:1)';
x_hist_edges= ...
  [x_hist_centers_want(1)-dx/2 ; (x_hist_centers_want(1:end-1)+x_hist_centers_want(2:end))/2 ; x_hist_centers_want(end)+dx/2];
y_hist_edges= ...
  [y_hist_centers_want(1)-dy/2 ; (y_hist_centers_want(1:end-1)+y_hist_centers_want(2:end))/2 ; y_hist_centers_want(end)+dy/2];
[dr_est_rot_counts,xy_hist_centers_check]=hist3(dr_est_rot','Edges',{x_hist_edges y_hist_edges});
x_hist_centers=xy_hist_centers_check{1};
y_hist_centers=xy_hist_centers_check{2};
dr_est_rot_counts=dr_est_rot_counts(1:end-1,1:end-1);  % stupid extra bins!
x_hist_centers=x_hist_centers(1:end-1);
y_hist_centers=y_hist_centers(1:end-1);
n_x_centers=length(x_hist_centers);
n_y_centers=length(y_hist_centers);
x_hist_center_grid=repmat(x_hist_centers ,[1           n_y_centers]);
y_hist_center_grid=repmat(y_hist_centers',[n_x_centers 1          ]);
counts_max=max(max(dr_est_rot_counts))  %#ok

% make a colormap
% f=linspace(0,1,256)';
% j=jet(256);
% j_no_white_short=j(1:224,:);
% j_no_white=interp1(linspace(0,1,224)',j_no_white_short,f);
% w=repmat([1 1 1],[256 1]);
%yb=flipud(blue_to_yellow(256));
% cmap=bsxfun(@times,f,yb)+bsxfun(@times,(1-f),w);
% cmap=flipud(gray(256));
% cmap=bsxfun(@times,f,j_no_white)+bsxfun(@times,(1-f),w);
%cmap=wycmgrb_smooth(256);
%cmap=flipud(bspectrumw_smooth(256));
%cmap=yb;
cmap=flipud(spindle_smooth(256));
%cmap=jet(256);

%cmap(1,:)=[0.5 0.5 0.5];  % make count of one map to red
%cmap(1,:)=[1 0 0];  % make count of one map to red
%cmap(2,:)=[0 1 0];  % make count of one map to red
%cmap(3,:)=[0 0 1];  % make count of one map to red

%
% plot those
%

% set dimensions
w_fig=4.5; % in
h_fig=3; % in
w_axes=1.8;  % in
h_axes=1.8;  % in
w_colorbar=0.1;  % in
w_colorbar_spacer=0.06;  % in

% make the figure
f=figure('color','w','colormap',cmap);
set_figure_size_explicit(f,[w_fig h_fig]);
a=axes('parent',f, ...
       'clim',[0 counts_max], ...
       'xlim',[-30 +30], ...
       'ylim',[-30 +30], ...
       'xtick',-50:10:+50, ...
       'ytick',-50:10:+50, ...
       'dataaspectratio',[1 1 1], ...
       'box','on', ...
       'layer','top');
%change_axes_position_manually_to_give_one_one_data_aspect_ratio(a);     
set(a,'fontsize',7);
set_axes_size_fixed_center_explicit(a,[w_axes h_axes])     
image('parent',a, ...
      'xdata',100*[x_hist_centers(1) x_hist_centers(end)], ...
      'ydata',100*[y_hist_centers(1) y_hist_centers(end)], ...
      'cdata',dr_est_rot_counts', ...
      'cdatamapping','scaled');
% line('parent',a, ...
%      'xdata',100*dr_est_rot(1,:), ...
%      'ydata',100*dr_est_rot(2,:), ...
%      'linestyle','none', ...
%      'marker','.', ...
%      'color','k');
% line('parent',a, ...
%      'xdata',100*dr_tail_rot(1,:), ...
%      'ydata',100*dr_tail_rot(2,:), ...
%      'linestyle','none', ...
%      'marker','.', ...
%      'color',[0 0.7 0]);
% line('parent',a, ...
%      'xdata',100*dr_head_rot(1,:), ...
%      'ydata',100*dr_head_rot(2,:), ...
%      'linestyle','none', ...
%      'marker','+', ...
%      'color','r');
do_draw_mouse_center=false;
mouse_body_alt(a,[100*0 100*(-a_mean/2) 100*a_mean 100*b_mean pi/2],1,do_draw_mouse_center,'color','k');

% draw scale bar
line('parent',a, ...
     'xdata',21+[-5 5], ...
     'ydata',-22*[1 1], ...
     'color','k', ...
     'linewidth',2);
text('parent',a, ...
     'position',[21 -25], ...
     'string','10 cm', ...
     'horizontalalignment','center', ...
     'fontsize',7);
   
%line(0,0,'marker','+','color','r','linestyle','none');
%axis square;
%ylabel('Distance in front of mouse (cm)');
%xlabel('Distance to right of mouse (cm)');
set(gca,'xtick',[]);
set(gca,'ytick',[]);
% title(sprintf('Vectorial error for %d localized segments, aligned to mouse', ...
%               n_segments_localized));
% legend({'Estimate','Mouse tail','Mouse head'},'location','southeast');
axes_cb_h=add_colorbar(a,w_colorbar,w_colorbar_spacer);
set(axes_cb_h,'fontsize',7);
set(axes_cb_h,'ytick',[0 counts_max]);
ylabel(axes_cb_h,'Counts');
drawnow;


% Using the faux mouse positions, determine fraction assigned
[posterior_assigned_maybe,i_mouse_assigned_maybe]=max(posterior_chest_jpn_with_fake,[],1);
pdf_chest_assigned_maybe=max(pdf_chest_jpn_with_fake,[],1);
pdf_chest_assigned_thresh=1;  % 1/(m^2)
is_assigned= (posterior_assigned_maybe>0.95) & (pdf_chest_assigned_maybe>pdf_chest_assigned_thresh);
n_assigned=sum(is_assigned)  %#ok
frac_assigned=n_assigned/n_segments_localized  %#ok
is_assigned_correctly=is_assigned & (i_mouse_assigned_maybe==1);
n_assigned_correctly=sum(is_assigned_correctly)  %#ok
frac_assigned_correctly=n_assigned_correctly/n_assigned  %#ok

