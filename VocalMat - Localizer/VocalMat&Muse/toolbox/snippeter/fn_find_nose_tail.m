function [ mouse ] = fn_find_nose_tail( tracker_data,mouse,num_mice )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
for mouse_num = 1:num_mice
    %correct for reversals-function replaces the reversed theta's
    astrctTrackers = fn_ScriptTestChooseOrientations_jpn(tracker_data,mouse_num);
    %converts Motr data to meters etc...
    index=cellfun(@(x) x(1),{mouse.frame_range});
    %calculates position of nose
    [nose_x nose_y tail_x tail_y] = find_nose_tail_jpn2(astrctTrackers,index);
    for populate = 1:size(mouse,2)
        mouse(populate).pos_data(1,mouse_num).nose_x = nose_x(populate);
        mouse(populate).pos_data(1,mouse_num).nose_y = nose_y(populate);        
        mouse(populate).pos_data(1,mouse_num).tail_x = tail_x(populate);
        mouse(populate).pos_data(1,mouse_num).tail_y = tail_y(populate);
    end
end

