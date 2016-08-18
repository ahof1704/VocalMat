function [date_str_flat, ...
          letter_str_flat, ...
          i_trial_flat, ...
          i_segment_within_trial_flat, ...
          is_localized_jpn_flat, ...
          r_est_jpn_flat, ...
          r_head_from_video_flat, ...
          r_tail_from_video_flat, ...
          posterior_jpn_with_fake_flat, ...
          pdf_jpn_with_fake_flat, ...
          r_chest_from_video_jpn_with_fake_flat] = ...
  gather_jpn_single_mouse_position_estimates()

% directories where to find stuff
if ispc()
  base_dir_name='Z:/Neunuebel/ssl_sys_test';  
else
  base_dir_name='/groups/egnor/egnorlab/Neunuebel/ssl_sys_test';
end
data_analysis_dir_name='Data_analysis10';

% identifying info for each trial
date_str=cell(0,1);
letter_str=cell(0,1);
date_str{end+1}='06052012';
letter_str{end+1}='D';
date_str{end+1}='06062012';
letter_str{end+1}='E';
date_str{end+1}='06102012';
letter_str{end+1}='E';
date_str{end+1}='06112012';
letter_str{end+1}='D';
date_str{end+1}='06122012';
letter_str{end+1}='D';
date_str{end+1}='06122012';
letter_str{end+1}='E';
date_str{end+1}='06132012';  % this is the one with the least vocs
letter_str{end+1}='D';
date_str{end+1}='06132012';
letter_str{end+1}='E';
% n_segments_per_job_max=50;
% n_segments_per_trial_max=inf;  % max number of vocs to do per trial
% use_cluster=true;

n_trials=length(date_str);

