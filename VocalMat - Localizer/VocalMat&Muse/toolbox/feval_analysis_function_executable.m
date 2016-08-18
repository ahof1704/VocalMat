function feval_analysis_function_executable(output_file_name,input_file_name)

% make sure the common blob_from_voc_indicators_and_ancillary functions get
% included in the executable:
%#function r_est_multi_segments_from_segment_indicators_and_trial_overhead

load(input_file_name);
if ~exist(output_file_name,'file')         
%if true ,  
  blobs = ...
    feval(analysis_function, ...
          args,options);  %#ok
  save(output_file_name,'blobs','args','options');
end

end
