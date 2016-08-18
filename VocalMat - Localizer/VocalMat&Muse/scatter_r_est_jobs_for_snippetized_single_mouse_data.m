% calculate stuff for all vocalizations
options.verbosity=0;  % how much output or intermediate results the user wants to 
                      % see
options.read_from_map_cache=false;  % whether to try to use the map cache 
                                   % to save time
options.write_to_map_cache=false;  % whether to write to the map cache after 
                                  % calculating a map de novo
options.quantify_confidence=false;  % don't calculate P-vals, CRs (that's
                                    % what makes it "raw")
options.return_big_things=false;  % don't return the full map or other large
                                  % data structures

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
date_str{end+1}='06132012';  % this is the one with the least vocs
letter_str{end+1}='D';
date_str{end+1}='06132012';
letter_str{end+1}='E';
n_segments_per_job_max=50;
n_segments_per_trial_max=inf;  % max number of vocs to do per trial
use_cluster=true;
% n_segments_per_trial_max=3;  % max number of vocs to do per trial
% use_cluster=false;

% directories where to find stuff
base_dir_name='/groups/egnor/egnorlab/Neunuebel/ssl_sys_test';
data_analysis_dir_name='Data_analysis10';

% Disperse the jobs to the cluster
scatter_multiple_trials_simpler(base_dir_name, ...
                                data_analysis_dir_name, ...
                                date_str, ...
                                letter_str, ...
                                n_segments_per_trial_max, ...
                                n_segments_per_job_max, ...
                                use_cluster, ...
                                @r_est_multi_segments_from_segment_indicators_and_trial_overhead, ...
                                options);