n_mice_with_fake=4;
date_str_flat=cell(0,1);
letter_str_flat=cell(0,1);
i_trial_flat=zeros(0,1);
i_segment_within_trial_flat=zeros(0,1);
is_localized_jpn_flat=false(0,1);
r_est_jpn_flat=zeros(2,0);
r_head_from_video_flat=zeros(2,0);
r_tail_from_video_flat=zeros(2,0);
posterior_jpn_with_fake_flat=zeros(n_mice_with_fake,0);
pdf_jpn_with_fake_flat=zeros(n_mice_with_fake,0);
r_chest_from_video_jpn_with_fake_flat=zeros(2,n_mice_with_fake,0);
for i_trial = 1:n_trials ,
  date_str_this=date_str{i_trial};
  letter_str_this=letter_str{i_trial};
  
  % load the trial overhead data (these stuctures are all per-snippet)
  [~,i_start_per_snippet,i_end_per_snippet,~,~,r_head_from_video_per_snippet,r_tail_from_video_per_snippet,~,~, ...
   ~,~,~,~,~,~,i_first_tf_rect_in_segment_this,i_last_tf_rect_in_segment_this]= ...
    ssl_trial_overhead_cartesian_heckbertian(base_dir_name,data_analysis_dir_name,date_str_this,letter_str_this);

  % reshape r_head, r_tail to put snippets in third index
  r_head_from_video_per_snippet=permute(r_head_from_video_per_snippet,[1 3 2]);
  r_tail_from_video_per_snippet=permute(r_tail_from_video_per_snippet,[1 3 2]);
  % should now be 2 x n_mice x n_snippets
  
  % collect across snippets in a segment
  n_segments_this=length(i_first_tf_rect_in_segment_this);
  r_head_from_video_this=nan(2,n_segments_this);
  r_tail_from_video_this=nan(2,n_segments_this);
  for i_segment=1:n_segments_this ,
    i_first_snippet_this_segment=i_first_tf_rect_in_segment_this(i_segment);
    i_last_snippet_this_segment=i_last_tf_rect_in_segment_this(i_segment);
    if ~isnan(i_first_snippet_this_segment) ,
      % if we get here, there are >=1 snippets in this segment
      r_head_from_video_per_snippet_this_segment= ...
        r_head_from_video_per_snippet(:,:,i_first_snippet_this_segment:i_last_snippet_this_segment);
      r_tail_from_video_per_snippet_this_segment= ...
        r_tail_from_video_per_snippet(:,:,i_first_snippet_this_segment:i_last_snippet_this_segment);     
      
      % Get the first and last audio sample index for each snippet
      i_first_sample_per_snippet_this_segment=i_start_per_snippet(i_first_snippet_this_segment:i_last_snippet_this_segment);
      i_last_sample_per_snippet_this_segment=i_end_per_snippet(i_first_snippet_this_segment:i_last_snippet_this_segment);

      % Summarize the positions across segments, taking care not to double
      % count snippets that correspond to the same time window
      [r_head_from_video_this_segment,r_tail_from_video_this_segment]= ...
        r_head_for_segment_from_snippets(r_head_from_video_per_snippet_this_segment, ...
                                         r_tail_from_video_per_snippet_this_segment, ...
                                         i_first_sample_per_snippet_this_segment, ...
                                         i_last_sample_per_snippet_this_segment);
      r_head_from_video_this(:,i_segment)=r_head_from_video_this_segment;
      r_tail_from_video_this(:,i_segment)=r_tail_from_video_this_segment;
    end
  end
  
  % load the output of Josh running Muse on each of the snippets
  muse_per_snippet_output_file_name_this = ...
    fullfile(base_dir_name, ...
             sprintf('sys_test_%s',date_str_this), ...
             data_analysis_dir_name, ...
             sprintf('Results_who_said_it_single_mouse_%s',letter_str_this));
  s=load(muse_per_snippet_output_file_name_this);
 
  % Check that the two information sources agree on the number of segments
  if length(i_first_tf_rect_in_segment_this)~=size(s.centroid_chunks,2) , 
    error('Trial overhead and Josh''s file disagree on the number of segments in a trial');
  end
  n_segments_this=length(i_first_tf_rect_in_segment_this);
  
  % unpack Josh's data
  r_est_jpn_this=s.centroid_chunks;
  r_chest_from_video_jpn_this=reshape(s.coords_mouse2(:,1,:),[2 n_segments_this]);
  r_chest_from_video_jpn_with_fake_this=s.coords_mouse2;
  % for single-mouse data, Josh has x and y coords swapped
  r_est_jpn_this=flipud(r_est_jpn_this);
  r_chest_from_video_jpn_this=flipud(r_chest_from_video_jpn_this);
  r_chest_from_video_jpn_with_fake_this=flip(r_chest_from_video_jpn_with_fake_this,1);  
  is_localized_jpn_this=~any(isnan(r_est_jpn_this),1)';
  posterior_jpn_with_fake_this=s.p;
  pdf_jpn_with_fake_this=s.density;
  
  % compare chest position according to the two sources
  % Note that Josh sets r_chest_from_video to nan for segments he can't
  % localize, so need to deal with that.
  r_chest_from_video_this=(3/4)*r_head_from_video_this+(1/4)*r_tail_from_video_this;
  e_chest_from_video_this=r_chest_from_video_this-r_chest_from_video_jpn_this;
  e_mag_chest_from_video_this=normcols(e_chest_from_video_this);
  e_mag_chest_from_video_this_localized=e_mag_chest_from_video_this(is_localized_jpn_this);
  e_mag_diff_mean=mean(e_mag_chest_from_video_this_localized);  %#ok
  e_mag_diff_median=median(e_mag_chest_from_video_this_localized);  %#ok
  e_mag_diff_max=max(e_mag_chest_from_video_this_localized);  %#ok
  %if any(e_mag_chest_from_video_this_localized>0.01) ,
  %  error('Chest positions from video do not agree');
  %end
  
  % Put everything in flat variables
  date_str_flat=[date_str_flat; ...
                 repmat({date_str_this},[n_segments_this 1])];  %#ok
  letter_str_flat=[letter_str_flat; ...
                   repmat({letter_str_this},[n_segments_this 1])];  %#ok
  i_trial_flat=[i_trial_flat;repmat(i_trial,[n_segments_this 1])];  %#ok
  i_segment_within_trial_flat=[i_segment_within_trial_flat ; ...
                               (1:n_segments_this)'];  %#ok
  is_localized_jpn_flat=[is_localized_jpn_flat;is_localized_jpn_this];  %#ok
  r_est_jpn_flat=[r_est_jpn_flat r_est_jpn_this];  %#ok
  r_head_from_video_flat=cat(2,r_head_from_video_flat,r_head_from_video_this);
  r_tail_from_video_flat=cat(2,r_tail_from_video_flat,r_tail_from_video_this);
  posterior_jpn_with_fake_flat=[posterior_jpn_with_fake_flat posterior_jpn_with_fake_this];  %#ok
  pdf_jpn_with_fake_flat=[pdf_jpn_with_fake_flat pdf_jpn_with_fake_this];  %#ok
  r_chest_from_video_jpn_with_fake_flat=cat(3,r_chest_from_video_jpn_with_fake_flat,r_chest_from_video_jpn_with_fake_this);
end

end  % function
