%need to correct theta for reversals
%need to rotate data to correspond to manual selections

clc
clear
close all

%data directories
dir1_list{1,1} = 'A:\Neunuebel\ssl_sys_test\sys_test_06052012\Data_analysis';
dir1_list{2,1} = 'A:\Neunuebel\ssl_sys_test\sys_test_06062012\Data_analysis';
dir1_list{3,1} = 'A:\Neunuebel\ssl_sys_test\sys_test_06102012\Data_analysis';
dir1_list{4,1} = 'A:\Neunuebel\ssl_sys_test\sys_test_06112012\Data_analysis';
dir1_list{5,1} = 'A:\Neunuebel\ssl_sys_test\sys_test_06122012\Data_analysis';
dir1_list{6,1} = 'A:\Neunuebel\ssl_sys_test\sys_test_06132012\Data_analysis';

%sound source localization structure filenames
filename_list{1,1} = 'Test_D_1_Mouse.mat';
filename_list{2,1} = 'Test_E_1_Mouse.mat';
filename_list{3,1} = 'Test_E_1_Mouse.mat';
filename_list{4,1} = 'Test_D_1_Mouse.mat';
filename_list{5,1} = 'Test_D_1_Mouse.mat';
filename_list{5,2} = 'Test_E_1_Mouse.mat';
filename_list{6,1} = 'Test_D_1_Mouse.mat';
filename_list{6,2} = 'Test_E_1_Mouse.mat';

%mouse house structure filenames
filename_list2{1,1} = 'Test_D_1.mat';
filename_list2{2,1} = 'Test_E_1.mat';
filename_list2{3,1} = 'Test_E_1.mat';
filename_list2{4,1} = 'Test_D_1.mat';
filename_list2{5,1} = 'Test_D_1.mat';
filename_list2{5,2} = 'Test_E_1.mat';
filename_list2{6,1} = 'Test_D_1.mat';
filename_list2{6,2} = 'Test_E_1.mat';

%sound source localization structure filenames
filename_list3{1,1} = 'Test_D_1_Mouse_b.mat';
filename_list3{2,1} = 'Test_E_1_Mouse_b.mat';
filename_list3{3,1} = 'Test_E_1_Mouse_b.mat';
filename_list3{4,1} = 'Test_D_1_Mouse_b.mat';
filename_list3{5,1} = 'Test_D_1_Mouse_b.mat';
filename_list3{5,2} = 'Test_E_1_Mouse_b.mat';
filename_list3{6,1} = 'Test_D_1_Mouse_b.mat';
filename_list3{6,2} = 'Test_E_1_Mouse_b.mat';

for i = 1:size(dir1_list,1)
    for j = 1:size(filename_list,2)
        if ~isempty(filename_list{i,j})
            cd (dir1_list{i,1})
            load(filename_list{i,j})
            cd ..
            load('meters_2_pixels.mat')
            cd Results\Tracks
            load(filename_list2{i,j})
            %correct for reversals-function replaces the reversed theta's
            astrctTrackers = fn_ScriptTestChooseOrientations_jpn(astrctTrackers);
            %converts Motr data to meters etc...
            track = prep_trajectory_jpn(astrctTrackers, 29, meters_2_pixels);
            index=cellfun(@(x) x(1),{mouse.frame_range});
            %calculates position of nose
            [nose_x nose_y nose_x_r nose_y_r tail_x tail_y tail_x_r tail_y_r] = find_nose_tail_jpn(track,index,meters_2_pixels, 'y');
            for populate = 1:size(mouse,2)
                mouse(populate).pos_data_Motr.nose_x = nose_x(populate);
                mouse(populate).pos_data_Motr.nose_y = nose_y(populate);
                mouse(populate).pos_data_Motr.nose_x_r = nose_x_r(populate);
                mouse(populate).pos_data_Motr.nose_y_r = nose_y_r(populate);
                
                mouse(populate).pos_data_Motr.tail_x = tail_x(populate);
                mouse(populate).pos_data_Motr.tail_y = tail_y(populate);
                mouse(populate).pos_data_Motr.tail_x_r = tail_x_r(populate);
                mouse(populate).pos_data_Motr.tail_y_r = tail_y_r(populate);
                
            end
            %             manual=cellfun(@(x) x(1),{mouse.pos_data});
            %             manual_x = cellfun(@(x) x(1),{manual.x_head});
            %             manual_y = cellfun(@(x) x(1),{manual.y_head});
            %             motr = cellfun(@(x) x(1),{mouse.pos_data_Motr});
            %             motr_x_r = cellfun(@(x) x(1),{motr.nose_x_r});
            %             motr_y_r = cellfun(@(x) x(1),{motr.nose_y_r});
            %             motr_x = cellfun(@(x) x(1),{motr.nose_x});
            %             motr_y = cellfun(@(x) x(1),{motr.nose_y});
            %             figure
            %             plot(manual_x(1:10)*meters_2_pixels,manual_y(1:10)*meters_2_pixels,'r.',...
            %                 motr_x_r(1:10)*meters_2_pixels,motr_y_r(1:10)*meters_2_pixels,'g.',...
            %                 motr_x(1:10)*meters_2_pixels,motr_y(1:10)*meters_2_pixels,'b.')
            
%             manual=cellfun(@(x) x(1),{mouse.pos_data});
%             manual_x = cellfun(@(x) x(1),{manual.x_tail});
%             manual_y = cellfun(@(x) x(1),{manual.y_tail});
%             motr = cellfun(@(x) x(1),{mouse.pos_data_Motr});
%             motr_x_r = cellfun(@(x) x(1),{motr.tail_x_r});
%             motr_y_r = cellfun(@(x) x(1),{motr.tail_y_r});
%             motr_x = cellfun(@(x) x(1),{motr.tail_x});
%             motr_y = cellfun(@(x) x(1),{motr.tail_y});
%             figure
%             plot(manual_x(1:10)*meters_2_pixels,manual_y(1:10)*meters_2_pixels,'r.',...
%                 motr_x_r(1:10)*meters_2_pixels,motr_y_r(1:10)*meters_2_pixels,'g.',...
%                 motr_x(1:10)*meters_2_pixels,motr_y(1:10)*meters_2_pixels,'b.')
            
%             disp(1)
            cd (dir1_list{i,1})
            save(filename_list3{i,j},'mouse');
            clear mouse meters_2_pixels astrctTrackers strMovieFileName track index nose*
        end
    end
end