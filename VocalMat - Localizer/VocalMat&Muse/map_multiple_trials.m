function [blob_per_voc_per_trial,per_trial_ancillary]= ...
  map_multiple_trials(base_dir_name, ...
                      data_analysis_dir_name, ...
                      date_str, ...
                      letter_str, ...
                      n_vocs_per_trial_max, ...
                      blob_from_voc_indicators_and_ancillary, ...
                      args_template_base, ...
                      verbosity)

% base_dir_name a string
% date_str, letter_str each a cell array of strings

n_trials=length(date_str);
blob_per_voc_per_trial=cell(n_trials,1);
for i_trial=1:n_trials
  i_trial
  n_vocs_so_far_this_trial=0;
  
  % load the per-trial ancillary data
  [i_syl,i_start,i_end,f_lo,f_hi, ...
   r_head,r_tail,R,Temp, ...
   dx,x_grid,y_grid,in_cage]= ...
    ssl_trial_overhead(base_dir_name, ...
                       data_analysis_dir_name, ...
                       date_str{i_trial}, ...
                       letter_str{i_trial});
  
  % store the per-trial data for return
  per_trial_ancillary(i_trial).date_str=date_str{i_trial};
  per_trial_ancillary(i_trial).letter_str=letter_str{i_trial};
  per_trial_ancillary(i_trial).R=R;
  per_trial_ancillary(i_trial).Temp=Temp;
  per_trial_ancillary(i_trial).dx=dx;
  if args_template_base.return_big_things
    per_trial_ancillary(i_trial).x_grid=x_grid;
    per_trial_ancillary(i_trial).y_grid=y_grid;
    per_trial_ancillary(i_trial).in_cage=in_cage;
  end
  
  % iterate over the vocalizations in this trial
  n_voc_this_trial=length(i_syl)
  n_mice=size(r_head,3);
  args_template=args_template_base;
  args_template.R=R;
  args_template.Temp=Temp;
  args_template.dx=dx;
  args_template.x_grid=x_grid;
  args_template.y_grid=y_grid;
  args_template.in_cage=in_cage;
  for i_voc_this_trial=1:n_voc_this_trial
    i_voc_this_trial
    args=args_template;
    i_syl_this=i_syl(i_voc_this_trial)
    args.i_syl=i_syl(i_voc_this_trial);
    args.i_start=i_start(i_voc_this_trial);
    args.i_end=i_end(i_voc_this_trial);  
    args.f_lo=f_lo(i_voc_this_trial);  
    args.f_hi=f_hi(i_voc_this_trial);  
    args.r_head=reshape(r_head(:,i_voc_this_trial,:),[2 n_mice]);  
    args.r_tail=reshape(r_tail(:,i_voc_this_trial,:),[2 n_mice]);
    blob_this_voc = ...
      feval(blob_from_voc_indicators_and_ancillary, ...
            base_dir_name,date_str{i_trial},letter_str{i_trial}, ...
            args, ...
            verbosity);
    if i_voc_this_trial==1
      blob_per_voc=blob_this_voc;
    else
      blob_per_voc(i_voc_this_trial,1)=blob_this_voc;
    end
    n_vocs_so_far_this_trial=n_vocs_so_far_this_trial+1;
    if n_vocs_so_far_this_trial>=n_vocs_per_trial_max
      break
    end
  end
  blob_per_voc_per_trial{i_trial}=blob_per_voc;
end

end
