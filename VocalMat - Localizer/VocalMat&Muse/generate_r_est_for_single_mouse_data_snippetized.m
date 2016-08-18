% N.B.: You probably shouldn't use this except for testing.  Use
% something that starts with scatter_ so you can run it on the cluster.

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
n_segments_per_trial_max=inf;  % max number of vocs to do per trial

% directories where to find stuff
base_dir_name='/groups/egnor/egnorlab/Neunuebel/ssl_sys_test';
data_analysis_dir_name='Data_analysis10';

% call r_est_from_voc_indicators_and_ancillary() for each voc, collect
% all the results in r_est_blob_per_voc_per_trial
tic
r_est_blob_per_segment_per_trial= ...
  map_multiple_trials_simpler(base_dir_name, ...
                              data_analysis_dir_name, ...
                              date_str, ...
                              letter_str, ...
                              n_segments_per_trial_max, ...
                              @r_est_from_segment_indicators_and_trial_overhead, ...
                              options);
toc

% save everything           
save('r_est_for_single_mouse_data_snippetized.mat');

