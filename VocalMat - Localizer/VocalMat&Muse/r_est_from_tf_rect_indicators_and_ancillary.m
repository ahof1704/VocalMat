function blob = ...
  r_est_from_tf_rect_indicators_and_ancillary(base_dir_name,...
                                              date_str, ...
                                              letter_str, ...
                                              R,Temp,dx,x_grid,y_grid,in_cage, ...
                                              tf_rect_name, ...
                                              i_start,i_end, ...
                                              f_lo,f_hi, ...
                                              r_head_from_video,r_tail_from_video, ...
                                              options)
                                         
% This function is called by r_est_from_voc_indicators() and 
% r_est_from_segment_indicators(), and likely other places.
%
% A 'voc' (vocalization) was a vocalization as determined by the old code,
% which was bounded in both time and frequency.
% A 'segment' is something spit out by Ax which is usually a single
% vocalization, but might only a part of a vocalization, or might be
% multiple vocalizations, but is again bounded in time and frequency.
% A 'tf_rect' is a time-frequency rectangle, and this function doesn't give
% a damn whether it's a voc or a segment.

% Check arg count
if nargin~=17 ,
  errror('Wrong number of args to r_est_from_tf_rect_indicators_and_ancillary()');
end

% unpack options
name_field=fieldnames(options);
for i=1:length(name_field)
  eval(sprintf('%s = options.%s;',name_field{i},name_field{i}));
end

% if x_grid or y_grid is empty, re-generate them
if isempty(x_grid) || isempty(y_grid) ,
  [x_grid,y_grid]=grids(R,dx);
end

% If in_cage is empty, declare everything in-cage
if isempty(in_cage) ,  
  in_cage=true(size(x_grid));
end

% dimensions
n_mice=size(r_head_from_video,2);
                                        
% synthesize the name of the memo file
memo_base_dir_name=fullfile(fileparts(mfilename('fullpath')),'..');
memo_dir_name=fullfile(memo_base_dir_name, ...
                       sprintf('memos_%06d_um',round(1e6*dx)));
memo_file_name= ...
  fullfile(memo_dir_name, ...
           sprintf('grid_%s_%s_%s.mat', ...
                   date_str,letter_str,tf_rect_name));

% read the grid from the memo file, or compute it                 
if read_from_map_cache && exist(memo_file_name,'file')
  s=load(memo_file_name);  % gets sse_grid, a few other things
  %fs=s.fs;
  r_est=s.r_est;
  rsrp_max=s.rsrp_max;
  rsrp_grid=s.rsrp_grid;
  %N=s.N;
  %K=s.K;
  % need to recreate a few things
  exp_dir_name=sprintf('%s/sys_test_%s',base_dir_name,date_str);
  if ~exist(exp_dir_name,'dir')
    exp_dir_name=sprintf('%s/%s',base_dir_name,date_str);
  end
  [v,~,fs]= ...
    read_voc_audio_trace(exp_dir_name, ...
                         letter_str, ...
                         i_start, ...
                         i_end);
    % v in V, t in s, fs in Hz                 
  V=fft(v);
  [N,K]=size(v);
  dt=1/fs;
  f=fft_base(N,1/(dt*N));
  keep=(f_lo<=abs(f))&(abs(f)<f_hi);
  N_filt=sum(keep);
  V_filt=V;
  V_filt(~keep,:)=0;
  %rsrp_grid=sse_grid/(N^2*K);
  %rsrp_max=sse_min/(N^2*K);
    % convert to time domain SS by dividing by N, then to mean by
    % dividing by N*K
  V_filt_ss_per_mike=sum(abs(V_filt).^2,1);  % 1 x K, sum of squares
  a=sqrt(V_filt_ss_per_mike)/N;  % volts, gain estimate, proportional to RMS
                                 % amp (in time domain)
  %clear sse_grid sse_min
else
  % load the audio data for one vocalization
  exp_dir_name=sprintf('%s/sys_test_%s',base_dir_name,date_str);
  if ~exist(exp_dir_name,'dir')
    exp_dir_name=sprintf('%s/%s',base_dir_name,date_str);
  end
  [v,~,fs]= ...
    read_voc_audio_trace(exp_dir_name, ...
                         letter_str, ...
                         i_start, ...
                         i_end);
    % v in V, t in s, fs in Hz                 

  % estimate the position, and get the SSE grid also
  [r_est,rsrp_max,rsrp_grid,a,~,N_filt,V_filt,V,rsrp_per_pair_grid]= ...
    r_est_from_clip_simplified(v,fs, ...
                               f_lo,f_hi, ...
                               Temp, ...
                               x_grid,y_grid,in_cage, ...
                               R, ...
                               verbosity);
                  
  % save the memo file
  if write_to_map_cache && ~exist(memo_dir_name,'dir')
    mkdir(memo_dir_name);
  end
  [N,K]=size(v);
  if write_to_map_cache
    save(memo_file_name,'fs','r_est','rsrp_max','rsrp_grid','N','K');
  end
end

% Calculate the total sum of squares for this voc, on the
% _filtered_ data
ms_total=sum(sum(abs(V_filt).^2))/(N^2*K);
  % convert to time-domain SS by dividing by N, then to mean by
  % dividing by N*K

