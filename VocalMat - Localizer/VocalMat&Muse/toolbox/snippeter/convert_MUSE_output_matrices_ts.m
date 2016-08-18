clc
clear
close all

fc = 450450; %samples per second

% where the files are stored, etc.
% base_dir_name='~/egnor_stuff/ssl_vocal_structure_bizarro';
% base_dir_name='/groups/egnor/egnorlab/Neunuebel/ssl_vocal_structure';

date_str=cell(0,1);
date_str{end+1}='08212012';
date_str{end+1}='08232012';
date_str{end+1}='09042012';
date_str{end+1}='09122012';
date_str{end+1}='10052012';
date_str{end+1}='10062012';
date_str{end+1}='10082012';
date_str{end+1}='11122012';
date_str{end+1}='12312012';
date_str{end+1}='01012013';
date_str{end+1}='01022013';
date_str{end+1}='03032013';
% date_str{end+1}='10072012';
% date_str{end+1}='11102012';

let_str=cell(0,1);
let_str{end+1}='B';
let_str{end+1}='B';
let_str{end+1}='B';
let_str{end+1}='B';
let_str{end+1}='B';
let_str{end+1}='B';
let_str{end+1}='B';
let_str{end+1}='B';
let_str{end+1}='B';
let_str{end+1}='B';
let_str{end+1}='B';
let_str{end+1}='B';
% let_str{end+1}='B';
% let_str{end+1}='B';

for ds_num = 1:size(date_str,2)%worked when ran 7!!!

    dir1 = sprintf('A:\\Neunuebel\\ssl_vocal_structure\\%s\\Data_analysis10\\',date_str{1,ds_num});
    
    mouse_str_name_dir = sprintf('%sTest_%s_1_Mouse.mat',dir1,let_str{1,ds_num});
    load(mouse_str_name_dir)
    
    
    %%
    start_ts = [mouse.start_sample_fine];
    stop_ts = [mouse.stop_sample_fine];
    cd(dir1)
    save('results_MUSE_matrix_ts','start_ts','stop_ts')
    
    clear base_data_dir_name dir1 dir_struct dur dur_tmp getNumber
    clear hf hot_pix i index index_tmp lf mouse mouse_str_name_dir
    clear output_files r_est r_head start_ts syl_name_old stop_ts start_ts
end
disp('Done')