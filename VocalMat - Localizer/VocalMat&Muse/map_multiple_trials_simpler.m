function [blob_per_segment_per_trial,overhead_per_trial]= ...
  map_multiple_trials_simpler(base_dir_name, ...
                              data_analysis_dir_name, ...
                              date_str, ...
                              letter_str, ...
                              n_segments_per_trial_max, ...
                              blob_from_segment_indicators_and_trial_overhead_function, ...
                              options)

% base_dir_name a string
% date_str, letter_str each a cell array of strings

n_segments_total=0;
n_trials=length(date_str);
blob_per_segment_per_trial=cell(n_trials,1);
for i_trial=1:n_trials
  i_trial  %#ok
  n_segments_so_far_this_trial=0;
  
  % load the per-trial ancillary data
  overhead_this_trial= ...
    ssl_trial_overhead_packaged(base_dir_name, ...
                                data_analysis_dir_name, ...
                                date_str{i_trial}, ...
                                letter_str{i_trial});
                                
  % iterate over the vocalizations in this trial
  n_segments_this_trial=length(i_first_tf_rect_in_segment);
  n_segments_total=n_segments_total+n_segments_this_trial;
  %n_mice=size(r_head,3);
  for i_segment_this_trial=1:n_segments_this_trial
    i_segment_this_trial  %#ok
    args=overhead_this_trial;
    args.i_segment=i_segment_this_trial;
    
    blob_this_segment = ...
      feval(blob_from_segment_indicators_and_trial_overhead_function, ...
            args, ...
            options);
          
    if i_segment_this_trial==1
      blob_per_segment=blob_this_segment;
    else
      blob_per_segment(i_segment_this_trial,1)=blob_this_segment;
    end
    n_segments_so_far_this_trial=n_segments_so_far_this_trial+1;
    if n_segments_so_far_this_trial>=n_segments_per_trial_max
      break
    end
  end
  blob_per_segment_per_trial{i_trial}=blob_per_segment;
  
  % store the per-trial data for return
  if ~options.return_big_things ,
    overhead_this_trial=rmfield(overhead_this_trial,{'x_grid' 'y_grid' 'in_cage'});
  end
  overhead_per_trial(i_trial)=overhead_this_trial;  %#ok
end

n_segments_total  %#ok

end
