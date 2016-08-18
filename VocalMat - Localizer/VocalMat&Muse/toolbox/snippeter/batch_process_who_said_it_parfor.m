%batch process who_said_it_parfor2
clc
clear
close all

stop_point = 8;
% matlabpool(8)

%data to process
% date_str=cell(0,1);
% date_str{end+1}='10072012';
% date_str{end+1}='11102012';
% date_str{end+1}='10082012';
% date_str{end+1}='11122012';
% date_str{end+1}='10062012';
% date_str{end+1}='09122012';
% date_str{end+1}='10052012';
% date_str{end+1}='09042012';
% date_str{end+1}='03032013';
% date_str{end+1}='12312012';
% date_str{end+1}='08212012';
% date_str{end+1}='01012013';
% date_str{end+1}='08232012';
% date_str{end+1}='01022013';

[ date_str,let_str,base_dir_name] = fn_create_experimental_list;

for i = 3:stop_point%size(date_str,2)
    date_str_cur = date_str{1,i};
    disp(date_str_cur)
    let_str_cur = let_str{1,i};
    folder1 = 'Data_analysis10\';
    num_virtual_mice = 3;
    num_mice = 1;
    chunk_start_num = 1;  %1 if whole segment was omitted or 2 if whole segment was localized
    scale_size = 14;%size of ruler for scale calibration
   
    %thresholds
    min_seg_time = 5;%ms
    hot_pix_threshold = 11;
    max_freq_threshold = []; %to remove harmonics  Will need to determine
    
    fn_who_said_it_parfor(date_str_cur,let_str_cur,folder1,num_virtual_mice,num_mice,chunk_start_num,scale_size,min_seg_time,hot_pix_threshold, max_freq_threshold,i)
end
% matlabpool close