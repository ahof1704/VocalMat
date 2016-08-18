function blob = ...
  pdf_from_voc_indicators_and_ancillary(base_dir_name,...
                                        date_str, ...
                                        letter_str, ...
                                        args, ...
                                        verbosity)

% call the real function                                      
blob = ...
  r_est_from_tf_rect_indicators_and_ancillary(base_dir_name,...
                                              date_str, ...
                                              letter_str, ...
                                              args, ...
                                              verbosity);

% unpack args
name_field=fieldnames(args);
for i=1:length(name_field)
  eval(sprintf('%s = args.%s;',name_field{i},name_field{i}));
end

% unpack blob
name_field=fieldnames(blob);
for i=1:length(name_field)
  eval(sprintf('%s = blob.%s;',name_field{i},name_field{i}));
end

% get dims
[~,n_mice]=size(r_head);

% make the figure
clr_mike=[1 0 0 ; ...
          0 0.7 0 ; ...
          0 0 1 ; ...
          0 1 1 ];
clr_anno=[0 0 0];        
rmse_grid=sqrt(mse_grid);
fig_h=figure('color','w');
w_page=8.5;  % inches
h_page=11;  % inches
set_figure_size([w_page h_page]);
rmse_axes_h=axes('parent',fig_h, ...
                 'box','on', ...
                 'layer','top');
w_rmse_axes=5;  % inches
h_rmse_axes=5;  % inches
y_rmse_axes=0.5;  % in
set_axes_position([(w_page-w_rmse_axes)/2 ...
                   y_rmse_axes ...
                   w_rmse_axes ...
                   h_rmse_axes]);
place_objective_map_in_axes(rmse_axes_h, ...
                            x_grid,y_grid,1e3*rmse_grid, ...
                            @jet, ...
                            [], ...
                            '', ...
                            clr_mike, ...
                            clr_anno, ...
                            r_est,[], ...
                            R,r_head,r_tail);
axes_cb_h=add_colorbar(rmse_axes_h,[],[]);
ylabel(axes_cb_h,'RMSE (mV)');

% Determine MSE at the body, approximating the body as an ellipse
r_center=(r_head+r_tail)/2;
a_vec=r_head-r_center;  % 2 x n_mice, each col pointing forwards
b=normcols(a_vec)/3;  % scalar, and a guess at the half-width of the mouse

for i_mouse=1:n_mice                   
  r_poly=polygon_from_ellipse(r_center(:,i_mouse), ...
                              a_vec(:,i_mouse), ...
                              b(i_mouse));
  line('parent',rmse_axes_h, ...
       'xdata',100*r_poly(1,:), ...
       'ydata',100*r_poly(2,:), ...
       'color',clr_anno);
end
line('parent',rmse_axes_h, ...
     'xdata',100*r_body(1,:), ...
     'ydata',100*r_body(2,:), ...
     'marker','o','linestyle','none','color',clr_anno, ...
     'markersize',6);  %#ok

% add the P-value annotations
for i_mouse=1:n_mice
  text('parent',rmse_axes_h, ...
       'position',1e2*(r_head(:,i_mouse)+ ...
                       0.3*(r_head(:,i_mouse)-r_tail(:,i_mouse))), ...
       'string',sprintf('%d: P=%0.2g',i_mouse,P_body(i_mouse)));
end
   
% need to read from the filesystem to get the voltage traces with
% a little padding on either side.
exp_dir_name=sprintf('%s/sys_test_%s',base_dir_name,date_str);
if ~exist(exp_dir_name,'dir')
  exp_dir_name=sprintf('%s/%s',base_dir_name,date_str);
end
T_pre=100e-3;  % s
T_post=400e-3;  %s
T_window_want=2e-3;  % s
dt=1/fs;  % s
n_pre=ceil(T_pre/dt);
n_post=ceil(T_post/dt);
n_window=ceil(T_window_want/dt);
[v,~,fs]= ...
  read_voc_audio_trace(exp_dir_name, ...
                       letter_str, ...
                       i_start-n_pre-n_window, ...
                       i_start+n_post+n_window);
  % v in V, t in s, fs in Hz
