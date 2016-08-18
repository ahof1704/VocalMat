function [dir1 dir2 saving_dir] = fn_beamforming_directory_names(exp_folder,date_str,mouse_structure_dir,num_mice)

if num_mice > 1
    dir2 = sprintf('A:\\Neunuebel\\%s\\%s\\',exp_folder,date_str);%root directory
else
    dir2 = sprintf('A:\\Neunuebel\\%s\\sys_test_%s\\',exp_folder,date_str);
end

dir1 = sprintf('%sdemux\\',dir2);%directory with audio files
saving_dir = sprintf('%s%s\\',dir2,mouse_structure_dir);%also the directory where data structure resides
