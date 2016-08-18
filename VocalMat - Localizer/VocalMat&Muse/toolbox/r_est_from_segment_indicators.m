function output= ...
  r_est_from_segment_indicators(base_dir_name,data_analysis_dir_name,date_str,letter_str,i_segment,options)

% Estimates position for all snippets in the given segment, gets rid of
% outliers, and returns the overall position estimate for the segment.

% load the per-trial ancillary data
trial_overhead = ...
  ssl_trial_overhead_packaged(base_dir_name, ...
                              data_analysis_dir_name, ...
                              date_str, ...
                              letter_str);
args=trial_overhead;
args.i_segment=i_segment;

% Call the function that does the work
output= ...
  r_est_from_segment_indicators_and_trial_overhead(args,options);

end