t_local=dt*((-n_pre-n_window):(+n_post+n_window))';
t0_local=t_local(1);
tf_local=t_local(end);
t0_voc_local=0;
tf_voc_local=dt*(i_end-i_start-1);
t0_voc=dt*(i_start-1);
t0_view_local=dt*(-n_pre);
tf_view_local=dt*(n_post);

% calculate spectrograms for the microphone signals
[N,K]=size(v);  % K the number of mikes
T=dt*N;  % s, duration of record
NW=4;  % time-bandwidth product
n_tapers=7;
f_max=[];  % full bandwidth
dt_window_want=T_window_want;
for k=1:K
  [f,t_gram,~,Svv_this]= ...
    powgram_mt(dt,v(:,k),T_window_want,dt_window_want,NW,n_tapers,f_max);
  if k==1
    [N_f,n_windows]=size(Svv_this);
    Svv=zeros(N_f,n_windows,K);
  end
  Svv(:,:,k)=Svv_this;
end

% convert t to the "local" timeline
t_gram_local=t_gram+t0_local;

% dimension axes for the spectrograms
w_powgram_array=5;  % in
h_powgram_array=4.25;  % in
x_powgram_array=(w_page-w_powgram_array)/2;  % in
y_powgram_array=6.1;  % in
h_spacer=0.15;  % in
h_powgram=(h_powgram_array-(K-1)*h_spacer)/K;  % in

% lay out spectrogram axes
axes_powgram_h=zeros(K,1);
for k=1:K
  axes_powgram_h(k)=axes('parent',fig_h);  %#ok
  set_axes_position([x_powgram_array ...
                     y_powgram_array+(K-k)*(h_powgram+h_spacer) ...
                     w_powgram_array ...
                     h_powgram]);
end

% plot the spectrograms in the axes
title_str=sprintf('%s-%s-%03d, t0:%0.3f s, i:%d-%d, f:%0.0f-%0.0f', ...
                  date_str,letter_str,i_syl,t0_voc,i_start,i_end, ...
                  f_lo,f_hi);
Svv_max=max(max(max(Svv)));
for k=1:K
  set(fig_h,'currentaxes',axes_powgram_h(k));
  plot_powgram(1e3*t_gram_local,1e-3*f,1e6*Svv(:,:,k), ...
               1e3*[t0_view_local tf_view_local],[0 150],[0 1e6*Svv_max], ...
               'amplitude',[]);
  line('parent',axes_powgram_h(k), ...
       'xdata',1e3*([t0_voc_local ...
                     tf_voc_local ...
                     tf_voc_local ...
                     t0_voc_local ...
                     t0_voc_local]), ...
       'ydata',1e-3*[f_lo f_lo f_hi f_hi f_lo], ...
       'zdata',ones(1,5),...
       'color','r');
  if k==1
    title(title_str,'interpreter','none');
  end
  if k~=K
    set(gca,'xticklabel',{});
  end
  if k==K
    xlabel('Time (ms)');
  else
    xlabel('');
  end
  if k==floor(K/2)+1
    ylabel('Frequency (kHz)');
  else
    ylabel('');
  end
end

% add a colorbar to the last 
w_spacer=10/72;  % in
w_cb=15/72;  % in
axes_cb_powgram_h = ...
  add_colorbar(axes_powgram_h(K), ...
               w_cb, ...
               w_spacer);
ylabel(axes_cb_powgram_h,'Amp (mV/Hz^{0.5})');
set(axes_cb_powgram_h, ...
    'ticklength',3*get(axes_cb_powgram_h,'ticklength'));

% change the colormap back
colormap(jet(256));

% output to pdf
base_name=sprintf('%s_%s_%03d', ...
                  date_str,letter_str,i_syl);
this_pdf_file_name=fullfile(pdf_page_dir_name,sprintf('%s.pdf',base_name));
if ~exist(pdf_page_dir_name,'dir')
  system(sprintf('mkdir "%s"',pdf_page_dir_name));
end
print_pdf_full_file_name(fig_h,this_pdf_file_name);

% close the figure
delete(fig_h);
fig_h=[];  %#ok

% minimal return values
blob=struct();
blob.file_name=this_pdf_file_name;

end
