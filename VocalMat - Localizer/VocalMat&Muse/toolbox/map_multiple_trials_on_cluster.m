function map_multiple_trials_on_cluster(base_dir_name, ...
                                        data_analysis_dir_name, ...
                                        date_str, ...
                                        letter_str, ...
                                        n_vocs_per_trial_max, ...
                                        blob_from_voc_indicators_and_ancillary, ...
                                        args_template_base, ...
                                        verbosity)  %#ok

% base_dir_name a string
% date_str, letter_str each a cell array of strings
m_file_path=mfilename('fullpath');
toolbox_dir_path=fileparts(m_file_path);
project_dir_path=fileparts(toolbox_dir_path);
exe_path=fullfile(project_dir_path,'run_map_multiple_trials_executable.sh');
mcr_path='/home/taylora/software/MATLAB/R2012a';
temp_dir_name=fullfile(project_dir_path,'temp');

n_trials=length(date_str);
%blob_per_voc_per_trial=cell(n_trials,1);
for i_trial=1:n_trials
  i_trial  %#ok
  n_vocs_so_far_this_trial=0;
  
  % load the per-trial ancillary data
  [i_syl,i_start,i_end,f_lo,f_hi, ...
   r_head,r_tail,R,Temp, ...
   dx,x_grid,y_grid,in_cage]= ...
    ssl_trial_overhead(base_dir_name, ...
                       data_analysis_dir_name, ...
                       date_str{i_trial}, ...
                       letter_str{i_trial});  %#ok
  
%   % store the per-trial data for return
%   per_trial_ancillary(i_trial).date_str=date_str{i_trial};
%   per_trial_ancillary(i_trial).letter_str=letter_str{i_trial};
%   per_trial_ancillary(i_trial).R=R;
%   per_trial_ancillary(i_trial).Temp=Temp;
%   per_trial_ancillary(i_trial).dx=dx;
%   if args_template_base.return_big_things
%     per_trial_ancillary(i_trial).x_grid=x_grid;
%     per_trial_ancillary(i_trial).y_grid=y_grid;
%     per_trial_ancillary(i_trial).in_cage=in_cage;
%   end
  
  % iterate over the vocalizations in this trial
  n_voc_this_trial=length(i_syl)  %#ok
  n_mice=size(r_head,3);
  args_template=args_template_base;
  args_template.R=R;
  args_template.Temp=Temp;
  args_template.dx=dx;
  %args_template.x_grid=x_grid;
  %args_template.y_grid=y_grid;
  %args_template.in_cage=in_cage;
  args_template.x_grid=[];  % Save space in input file, will re-generate on cluster
  args_template.y_grid=[];
  args_template.in_cage=[];
  for i_voc_this_trial=1:n_voc_this_trial
    i_voc_this_trial  %#ok
    args=args_template;
    i_syl_this=i_syl(i_voc_this_trial)  %#ok
    args.i_syl=i_syl(i_voc_this_trial);
    args.i_start=i_start(i_voc_this_trial);
    args.i_end=i_end(i_voc_this_trial);  
    args.f_lo=f_lo(i_voc_this_trial);  
    args.f_hi=f_hi(i_voc_this_trial);  
    args.r_head=reshape(r_head(:,i_voc_this_trial,:),[2 n_mice]);  
    args.r_tail=reshape(r_tail(:,i_voc_this_trial,:),[2 n_mice]);
    date_str_this_trial=date_str{i_trial};
    letter_str_this_trial=letter_str{i_trial};
    
    % % Original non-parallelized code
    % blob_this_voc = ...
    %   feval(blob_from_voc_indicators_and_ancillary, ...
    %         base_dir_name,date_str_this_trial,letter_str_this_trial, ...
    %         args, ...
    %         verbosity);
    % if i_voc_this_trial==1
    %   blob_per_voc=blob_this_voc;
    % else
    %   blob_per_voc(i_voc_this_trial,1)=blob_this_voc;
    % end
    
    % New paralleledized code
    if ~exist(temp_dir_name,'dir')
      mkdir(temp_dir_name);
    end
    input_file_name= ...
      fullfile(temp_dir_name, ...
               sprintf('input_%s_%s_%03d.mat',date_str_this_trial,letter_str_this_trial,i_syl_this));
    output_file_name= ...
      fullfile(temp_dir_name, ...
               sprintf('output_%s_%s_%03d.mat',date_str_this_trial,letter_str_this_trial,i_syl_this));
    save(input_file_name,'blob_from_voc_indicators_and_ancillary', ...
                         'base_dir_name', ...
                         'date_str_this_trial', ...
                         'letter_str_this_trial', ...
                         'args', ...
                         'verbosity');
    qsub_str=sprintf('qsub -A egnorr -b yes "%s" "%s" "%s" "%s"', ...
                     exe_path,mcr_path, ...
                     output_file_name, ...
                     input_file_name);
    fprintf('%s\n',qsub_str);                
    system(qsub_str);         
    pause(0.005);
    
    % Original code starts again here
    n_vocs_so_far_this_trial=n_vocs_so_far_this_trial+1;
    if n_vocs_so_far_this_trial>=n_vocs_per_trial_max
      break
    end
  end
  % blob_per_voc_per_trial{i_trial}=blob_per_voc;
end

end
