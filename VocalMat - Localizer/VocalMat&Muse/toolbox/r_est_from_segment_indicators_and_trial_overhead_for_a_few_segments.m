function blobs = ...
  r_est_from_segment_indicators_and_trial_overhead_for_a_few_segments(...
    args_common,options)  %#ok

n_segments=length(args_common.i_segment);
for i_segment=1:n_segments ,
  args=args_common;
  args.i_segment=i_segment;
  blob= ...
    r_est_from_segment_indicators_and_trial_overhead(args,options);
  
  % if first iter, dimension blobs                                        
  if i_segment==1 ,
    field_names=fieldnames(blob);
    n_fields=length(field_names);
    keys_and_values=cell(2*n_fields,1);
    keys_and_values(1:2:2*n_fields)=field_names;
    keys_and_values(2:2:2*n_fields)=repmat({cell(n_segments,1)},[n_fields 1]);
    blobs=struct(keys_and_values{:});
  end
  blobs(i_segment)=blob;
end

end
