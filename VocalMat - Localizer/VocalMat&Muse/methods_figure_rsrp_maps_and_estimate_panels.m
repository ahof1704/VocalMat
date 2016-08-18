% calculate stuff for all vocalizations
options.verbosity=0;  % how much output or intermediate results the user wants to 
                      % see
options.read_from_map_cache=false;  % whether to try to use the map cache 
                                    % to save time
options.write_to_map_cache=false;  % whether to write to the map cache after 
                                   % calculating a map de novo
options.quantify_confidence=false;  % calculate P-vals, CRs (that's
                                 % what makes it not "raw")
options.return_big_things=true;  % return the full map and other large
                                 % data structures

% identifying info for the segment
date_str='06132012';
letter_str='D';
i_segment=51;  % this was voc84 in the old-style

% directories where to find stuff
%base_dir_name='~/egnor_stuff/ssl_vocal_structure_bizarro';
% base_dir_name='/groups/egnor/egnorlab/Neunuebel/ssl_vocal_structure';
%base_dir_name='/groups/egnor/egnorlab/Neunuebel/ssl_sys_test';
if ispc()
  base_dir_name='z:/Neunuebel/ssl_sys_test';
else
  base_dir_name='/groups/egnor/egnorlab/Neunuebel/ssl_sys_test';
end
data_analysis_dir_name='Data_analysis10';

% load the trial overhead
trial_overhead=...
  ssl_trial_overhead_cartesian_heckbertian_packaged(base_dir_name,...
                                                    data_analysis_dir_name, ...
                                                    date_str, ...
                                                    letter_str);

% package up the args                                           
args=trial_overhead;
args.i_segment=i_segment;
%args.verbosity=verbosity;

% call the functions
r_est_blobs = ...
  r_ests_from_segment_indicators_and_trial_overhead(args,options);

% unpack the return blob
i_snippet_pretty=16;
field_names=fieldnames(r_est_blobs);
for i=1:length(field_names)
  if isequal(field_names{i},'rsrp_per_pair_grid')
    rsrp_per_pair_grid_pretty_snippet=r_est_blobs(i_snippet_pretty).rsrp_per_pair_grid;
  else
    eval(sprintf('%s_all_snippets={r_est_blobs(:).%s}'';',field_names{i},field_names{i}));
  end
end
clear r_est_blobs;

% transform things from cell arrays what can
n_snippets=length(tf_rect_name_all_snippets);  %#ok
rsrp_grid_all_snippets=cell2mat(reshape(rsrp_grid_all_snippets,[1 1 n_snippets]));  %#ok
%rsrp_per_pair_grid_all_snippets=cell2mat(reshape(rsrp_per_pair_grid_all_snippets,[1 1 1 n_snippets]));
r_est_all_snippets=cell2mat(reshape(r_est_all_snippets,[1 n_snippets]));  %#ok
r_head_from_video_all_snippets=cell2mat(reshape(r_head_from_video_all_snippets,[1 1 n_snippets]));  %#ok
r_tail_from_video_all_snippets=cell2mat(reshape(r_tail_from_video_all_snippets,[1 1 n_snippets]));  %#ok

% unpack the trial overhead
r_mics=trial_overhead.R;
Temp=trial_overhead.Temp;
dx=trial_overhead.dx;
x_grid=trial_overhead.x_grid;
y_grid=trial_overhead.y_grid;
in_cage=trial_overhead.in_cage;
fs=trial_overhead.fs;
r_corners=trial_overhead.r_corners;
clear trial_overhead;

% get dims out
%N=size(v_all_snippets{1},1);  % all same length
K=size(r_mics,2);
dt=1/fs;  % s
n_snippets=length(tf_rect_name_all_snippets)  %#ok
n_pairs=nchoosek(K,2);

% % figure setup
% % set the default to be that figures print the same size as on-screen
% set(0,'DefaultFigurePaperPositionMode','auto');
% 
% % make it so that it doesn't change the figure or axes background of
% % printed figures
% set(0,'DefaultFigureInvertHardCopy','off');
% 
% % set up so the default is not to change the figure axis limits and ticks
% % when printing
% newPrintTemplate=printtemplate;
% newPrintTemplate.AxesFreezeTicks=1;
% newPrintTemplate.AxesFreezeLimits=1;
% newPrintTemplate.DriverColor=1;
% set(0,'DefaultFigurePrintTemplate',newPrintTemplate); 
% clear newPrintTemplate


