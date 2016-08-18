% identifying info for each trial
date_str=cell(0,1);
letter_str=cell(0,1);
date_str{end+1}='06052012';
letter_str{end+1}='D';
date_str{end+1}='06062012';
letter_str{end+1}='E';
date_str{end+1}='06102012';
letter_str{end+1}='E';
date_str{end+1}='06112012';
letter_str{end+1}='D';
date_str{end+1}='06122012';
letter_str{end+1}='D';
date_str{end+1}='06122012';
letter_str{end+1}='E';
date_str{end+1}='06132012';
letter_str{end+1}='D';
date_str{end+1}='06132012';
letter_str{end+1}='E';

% directories where to find stuff
base_dir_name='/groups/egnor/egnorlab/Neunuebel/ssl_sys_test';
data_analysis_dir_name='Data_analysis10';

n_trials=length(date_str);
r_est_blob_per_segment_per_trial=cell(n_trials,1);
overhead_per_trial=struct([]);
for i_trial=1:n_trials ,
  job_output_dir_name=sprintf('job_outputs_%s_%s',date_str{i_trial},letter_str{i_trial});
  d=dir(fullfile(job_output_dir_name,'output*.mat'));
  output_file_names_rel={d.name}';
  n_output_files_this_trial=length(output_file_names_rel);
  for i_output_file_this_trial=1:n_output_files_this_trial ,
    s=load(fullfile(job_output_dir_name,output_file_names_rel{i_output_file_this_trial}));
    if i_output_file_this_trial==1 ,
      r_est_blobs_this_trial=s.blobs;
      overhead_this_trial=rmfield(s.args,'i_segment');
      if i_trial==1
        overhead_per_trial=overhead_this_trial;
      else
        overhead_per_trial=[overhead_per_trial;overhead_this_trial];
      end
    else
      r_est_blobs_this_trial=[r_est_blobs_this_trial;s.blobs];  %#ok
    end
  end
  r_est_blob_per_segment_per_trial{i_trial}=r_est_blobs_this_trial;
end

% save everything           
save('-v7.3', ...
     'r_est_for_single_mouse_data_snippetized.mat', ...
     'r_est_blob_per_segment_per_trial', ...
     'overhead_per_trial');

