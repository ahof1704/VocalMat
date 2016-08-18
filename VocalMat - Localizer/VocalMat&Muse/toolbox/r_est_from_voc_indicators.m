function r_est_blob= ...
  r_est_from_voc_indicators(base_dir_name,...
                            data_analysis_dir_name, ...
                            date_str, ...
                            letter_str, ...
                            syl_name, ...
                            args_template, ...
                            verbosity)

% do all the stuff we only have to do once per trial
[syl_name_all,i_start_all,i_end_all,f_lo_all,f_hi_all, ...
 r_head_all,r_tail_all,R,Temp, ...
 dx,x_grid,y_grid,in_cage]= ...
  ssl_trial_overhead(base_dir_name, ...
                     data_analysis_dir_name, ...
                     date_str, ...
                     letter_str);
%n_voc=length(i_syl_all);

% find the voc index
i_voc=find(strcmp(syl_name,syl_name_all));
i_start=i_start_all(i_voc);
i_end=i_end_all(i_voc);  
f_lo=f_lo_all(i_voc)
f_hi=f_hi_all(i_voc)  
r_head=r_head_all(:,i_voc);  
r_tail=r_tail_all(:,i_voc);

% pack up all the arguments
args=args_template;
args.R=R;
args.Temp=Temp;
args.dx=dx;
args.x_grid=x_grid;
args.y_grid=y_grid;
args.in_cage=in_cage;
args.syl_name=syl_name;
args.i_start=i_start;
args.i_end=i_end;  
args.f_lo=f_lo;  
args.f_hi=f_hi;  
args.r_head=r_head;  
args.r_tail=r_tail;

% estimate r
r_est_blob = ... 
  r_est_from_voc_indicators_and_ancillary(base_dir_name,...
                                          date_str, ...
                                          letter_str, ...
                                          args, ...
                                          verbosity);
                                        
% throw the args into the return blob
args_field_name=fieldnames(args);
for i=1:length(args_field_name)
  r_est_blob.(args_field_name{i})=args.(args_field_name{i});
end

end