% unpack stuff for this snippet
tf_rect_name_pretty=tf_rect_name_all_snippets{i_snippet_pretty};
v_pretty=v_all_snippets{i_snippet_pretty};  %#ok
%V_filt_pretty=V_filt_all_snippets{i_snippet_pretty};  %#ok
a_pretty=a_all_snippets{i_snippet_pretty};  %#ok
rsrp_grid_pretty=rsrp_grid_all_snippets(:,:,i_snippet_pretty);
rsrp_pretty_abs_max=max(max(abs(rsrp_grid_pretty)));  %#ok
%rsrp_per_pair_grid=rsrp_per_pair_grid_all_snippets(:,:,:,i_snippet);
r_est_pretty=r_est_all_snippets(:,i_snippet_pretty);
r_head_from_video_pretty=r_head_from_video_all_snippets(:,:,i_snippet_pretty);
r_tail_from_video_pretty=r_tail_from_video_all_snippets(:,:,i_snippet_pretty);

% useful stuff        
N=size(v_pretty,1);
t=dt*(0:(N-1))';  % s



%
% make a figure of the objective function, estimate for the example snippet
%

% set mic colors
% clr_mike=[1 0 0 ; ...
%           0 0.7 0 ; ...
%           0 0 1 ; ...
%           0 0.8 0.8 ];
do_draw_mic_labels=true;                 
clr_mike=zeros(4,3);

title_str=sprintf('%s %s %s', ...
                  date_str,letter_str,tf_rect_name_pretty);
colorbar_label_str='RSRP/sample (mV^2)';         
clr_anno=[0 0 0];

w_fig=4.5; % in
h_fig=3; % in
w_axes=1.8;  % in
h_axes=1.8;  % in
w_colorbar=0.1;  % in
w_colorbar_spacer=0.05;  % in

fig_h=figure('color','w');
set_figure_size_explicit(fig_h,[w_fig h_fig]);
axes_h=axes('parent',fig_h);
set_axes_size_fixed_center_explicit(axes_h,[w_axes h_axes])

place_gridded_function_in_axes(axes_h, ...
                               x_grid,y_grid,10^6*rsrp_grid_pretty/N, ...
                               @bipolar_red_white_blue, ...
                               [-820 +820]);
%                               10^6*rsrp_pretty_abs_max/N*[-1 +1]);

z_mics_and_floor=0;
do_draw_mask=true;
draw_mics_and_floor_in_axes(axes_h,r_mics,r_corners,z_mics_and_floor,do_draw_mask);

axes_cb_h= ...
  add_colorbar_sized_to_corners(axes_h, ...
                                w_colorbar, ...
                                w_colorbar_spacer, ...
                                'RSRP/sample (mV^2)', ...
                                r_corners);
z_est_and_mouse=0.01;  % m                              
line('parent',axes_h, ...
     'xdata',100*r_est_pretty(1,:), ...
     'ydata',100*r_est_pretty(2,:), ...
     'zdata',100*z_est_and_mouse, ...
     'linestyle','none', ...
     'marker','+', ...
     'color','k');
draw_mice_given_head_and_tail(axes_h, ...
                              100*r_head_from_video_pretty, ...
                              100*r_tail_from_video_pretty, ...
                              100*z_est_and_mouse, ...
                              [0 0 0]);  % color
set(fig_h,'name','single_snippet_map');                
% place_objective_map_in_axes(axes_h, ...
%                             x_grid,y_grid,10^6*rsrp_grid_pretty/N, ...
%                             @bipolar_red_white_blue, ...
%                             10^6*rsrp_pretty_abs_max/N*[-1 +1], ...
%                             title_str, ...
%                             clr_mike, ...
%                             clr_anno, ...
%                             r_est_pretty,[], ...
%                             r_mics,r_head_from_video_pretty,r_tail_from_video_pretty, ...
%                             do_draw_mic_labels);
%title(axes_h,title_str,'interpreter','none','fontsize',7);

% % axes_cb_h=add_colorbar(axes_h,w_colorbar,w_colorbar_spacer);
% % set(axes_cb_h,'fontsize',7);
% % ylabel(axes_cb_h,colorbar_label_str);

%
% done with figure of the objective function, estimate for the example snippet
%








% normalize the per-pair rsrp images by the RMS amplitude of each signal
[M,iMicFirst,iMicSecond]=mixing_matrix_from_n_mics(K);
rsrp_per_pair_grid_normed=zeros(size(rsrp_per_pair_grid_pretty_snippet));
for i_pair=1:n_pairs
  keep=logical(abs(M(i_pair,:)));
  norming_factor=sqrt(prod(a_pretty(keep).^2))*N;
  rsrp_per_pair_grid_normed(:,:,i_pair)=rsrp_per_pair_grid_pretty_snippet(:,:,i_pair)/norming_factor;