% Determine RSRP at the head, which we call rsrp_body for historical reasons
d_thresh=0.01;  % cm
r_rsrp_near_head=zeros(2,n_mice);
rsrp_near_head=zeros(1,n_mice);
for i_mouse=1:n_mice
  d=distance_from_point(x_grid,y_grid,r_head_from_video(:,i_mouse));
  is_close_to_head=(d<=d_thresh);
  % On some vocs, the stupid mouse head is actually outside the microphone
  % rectangle.  If the head is far enough out that there are no pels in the
  % "head circle", just return nans rsrp_body and r_body.  We'll have to sift
  % those out later.
  some_pels_close_to_head=any(any(is_close_to_head));
  if some_pels_close_to_head
    rsrp_close_to_head=rsrp_grid(is_close_to_head);
    [~,k_star]=min(rsrp_close_to_head);
    rsrp_near_head(i_mouse)=rsrp_close_to_head(k_star);
    x_close_to_head=x_grid(is_close_to_head);
    y_close_to_head=y_grid(is_close_to_head);
    r_rsrp_near_head(:,i_mouse)=[x_close_to_head(k_star);y_close_to_head(k_star)];
  else
    rsrp_near_head(i_mouse)=nan;
    r_rsrp_near_head(:,i_mouse)=[nan;nan];
  end
end

% % load the empirical cdf curve
% conf_level=0.68;
% if quantify_confidence && exist('cdf_dJ_emp_unique.mat','file')
%   s=load('cdf_dJ_emp_unique.mat');
%   cdf_dJ_emp_unique=s.cdf_dJ_emp_unique;
%   dJ_line_unique=s.dJ_line_unique;
%   % determine the critical J, given the desired confidence level
%   dJ_crit=interp1(cdf_dJ_emp_unique,dJ_line_unique,conf_level);
%   % calculate the P-value at each nose position
%   dJ_body=rsrp_body./rsrp_max-1;
%   P_body=1-interp1(dJ_line_unique,cdf_dJ_emp_unique,dJ_body);
% else
%   dJ_crit=nan;
%   P_body=nan(1,n_mice);
% end

% % translate the J_crit to an mse_crit
% mse_crit=rsrp_max*(dJ_crit+1);  % dJ==mse/mse_min-1, for now

% % Determine MSE at the body, approximating the body as an ellipse
r_center=(r_head_from_video+r_tail_from_video)/2;
a_vec=r_head_from_video-r_center;  % 2 x n_mice, each col pointing forwards
b=normcols(a_vec)/3;  % scalar, and a guess at the half-width of the mouse
% in_body=in_ellipse(x_grid,y_grid,r_center,a_vec,b);  % boolean mask
% mse_body=mse_grid(in_body);
% [mse_body,i]=min(mse_body);  %#ok
% % x_in_body=x_grid(in_body);
% % y_in_body=y_grid(in_body);
% % r_est_in_body=[x_in_body(i);y_in_body(i)];

% plot the dF map
if verbosity>=1
  title_str=sprintf('%s %s %s', ...
                    date_str,letter_str,tf_rect_name);
  clr_mike=[1 0 0 ; ...
            0 0.7 0 ; ...
            0 0 1 ; ...
            0 1 1 ];
  clr_anno=[0 0 0];        
  %rmse_grid=sqrt(rsrp_grid);
  rsrp_abs_max=max(max(abs(rsrp_grid)));
  figure_objective_map(x_grid,y_grid,1e6*rsrp_grid, ...
                       @bipolar_red_white_blue, ...
                       1e6*rsrp_abs_max*[-1 +1], ...
                       title_str, ...
                       'RSRP (mV^2)', ...
                       clr_mike, ...
                       clr_anno, ...
                       r_est,[], ...
                       R,r_head_from_video,r_tail_from_video);
  for i_mouse=1:n_mice                   
    r_poly=polygon_from_ellipse(r_center(:,i_mouse), ...
                                a_vec(:,i_mouse), ...
                                b(i_mouse));
    line(100*r_poly(1,:),100*r_poly(2,:),'color',clr_anno);
  end
  line(100*r_rsrp_near_head(1,:),100*r_rsrp_near_head(2,:),zeros(1,n_mice), ...
       'marker','o','linestyle','none','color',clr_anno, ...
       'markersize',6);
  
  drawnow;                   
end

% pack the return vars
blob=struct();
blob.r_est=r_est;
blob.rsrp_max=rsrp_max;
%blob.mse_crit=mse_crit;
blob.rsrp_near_head=rsrp_near_head;
%blob.P_body=P_body;
blob.r_rsrp_near_head=r_rsrp_near_head;
blob.ms_total=ms_total;
blob.a=a;
blob.N=N;
blob.N_filt=N_filt;
blob.fs=fs;
blob.f_lo=f_lo;
blob.f_hi=f_hi;
blob.tf_rect_name=tf_rect_name;
blob.i_start=i_start;
blob.i_end=i_end;
blob.tf_rect_name=tf_rect_name;
blob.r_head_from_video=r_head_from_video;
blob.r_tail_from_video=r_tail_from_video;
if return_big_things
  blob.rsrp_grid=rsrp_grid;
  blob.rsrp_per_pair_grid=rsrp_per_pair_grid;
  blob.V_filt=V_filt;
  blob.V=V;
  blob.v=v;
end
  
end
