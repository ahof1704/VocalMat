clc
clear
close all

dir1_list{1,1} = 'A:\Neunuebel\ssl_sys_test\sys_test_06052012\Data_analysis';
dir1_list{2,1} = 'A:\Neunuebel\ssl_sys_test\sys_test_06062012\Data_analysis';
dir1_list{3,1} = 'A:\Neunuebel\ssl_sys_test\sys_test_06102012\Data_analysis';
dir1_list{4,1} = 'A:\Neunuebel\ssl_sys_test\sys_test_06112012\Data_analysis';
dir1_list{5,1} = 'A:\Neunuebel\ssl_sys_test\sys_test_06122012\Data_analysis';
dir1_list{6,1} = 'A:\Neunuebel\ssl_sys_test\sys_test_06132012\Data_analysis';

filename_list{1,1} = 'Test_D_1_Mouse.mat';
filename_list{2,1} = 'Test_E_1_Mouse.mat';
filename_list{3,1} = 'Test_E_1_Mouse.mat';
filename_list{4,1} = 'Test_D_1_Mouse.mat';
filename_list{5,1} = 'Test_D_1_Mouse.mat';
filename_list{5,2} = 'Test_E_1_Mouse.mat';
filename_list{6,1} = 'Test_D_1_Mouse.mat';
filename_list{6,2} = 'Test_E_1_Mouse.mat';
%saving directory
% dir1 = 'A:\Neunuebel\ssl_sys_test\sys_test_07032012\Data_analysis';
count = 0;
for i = 1:size(dir1_list,1)
    cd (dir1_list{i,1})
    cd ..
    dir2 = pwd;
    s=load('meters_2_pixels.mat'); %saved conversion factor calculated with based on recorded tape measure on video
    meters_2_pixels = s.meters_2_pixels;
    clear s;
    for j = 1:size(filename_list,2)
        if ~isempty(filename_list{i,j})
            count = count + 1;
            dummy = filename_list{i,j};
            video_fname_prefix = dummy(1:8);
            clear dummy
            vfilename = sprintf('%s.seq',video_fname_prefix);
            [corners_out, handle1] = fn_corner_pos_location(dir2,vfilename,meters_2_pixels,'n', video_fname_prefix);
            close (handle1)
        end
    end
end