end

% plot the rsrp image for each pair in a single figure
max_abs=max(max(max(abs(rsrp_per_pair_grid_normed))));
[fig_h,axes_hs]= ...
  figure_objective_map_per_pair_grid_new(x_grid,y_grid,rsrp_per_pair_grid_normed, ...
                                         @bipolar_red_white_blue, ...
                                         0.9*[-1 +1], ...
                                         r_est_pretty, ...
                                         r_mics, ...
                                         r_corners, ...
                                         r_head_from_video_pretty, ...
                                         r_tail_from_video_pretty);
set(fig_h,'name','per_mic_pair_maps');                

%close all;












% need to do outlier filtering on r_est here
[is_outlier,~,r_est_trans,Covariance_matrix] = kur_rce(r_est_all_snippets',1);
is_outlier=logical(is_outlier);
indices_of_outliers=find(is_outlier)  %#ok
r_est=r_est_trans';
n_outliers=sum(is_outlier)  %#ok

% filter out the outliers
is_keeper=~is_outlier;
n_keepers=sum(is_keeper);
rsrp_grid_all_keepers=rsrp_grid_all_snippets(:,:,is_keeper);
r_est_all_keepers=r_est_all_snippets(:,is_keeper);
r_est_all_outliers=r_est_all_snippets(:,is_outlier);

% take the mean of the maps for all the non-outliers
rsrp_grid_pretty=mean(rsrp_grid_all_keepers,3);
rsrp_pretty_abs_max=max(max(abs(rsrp_grid_pretty)));

% Get the video position from the snippets
i_start_all_snippets=cell2mat(i_start_all_snippets);  %#ok
i_end_all_snippets=cell2mat(i_end_all_snippets);  %#ok
[r_head_from_video,r_tail_from_video]= ...
  r_head_for_segment_from_snippets(r_head_from_video_all_snippets, ...
                                   r_tail_from_video_all_snippets, ...
                                   i_start_all_snippets, ...
                                   i_end_all_snippets);                                 
% r_head_from_video=mean(r_head_from_video_all_snippets,2);
% r_tail_from_video=mean(r_tail_from_video_all_snippets,2);

% make up some mouse locations
n_fake_mice=3;
%[r_head_from_video_fake,r_tail_from_video_fake]= ...
%  random_mouse_locations(R,r_head_from_video,r_tail_from_video,n_fake_mice);
% These were a nice-looking sample:
r_head_from_video_fake = ...
   [     0.445553008346868         0.709662308265758         0.522328094818333 ; ...
         0.334817684474456         0.419620179150835         0.582494615220904 ];
r_tail_from_video_fake = ...
   [     0.473832772083876         0.636316477631333         0.556192459384125 ; ...
         0.257019105608912         0.381243714500405         0.658029830339911 ];

% Have to transform these last to convential Cartesian coords
r_head_from_video_fake(2,:)=(0.67925-r_head_from_video_fake(2,:))+0.0265;
r_tail_from_video_fake(2,:)=(0.67925-r_tail_from_video_fake(2,:))+0.0265;

       
% caclulate the density at the real+fake mice, and the posterior
% probability
r_head_from_video_with_fake=[r_head_from_video r_head_from_video_fake];
r_tail_from_video_with_fake=[r_tail_from_video r_tail_from_video_fake];
r_chest_from_video_real_and_fake= ...
  (3/4)*r_head_from_video_with_fake + ...
  (1/4)*r_tail_from_video_with_fake ;
p_chest_real_and_fake=mvnpdf(r_chest_from_video_real_and_fake',r_est',Covariance_matrix)    %#ok % density
P_posterior_chest_from_video_real_and_fake= ...
  p_chest_real_and_fake/sum(p_chest_real_and_fake)    %#ok % posterior probability


% plot the per-snippet estimates, the density, and the mice
colorbar_max=100;  % 1/m^2
are_mice_beyond_first_fake=true;
[h_fig,h_axes,h_axes_cb]= ...
  fig_segment_ssl_summary(r_est,Covariance_matrix, ...
                          r_est_all_snippets,is_outlier, ...
                          r_mics,r_corners, ...
                          r_head_from_video_with_fake,r_tail_from_video_with_fake, ...
                          colorbar_max, ...
                          are_mice_beyond_first_fake);
set(h_fig,'name','segment_summary');                
                        



