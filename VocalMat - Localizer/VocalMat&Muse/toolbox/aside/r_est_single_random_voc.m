function [r_est,dssen_body,date_str_this,letter_str_this,i_syl_this]= ...
  r_est_single_random_voc(verbosity)

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

%base_dir_name='/groups/egnor/egnorlab/Neunuebel/ssl_sys_test';
base_dir_name='~/egnor/ssl/ssl_sys_test';

[r_est,dssen_body,date_str_this,letter_str_this,i_syl_this]= ...
  r_est_single_random_voc_from_multiple_trials(base_dir_name, ...
                                               date_str, ...
                                               letter_str, ...
                                               verbosity);

end
