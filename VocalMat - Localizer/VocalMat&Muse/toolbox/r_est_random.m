function [r_est,mse_grid,x_grid,y_grid, ...
          date_str,letter_str,i_syl,r_head,r_tail,R, ...
          mse_min,mse_crit,mse_body,ms_total,a,N,N_filt]= ...
  r_est_random(conf_level,verbosity)

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

base_dir_name='/groups/egnor/egnorlab/Neunuebel/ssl_sys_test';
%base_dir_name='~/egnor/ssl/ssl_sys_test';
data_analysis_dir_name='Data_analysis';

[r_est,mse_grid,x_grid,y_grid,date_str,letter_str,i_syl,r_head,r_tail,R, ...
 mse_min,mse_crit,mse_body,ms_total,a,N,N_filt]= ...
  r_est_random_multiple_trials(base_dir_name, ...
                               data_analysis_dir_name, ...
                               date_str, ...
                               letter_str, ...
                               conf_level, ...
                               verbosity);

end
