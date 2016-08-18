function [date_str_flat, ...
          letter_str_flat, ...
          i_trial, ...
          i_segment_within_trial_flat, ...
          localized_flat, ...
          r_est_flat, ...
          Covariance_matrix_flat, ...
          p_head_flat, ...
          r_head_from_video_flat, ...
          r_tail_from_video_flat] = ...
  flatten_trials_given_r_est_blob_per_segment_per_trial(r_est_blob_per_segment_per_trial)

% marshall the values across trials into double arrays (not cell
% arrays)
%K=4;  % number of mics
date_str_flat=cell(0,1);
letter_str_flat=cell(0,1);
i_trial=zeros(0,1);
i_segment_within_trial_flat=zeros(0,1);
localized_flat=false(0,1);
r_est_flat=zeros(2,0);
Covariance_matrix_flat=zeros(2,2,0);
p_head_flat=zeros(0,1);
r_head_from_video_flat=zeros(2,0);
r_tail_from_video_flat=zeros(2,0);
n_trials=length(r_est_blob_per_segment_per_trial);
for i_trial_this=1:n_trials
  n_segments_this_trial=length(r_est_blob_per_segment_per_trial{i_trial_this});

  fprintf('%s_%s: %d segments\n', ...
          r_est_blob_per_segment_per_trial{i_trial_this}(1).date_str, ...
          r_est_blob_per_segment_per_trial{i_trial_this}(1).letter_str, ...
          n_segments_this_trial);

  date_str_flat_this={r_est_blob_per_segment_per_trial{i_trial_this}.date_str}';
  date_str_flat= ...
    [date_str_flat;date_str_flat_this];  %#ok

  letter_str_flat_this={r_est_blob_per_segment_per_trial{i_trial_this}.letter_str}';
  letter_str_flat= ...
    [letter_str_flat;letter_str_flat_this];  %#ok
  
  
  i_trial=[i_trial ; ...
           repmat(i_trial_this,[n_segments_this_trial 1])];  %#ok
  
  i_segment_within_trial_flat= ...
    [i_segment_within_trial_flat;[r_est_blob_per_segment_per_trial{i_trial_this}.i_segment]'];  %#ok

  localized_flat= ...
    [localized_flat;[r_est_blob_per_segment_per_trial{i_trial_this}.localized]'];  %#ok
  
  r_est_flat= ...
    [r_est_flat [r_est_blob_per_segment_per_trial{i_trial_this}.r_est] ];  %#ok
  
  Cov_matrix_per_segment_as_cell_col={r_est_blob_per_segment_per_trial{i_trial_this}.Covariance_matrix}';
  Cov_matrix_per_segment_as_cell=reshape(Cov_matrix_per_segment_as_cell_col,[1 1 n_segments_this_trial]);
  Cov_matrix_per_segment=cell2mat(Cov_matrix_per_segment_as_cell);
  Covariance_matrix_flat=cat(3,Covariance_matrix_flat,Cov_matrix_per_segment);
  
  p_head_flat=[p_head_flat;[r_est_blob_per_segment_per_trial{i_trial_this}.p_head]'];  %#ok

  r_head_from_video_flat= ...
    [r_head_from_video_flat [r_est_blob_per_segment_per_trial{i_trial_this}.r_head_from_video] ];  %#ok
  
  r_tail_from_video_flat= ...
    [r_tail_from_video_flat [r_est_blob_per_segment_per_trial{i_trial_this}.r_tail_from_video] ];  %#ok
end

end
