function [new_mouse new_mouse_video] = fn_chunk_vocalization_time_range7(mouse,frame_rate,fc, video_pulse_start_ts,dur_chunk,freq_contours2,min_hot_pixels)
%assign frame number to chunk of vocal segment
%frame number assignment based on chunk of vocal segment start and stop
%falling within the range of time stamps associated with the frame
count = 0;
id = 'MATLAB:sprintf:InputForPercentSIsNotOfClassChar';
warning('off',id)

for i_segment = 1:size(mouse,2)
%     disp(index1)
    this_mouse = mouse(i_segment);
    syl_str = this_mouse.syl_name;
    syl_val = str2double(syl_str(4:end));
    start_ts = this_mouse.start_sample_fine;
    stop_ts = this_mouse.stop_sample_fine;
    
    [ frame_number,frame_number_ts ] = fn_extract_frames2( video_pulse_start_ts, start_ts, stop_ts );
    
    %num = num2str(i_segment);
    %num = fn_numPad(num,6);
    
    %syl_name = sprintf('Voc%s_0',num);
    tmp_name = this_mouse.syl_name;
    
    pos1 = strfind(tmp_name,'Voc');    
    voc_list_orig_loc = str2double(tmp_name(pos1+3:end));
    %setting up time frequency grid
    freql = floor(this_mouse.lf_fine/1000);
    if mod(freql,2)==1
        freql = freql-1;
    end
    freql = freql*1000;
    freqh = ceil(this_mouse.hf_fine/1000);
    if mod(freqh,2)==1
        freqh = freqh + 1;
    end
    freqh = freqh*1000;
    f_bins = freql:2000:freqh;
    t_bins_samples =  start_ts:ceil(dur_chunk*fc)+1:stop_ts;
    t_bins_sec = t_bins_samples/fc;
    %looking at all parts of freq_contour2 file associated with segment
    for i = 1:size(freq_contours2{1,voc_list_orig_loc},2)
        count2 = 0;
        count3 = 0;
        edges = cell(1,2);
        b1 = freq_contours2{1,voc_list_orig_loc}{1,i};
        t = b1(:,1);
        f = b1(:,2);
        edges{1,1} = t_bins_sec;
        edges{1,2} = f_bins;
        N = hist3([t f],'Edges',edges);
        N(:,end) = [];
        N(end,:) = [];        
        [toi foi] = find(N>min_hot_pixels);
        clear foi
        for t_find = min(toi):max(toi)
            count2 = count2 + 1;
            foi = find(N(t_find,:)>min_hot_pixels);
            cur_start_ts = t_bins_samples(t_find);
            cur_stop_ts = t_bins_samples(t_find+1)-1;
            [smallest_value smallest_loc] = min(abs(frame_number_ts-cur_start_ts));
            closest_frame = frame_number(smallest_loc);
            for f_find = 1:size(foi,2)                
                count = count + 1;
                count3 = count3 + 1;                
                %count3_s = fn_numPad(count3,3);
                %i_s = fn_numPad(i,2);
                new_mouse(1,count).syl_name = sprintf('Voc%06d_%s%02d_%03d',i_segment,char(96+count2),i,count3);
                new_mouse(1,count).syl_name_old = syl_val;
                new_mouse(1,count).lf_fine = f_bins(foi(f_find));
                new_mouse(1,count).hf_fine = f_bins(foi(f_find)+1)-1;
                new_mouse(1,count).start_sample_fine = cur_start_ts;
                new_mouse(1,count).stop_sample_fine = cur_stop_ts;
                new_mouse(1,count).index = i_segment;
                new_mouse(1,count).hot_pix = N(t_find,foi(f_find));
                new_mouse(1,count).frame_range = frame_number; %frames associated with entire segment
                new_mouse(1,count).frame_range_ts = frame_number_ts; %frame time stamps associated with entire segment
                new_mouse(1,count).frame_number = closest_frame; %closest frame associated with chunk
                
                new_mouse_video(1,count).frame_range = frame_number; %frames associated with entire segment
                new_mouse_video(1,count).frame_range_ts = frame_number_ts; %frame time stamps associated with entire segment
                new_mouse_video(1,count).frame_number = closest_frame; %closest frame associated with chunk
                
                clear smallest_loc smallest_value
            end
            clear foi
        end
        clear toi
    end
    clear closest_frame_ts syl_val
end
% disp(1)


