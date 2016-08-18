clc
clear
close all

fc = 450450; %samples per second

% where the files are stored, etc.
% base_dir_name='~/egnor_stuff/ssl_vocal_structure_bizarro';
% base_dir_name='/groups/egnor/egnorlab/Neunuebel/ssl_vocal_structure';

% date_str=cell(0,1);
% date_str{end+1}='08212012';
% date_str{end+1}='08232012';
% date_str{end+1}='09042012';
% date_str{end+1}='09122012';
% date_str{end+1}='10052012';
% date_str{end+1}='10062012';
% date_str{end+1}='10082012';
% date_str{end+1}='11122012';
% date_str{end+1}='12312012';
% date_str{end+1}='01012013';
% date_str{end+1}='01022013';
% date_str{end+1}='03032013';
% date_str{end+1}='10072012';
% date_str{end+1}='11102012';

% let_str=cell(0,1);
% let_str{end+1}='B';
% let_str{end+1}='B';
% let_str{end+1}='B';
% let_str{end+1}='B';
% let_str{end+1}='B';
% let_str{end+1}='B';
% let_str{end+1}='B';
% let_str{end+1}='B';
% let_str{end+1}='B';
% let_str{end+1}='B';
% let_str{end+1}='B';
% let_str{end+1}='B';
% let_str{end+1}='B';
% let_str{end+1}='B';
[ date_str,let_str,base_dir_name] = fn_create_experimental_list;
for ds_num = 1:8%worked when ran 7!!!
    
    base_data_dir_name='U:\Matlab\progs\v34_multiple_mice_parallel';
    if ds_num>8
        dir1 = sprintf('A:\\Neunuebel\\ssl_vocal_structure\\%s\\Data_analysis10\\',date_str{1,ds_num});
    else
        dir1 = sprintf('A:\\Neunuebel\\ssl_sys_test\\sys_test_%s\\Data_analysis10\\',date_str{1,ds_num});
    end
    mouse_str_name_dir = sprintf('%sTest_%s_1_Mouse.mat',dir1,let_str{1,ds_num});
    output_files = sprintf('job_outputs_%s_%s',date_str{1,ds_num},let_str{1,ds_num});
    
    job_outputs_dir_name=fullfile(base_data_dir_name,output_files);
    dir_struct=dir(fullfile(job_outputs_dir_name,'*.mat'));
    load(mouse_str_name_dir)
    
    for i = 1:size(dir_struct,1)
        load(fullfile(base_data_dir_name,output_files,dir_struct(i).name));
        
        r_est_tmp = [blobs.r_est];
        r_head_tmp = [blobs.r_head];
        syl_name_c = {blobs.syl_name};
        getNumber=@(s)(str2double(s(4:9)));
        index_tmp = cellfun(getNumber,syl_name_c);
        start_ts_tmp = [blobs.i_start];
        stop_ts_tmp = [blobs.i_end];
        dur_tmp = (stop_ts_tmp-start_ts_tmp)/fc;
        dur_tmp = dur_tmp*1000;
        hf_tmp = [argses.f_hi];
        lf_tmp = [argses.f_lo];
        if i == 1
            r_est = r_est_tmp;
            r_head = r_head_tmp;
            index = index_tmp;
            dur = dur_tmp;
            hf = hf_tmp;
            lf = lf_tmp;
            start_ts = start_ts_tmp;
        else
            r_est = cat(2,r_est,r_est_tmp);
            r_head = cat(2,r_head,r_head_tmp);
            index = cat(2,index,index_tmp);
            dur = cat(2,dur,dur_tmp);
            hf = cat(2,hf,hf_tmp);
            lf = cat(2,lf,lf_tmp);
            start_ts = cat(2,start_ts,start_ts_tmp);
        end
        if isequal(start_ts,[mouse(1:numel(start_ts)).start_sample_fine])==0
            error('Alignment Wrong');
        end
        clear args_common argses base_dir_name blobs date_str_this_trial
        clear job_outputs_dir_name letter_str_this_trial
        clear r_est_tmp r_head_tmp syl_name_val_tmp syl_name_c
        clear start_ts_tmp stop_ts_tmp hf_tmp lf_tmp
        
    end
    %%
    hot_pix = [mouse.hot_pix];
    syl_name_old = [mouse.syl_name_old];
    start_ts = [mouse.start_sample_fine];
    stop_ts = [mouse.stop_sample_fine];
    save_filename1 = sprintf('Results_MUSE_matrix_%s',let_str{1,ds_num});
    save_filename2 = sprintf('Results_MUSE_matrix_ts_%s',let_str{1,ds_num});
    cd(dir1)
    save(save_filename1,'r_est','r_head','index','dur','hf','lf','hot_pix','syl_name_old')
    save(save_filename2,'start_ts','stop_ts')
    
    clear base_data_dir_name dir1 dir_struct dur dur_tmp getNumber
    clear hf hot_pix i index index_tmp lf mouse mouse_str_name_dir
    clear output_files r_est r_head start_ts syl_name_old
end