function Experiment_list = fn_load_saved_voc_file_list(temp_list,fn_load_saved_voc_file_list,number_sessions)
%creats a matrix with the temps at time of recording
if strcmp(fn_load_saved_voc_file_list,'y')==1
    load(temp_list)
else
    for i = 1:number_sessions
%         Experiment_list{i,1} = input('What is the name of the vocalization list (i.e., ''Test_B_1_voc_list'')?');
        Experiment_list{i,1} = 'Test_B_1_voc_list';
    end
    save('Experiment_list','Experiment_list')
end
