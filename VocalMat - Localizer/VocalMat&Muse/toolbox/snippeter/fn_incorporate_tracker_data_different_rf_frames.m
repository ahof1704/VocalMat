function [ mouse_position ] = fn_incorporate_tracker_data_different_rf_frames( tracker_data,mouse,num_mice )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%this fucntion takes into consideration the differnce in axis orientations
%between manual and motr

%correct for reversals-function replaces the reversed theta's
index=cellfun(@(x) x(1),{mouse.frame_number});
astrctTrackers = fn_ScriptTestChooseOrientations_jpn(tracker_data,num_mice,max(index)+1);
%converts Motr data to meters etc...

flip_y_point = 768;
mouse_position(1:size(mouse,2)) = struct('nose_x',zeros(1,num_mice),...
                                         'nose_y',zeros(1,num_mice),...
                                         'tail_x',zeros(1,num_mice),...
                                         'tail_y',zeros(1,num_mice));
for mouse_num = 1:num_mice
    %calculates position of nose
    [nose_x nose_y tail_x tail_y x y a b theta] = find_nose_tail_jpn3(astrctTrackers,index,mouse_num);

    % rotate 90 CCW and switch to axis ij for nose
    s_n = [nose_y;nose_x]; %s_n(1) = x cord s_n(2) = y cord
    s_n(1,:) = abs(s_n(1,:)-flip_y_point);
    nose_x = s_n(1,:);
    nose_y = s_n(2,:);
    clear s_n

    % rotate 90 CCW and switch to axis ij for tail
    s_n = [tail_y;tail_x]; %s_n(1) = x cord s_n(2) = y cord
    s_n(1,:) = abs(s_n(1,:)-flip_y_point);
    tail_x = s_n(1,:);
    tail_y = s_n(2,:);
    clear s_n
        
%     % rotate 90 CCW and switch to axis ij for nose
%     s_n = [y;x]; %s_n(1) = x cord s_n(2) = y cord
%     s_n(1,:) = abs(s_n(1,:)-flip_y_point);
%     x = s_n(1,:);
%     y = s_n(2,:);
%     clear s_n
    
    for populate = 1:size(mouse,2)
        mouse_position(populate).pos_data_nose_x(1,mouse_num) = nose_x(populate);
        mouse_position(populate).pos_data_nose_y(1,mouse_num) = nose_y(populate);
        mouse_position(populate).pos_data_tail_x(1,mouse_num) = tail_x(populate);
        mouse_position(populate).pos_data_tail_y(1,mouse_num) = tail_y(populate);
%         mouse(populate).pos_data(1,mouse_num).x = x(populate);
%         mouse(populate).pos_data(1,mouse_num).y = y(populate);
%         mouse(populate).pos_data(1,mouse_num).a = a(populate);
%         mouse(populate).pos_data(1,mouse_num).b = b(populate);
%         mouse(populate).pos_data(1,mouse_num).theta = theta(populate);
    end
    clear nose_x nose_y tail_x tail_y x y a b theta
end

