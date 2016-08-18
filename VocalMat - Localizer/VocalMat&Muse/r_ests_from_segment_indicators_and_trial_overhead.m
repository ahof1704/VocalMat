function r_est_blobs= ...
  r_ests_from_segment_indicators_and_trial_overhead(args,options)

% Estimates position for all snippets in the given segment, and returns the
% per-snippet estimates.

% unpack all the args
field_names=fieldnames(args);
for i=1:length(field_names) ,
  eval(sprintf('%s=args.%s;',field_names{i},field_names{i}));
end

% % unpack the contents of trial_overhead
% tf_rect_name_all=trial_overhead.tf_rect_name;
% i_start_all=trial_overhead.i_start;
% i_end_all=trial_overhead.i_end;
% f_lo_all=trial_overhead.f_lo;
% f_hi_all=trial_overhead.f_hi;
% r_head_all=trial_overhead.r_head_from_video;
% r_tail_all=trial_overhead.r_tail_from_video;
% R=trial_overhead.R;
% Temp=trial_overhead.Temp;
% dx=trial_overhead.dx;
% x_grid=trial_overhead.x_grid;
% y_grid=trial_overhead.y_grid;
% in_cage=trial_overhead.in_cage;

% filter out the snippets that don't match i_segment
n_snippets_in_trial=length(tf_rect_name);
keep=false(n_snippets_in_trial,1);
if isnan(i_first_tf_rect_in_segment(i_segment)) ,
  % means this segment has zero snippets, so keep should be all-false
else
  keep(i_first_tf_rect_in_segment(i_segment):i_last_tf_rect_in_segment(i_segment))=true;
end
%keep=(i_segment_all==i_segment);
tf_rect_name_keep=tf_rect_name(keep);
i_start_keep=i_start(keep);
i_end_keep=i_end(keep);
f_lo_keep=f_lo(keep);
f_hi_keep=f_hi(keep);
r_head_from_video_keep=r_head_from_video(:,keep,:);  %#ok
r_tail_from_video_keep=r_tail_from_video(:,keep,:);  %#ok  

% % package up all the trial overhead for return
% overhead.R=R;
% overhead.Temp=Temp;
% overhead.dx=dx;
% overhead.x_grid=x_grid;
% overhead.y_grid=y_grid;
% overhead.in_cage=in_cage;

% % pack up the arguments that don't change across snippets
% args_template_and_overhead=merge_scalar_structs(options,overhead);

% do the estimation for each snippet
n_mice=size(r_head_from_video,3);
n_snippets=length(tf_rect_name_keep);
r_est_blobs=struct([]);
if isfield(options,'verbosity') ,
  options.verbosity=options.verbosity-1;
end
for i_snippet=1:n_snippets ,
  % pack up all the arguments
  %snippet_args=args_template_and_overhead;
  tf_rect_name_this=tf_rect_name_keep{i_snippet};
  i_start_this=i_start_keep(i_snippet);
  i_end_this=i_end_keep(i_snippet);  
  f_lo_this=f_lo_keep(i_snippet);  
  f_hi_this=f_hi_keep(i_snippet);  
  r_head_from_video_this=reshape(r_head_from_video_keep(:,i_snippet,:),[2 n_mice]);  
  r_tail_from_video_this=reshape(r_tail_from_video_keep(:,i_snippet,:),[2 n_mice]);

  % estimate r
  r_est_blob_this = ... 
    r_est_from_tf_rect_indicators_and_ancillary(base_dir_name, ...
                                                date_str, ...
                                                letter_str, ...
                                                R,Temp,dx,x_grid,y_grid,in_cage, ...
                                                tf_rect_name_this, ...
                                                i_start_this,i_end_this, ...
                                                f_lo_this,f_hi_this, ...
                                                r_head_from_video_this,r_tail_from_video_this, ...
                                                options);
  
  if i_snippet==1
    r_est_blobs=r_est_blob_this;
    %fs=r_est_blob_this.fs;
    %overhead.fs=fs;
  else
    r_est_blobs(i_snippet)=r_est_blob_this;
  end
end

% if isempty(r_est_blobs) || isempty(fieldnames(r_est_blobs)) ,
%   error('r_est_blobs is messed up');
% end

end
