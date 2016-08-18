function scatter_multiple_trials_simpler(base_dir_name, ...
                                         data_analysis_dir_name, ...
                                         date_str, ...
                                         letter_str, ...
                                         n_segments_per_trial_max, ...
                                         n_segments_per_job_max, ...
                                         use_cluster, ...
                                         analysis_function, ...
                                         options)  %#ok

% base_dir_name a string
% date_str, letter_str each a cell array of strings
m_file_path=mfilename('fullpath');
toolbox_dir_path=fileparts(m_file_path);
project_dir_path=fileparts(toolbox_dir_path);
exe_path=fullfile(project_dir_path,'bin','run_feval_analysis_function_executable_custom.sh');
[status,matlab_file_name_abs]=system('which matlab');
if status ~= 0,
  error('Unable to determine which matlab to use.');
end
mcr_path=fileparts(fileparts(matlab_file_name_abs));
%mcr_path='/home/taylora/software/MATLAB/R2012a';
%temp_dir_name=fullfile(project_dir_path,'temp');

n_trials=length(date_str);
%blob_per_segment_per_trial=cell(n_trials,1);
n_segments_submitted_total=0;
for i_trial=1:n_trials
  i_trial  %#ok
  date_str_this_trial=date_str{i_trial};
  letter_str_this_trial=letter_str{i_trial};
  %n_segments_so_far_this_trial=0;
  
  job_inputs_dir_name =fullfile(project_dir_path,sprintf('job_inputs_%s_%s' ,date_str_this_trial,letter_str_this_trial));
  job_outputs_dir_name=fullfile(project_dir_path,sprintf('job_outputs_%s_%s',date_str_this_trial,letter_str_this_trial));
  job_stdouts_dir_name=fullfile(project_dir_path,sprintf('job_stdouts_%s_%s',date_str_this_trial,letter_str_this_trial));
  job_stderrs_dir_name=fullfile(project_dir_path,sprintf('job_stderrs_%s_%s',date_str_this_trial,letter_str_this_trial));

  % load the per-trial ancillary data
  trial_overhead = ...
    ssl_trial_overhead_cartesian_heckbertian_packaged(base_dir_name, ...
                                                      data_analysis_dir_name, ...
                                                      date_str_this_trial, ...
                                                      letter_str_this_trial);
                              
  % iterate over the vocalizations in this trial
  n_segments_this_trial=length(trial_overhead.i_first_tf_rect_in_segment)  %#ok
  n_segments_to_process_this_trial=min(n_segments_this_trial,n_segments_per_trial_max);
  n_jobs_this_trial=ceil(n_segments_to_process_this_trial/n_segments_per_job_max);
  tic
  for i_job_this_trial=1:n_jobs_this_trial
    i_segment_this_job_first=(i_job_this_trial-1)*n_segments_per_job_max+1;
    if (i_job_this_trial<n_jobs_this_trial)
      i_segment_this_job_last=(i_job_this_trial-1)*n_segments_per_job_max+n_segments_per_job_max;  
    else
      i_segment_this_job_last=n_segments_to_process_this_trial;
    end
    n_segments_this_job=i_segment_this_job_last-i_segment_this_job_first+1;
    i_segment_this_job_first  %#ok
    i_segment_this_job_last  %#ok
    %args=repmat(args_template,[n_segments_this_job 1]);
    %argses=struct([]);
        
    % Set up args for job
    args=trial_overhead;
    args.i_segment=(i_segment_this_job_first:i_segment_this_job_last)';
    
    % Make sure all the dirs we need exist
    if ~exist(job_inputs_dir_name,'dir')
      mkdir(job_inputs_dir_name);
    end
    if ~exist(job_outputs_dir_name,'dir')
      mkdir(job_outputs_dir_name);
    end
    if ~exist(job_stdouts_dir_name,'dir')
      mkdir(job_stdouts_dir_name);
    end
    if ~exist(job_stderrs_dir_name,'dir')
      mkdir(job_stderrs_dir_name);
    end
    
    input_file_name= ...
      fullfile(job_inputs_dir_name, ...
               sprintf('input_%s_%s_first_segment_%04d.mat',date_str_this_trial,letter_str_this_trial,i_segment_this_job_first));
    output_file_name= ...
      fullfile(job_outputs_dir_name, ...
               sprintf('output_%s_%s_first_segment_%04d.mat',date_str_this_trial,letter_str_this_trial,i_segment_this_job_first));
    if ~exist(output_file_name,'file') ,
    %if true ,  
      save(input_file_name,'analysis_function','args','options');
      if use_cluster ,                   
        qsub_str=sprintf('qsub -l short=true -A egnorr -b yes -e "%s" -o "%s" "%s" "%s" "%s" "%s"', ...
                         job_stderrs_dir_name, ...
                         job_stdouts_dir_name, ...
                         exe_path, ...
                         mcr_path, ...
                         output_file_name, ...
                         input_file_name);
        fprintf('%s\n',qsub_str);                
        system(qsub_str);         
        pause(0.005);
      else
        feval_analysis_function_executable(output_file_name,input_file_name);
      end
    end
    n_segments_submitted_total=n_segments_submitted_total+n_segments_this_job;
    
    %n_segments_so_far_this_trial=n_segments_so_far_this_trial+n_segments_this_job;
  end  % loop over jobs
  toc
  % blob_per_segment_per_trial{i_trial}=blob_per_segment;
end  % loop over trials

n_segments_submitted_total  %#ok

end
