% calculate stuff for all vocalizations
%works for single and multiple mice

verbosity=0;  % how much output or intermediate results the user wants to 
              % see
args.read_from_map_cache=false;  % whether to try to use the map cache 
                                % to save time
args.write_to_map_cache=false;  % whether to write to the map cache after 
                               % calculating a map de novo
args.quantify_confidence=false;  % calculate P-vals, CRs (that's
                                 % what makes it not "raw")
args.return_big_things=false;  % don't return the full map or other large
                               % data structures
n_vocs_per_trial_max=Inf;  % max number of vocs to do per trial
n_vocs_per_job_max=500;  % max number of vocalizations to do per cluster job
use_cluster=true;
% n_vocs_per_trial_max=20;  % max number of vocs to do per trial
% n_vocs_per_job_max=10;  % max number of vocalizations to do per cluster job
% use_cluster=false;
                               
% identifying info for each trial

date_str=cell(0,1);
%single mouse
date_str{end+1}='06052012';
date_str{end+1}='06062012';
date_str{end+1}='06102012';
date_str{end+1}='06112012';
date_str{end+1}='06122012';
date_str{end+1}='06122012';
date_str{end+1}='06132012';  % this is the one with the least vocs for single mouse data
date_str{end+1}='06132012';
% %mutiple mice
% date_str{end+1}='10062012';
% date_str{end+1}='11102012';
% date_str{end+1}='10052012';
% date_str{end+1}='09122012';
% date_str{end+1}='08232012';
% date_str{end+1}='09042012';
% date_str{end+1}='03032013';
% date_str{end+1}='12312012';
% date_str{end+1}='08212012';
% date_str{end+1}='01012013';
% date_str{end+1}='01022013';
% date_str{end+1}='10082012';
% date_str{end+1}='10072012';
% date_str{end+1}='11122012';

letter_str=cell(0,1);
%single mouse
letter_str{end+1}='D';
letter_str{end+1}='E';
letter_str{end+1}='E';
letter_str{end+1}='D';
letter_str{end+1}='D';
letter_str{end+1}='E';
letter_str{end+1}='D';
letter_str{end+1}='E';
% %multiple mice
% letter_str{end+1}='B';
% letter_str{end+1}='B';
% letter_str{end+1}='B';
% letter_str{end+1}='B';
% letter_str{end+1}='B';
% letter_str{end+1}='B';
% letter_str{end+1}='B';
% letter_str{end+1}='B';
% letter_str{end+1}='B';
% letter_str{end+1}='B';
% letter_str{end+1}='B';
% letter_str{end+1}='B';
% letter_str{end+1}='B';
% letter_str{end+1}='B';

%n_vocs_per_trial_max=inf;  % max number of vocs to do per trial

% directories where to find stuff
%base_dir_name='~/egnor_stuff/ssl_vocal_structure_bizarro';
% base_dir_name='/groups/egnor/egnorlab/Neunuebel/ssl_vocal_structure';
base_dir_name='/groups/egnor/egnorlab/Neunuebel/ssl_sys_test';
data_analysis_dir_name='Data_analysis10';

% call r_est_from_voc_indicators_and_ancillary() for each voc, collect
% all the results in r_est_blob_per_voc_per_trial
%[r_est_blob_per_voc_per_trial,per_trial_ancillary]= ... 
  scatter_multiple_trials(base_dir_name, ...
                          data_analysis_dir_name, ...
                          date_str, ...
                          letter_str, ...
                          n_vocs_per_trial_max, ...
                          n_vocs_per_job_max, ...
                          use_cluster, ...
                          @r_est_from_voc_indicators_and_ancillary_for_a_few_vocs, ...
                          args, ...
                          verbosity);

% save everything           
%save('r_est_for_10072012_B.mat');

