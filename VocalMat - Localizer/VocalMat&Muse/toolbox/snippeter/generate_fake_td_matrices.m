clc
close all
clear

%for example of ssl
load('A:\Neunuebel\ssl_sys_test\sys_test_06052012\Data_analysis\Test_D_1_Mouse.mat')
this_voc = mouse(120);
video_fname_prefix = 'Test_D_1';
dir1 = 'A:\Neunuebel\ssl_sys_test\sys_test_06052012\demux';
dir2 = 'A:\Neunuebel\ssl_sys_test\sys_test_06052012\';
clear mouse
fc = 450450;

session_num = 1; %used for temp recordings in quad example
cd (dir1)
cd ..
load meters_2_pixels
load_saved_corners = 'y';
vfilename = sprintf('%s.seq',video_fname_prefix);
[corners_out, handle1] = fn_corner_pos_location(dir2,vfilename,meters_2_pixels,load_saved_corners, video_fname_prefix);
clear handle1
load positions_out
[ range_x, range_y ] = fn_range_x_y_cords( corners_out );
load temps
T = temps(session_num,1);
Vsound = fn_velocity_sound(T);
[ cord_based_estimate, i_pos, j_pos, box_estimated_delta_t ] = fn_box_estimated_delta_t( range_x, range_y, positions_out, Vsound, meters_2_pixels);


start_point = this_voc.start_sample_fine;
end_point = this_voc.stop_sample_fine;
cd demux
for ch_num = 1:4
    filename = sprintf('%s.ch%d',video_fname_prefix,ch_num);
    % precision = 'float32';
    
    m = memmapfile(filename,         ...
        'Offset', 0,        ...
        'Format', 'single',    ...
        'Writable', false);
    switch isnumeric(ch_num)
        case ch_num == 1
            ach1 = m.Data(start_point:end_point);
        case ch_num == 2
            ach2 = m.Data(start_point:end_point);
        case ch_num == 3
            ach3 = m.Data(start_point:end_point);
        case ch_num == 4
            ach4 = m.Data(start_point:end_point);
    end
    clear filename m
end

low = this_voc.lf_fine;
high = this_voc.hf_fine;
if low>high
    tmp_frq = low;
    low = high;
    high = tmp_frq;
end

foo12 = rfilter(ach1,low,high,fc);
clear ach1
ach1 = foo12;
clear foo12;
foo12 = rfilter(ach2,low,high,fc);
clear ach2
ach2 = foo12;
clear foo12;
foo12 = rfilter(ach3,low,high,fc);
clear ach3
ach3 = foo12;
clear foo12;
foo12 = rfilter(ach4,low,high,fc);
clear ach4
ach4 = foo12;
clear foo12;

xcorr12 = abs(xcorr(ach1,ach2,'coef'));
xcorr13 = xcorr(ach1,ach3,'coef');
xcorr14 = xcorr(ach1,ach4,'coef');
xcorr23 = xcorr(ach2,ach3,'coef');
xcorr24 = xcorr(ach2,ach4,'coef');
xcorr34 = xcorr(ach3,ach4,'coef');

tmp = size(ach1,1)-1:-1:1;
tmp2 = 1:size(ach1,1)-1;
tmp3 = [-tmp 0 tmp2];
sample_delay_locs = tmp3/fc;
clear tmp tmp2 tmp3

% foo = this_voc.pos_data;
% estimated_delta_t = fn_equations( positions_out, Vsound, foo, meters_2_pixels);
% for td_pair = 1:size(box_estimated_delta_t,2);
%     tds = box_estimated_delta_t(:,td_pair);
%     td_r = estimated_delta_t(1,td_pair);
%     for count = 1:size(tds,1)
%         i = i_pos(count,1);
%         j = j_pos(count,1);
%         cord_based_estimate(j,i,td_pair) = tds(count);
%     end
%     map = cord_based_estimate(:,:,td_pair);
%     tmp = ~isnan(map);
%     [j2 i2] = find(tmp==1);
%     good_area = map(min(j2):max(j2),min(i2):max(i2));
%     new_map = zeros(size(good_area));
%     for i3 = 1:size(good_area,2)
%         for j3 = 1:size(good_area,1)
%             td_c = good_area(j3,i3)
%             foo1 = find(sample_delay_locs<=td_c);
%             foo2 = find(sample_delay_locs>=td_c);
%             xcorr12(foo1(end):foo2(1))
%             new_map(j3,i3) = mean(xcorr12(foo1(end):foo2(1)));            
%         end
%     end
%         
%     clear tds tmp td_r
% end

% 
% disp(foo)

cd(dir2)
fn_FigureTrackFrame_jpn_rotate(vfilename,this_voc.frame_range(1))
[x y] = ginput(1)
foo.x_head = x;
foo.y_head = y;
estimated_delta_t = fn_equations( positions_out, Vsound, foo, meters_2_pixels);
estimated_delta_t(4)
clear foo estimated_delta_t x y

