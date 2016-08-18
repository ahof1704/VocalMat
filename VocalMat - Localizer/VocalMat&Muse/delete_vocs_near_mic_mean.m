function r_est_blob_per_voc_per_trial= ...
  delete_vocs_near_mic_mean(r_est_blob_per_voc_per_trial_raw, ...
                            per_trial_ancillary)

% clear out vocs in which r_est is close to mic mean
% these are usually vocs with very low SNR
% if r_est is nan, reject those too

d_thresh=0.025;  % m

n_trials=length(r_est_blob_per_voc_per_trial_raw);
r_est_blob_per_voc_per_trial=r_est_blob_per_voc_per_trial_raw;
for i_trial=1:n_trials
  %i_trial
  R_this=per_trial_ancillary(i_trial).R;
  R_this_mean=mean(R_this,2);
  R_this_mean_proj=R_this_mean(1:2);
  r_est_raw_this=[r_est_blob_per_voc_per_trial{i_trial}.r_est];
  d_to_mean=normcols(bsxfun(@minus,r_est_raw_this,R_this_mean_proj));
  mse_body_raw_this=[r_est_blob_per_voc_per_trial{i_trial}.mse_body];
  keep=(d_to_mean>d_thresh)&isfinite(mse_body_raw_this);
  r_est_blob_per_voc_per_trial{i_trial}(~keep)=[];
end

end
