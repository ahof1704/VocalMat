function new_mouse = fn_chunk_vocalization_time_range2(mouse,frame_rate,fc, video_pulse_start_ts)
%assign frame number to chunk of vocal segment
%frame number assignment based on chunk of vocal segment start and stop 
%falling within the range of time stamps associated with the frame 
count = 0;
id = 'MATLAB:sprintf:InputForPercentSIsNotOfClassChar';
warning('off',id)
for index1 = 1:size(mouse,2)
    this_mouse = mouse(index1);
    start_ts = this_mouse.start_sample_fine;
    stop_ts = this_mouse.stop_sample_fine;
    
    [ frame_number,frame_number_ts ] = fn_extract_frames2( video_pulse_start_ts, start_ts, stop_ts );
    
    count = count + 1;
    num = num2str(index1);
    num = fn_numPad(num,5);
    
    new_mouse(1,count).syl_name = sprintf('Voc%s_0',num);
    new_mouse(1,count).syl_name_old = this_mouse.syl_name;
    new_mouse(1,count).lf_fine = this_mouse.lf_fine;
    new_mouse(1,count).hf_fine = this_mouse.hf_fine;
    new_mouse(1,count).start_sample_fine = start_ts;
    new_mouse(1,count).stop_sample_fine = stop_ts;
    new_mouse(1,count).filtering = 'y';
    new_mouse(1,count).index = index1;
    new_mouse(1,count).frame_range = frame_number;
    new_mouse(1,count).frame_range_ts = frame_number_ts;
    new_mouse(1,count).frame_number = frame_number(1);
    
    
    count2 = 96;
    for t = 1:size(frame_number_ts,2)-1
        frame_start = frame_number_ts(t);
        frame_end = frame_number_ts(t+1);
        if frame_start>=start_ts
            ts1 = frame_start+1;
        else
            ts1 = start_ts;
        end
        
        if frame_end<=stop_ts
            ts2 = frame_end;
        else
            ts2 = stop_ts;
        end
        count2 = count2 + 1;
        count = count + 1;
        new_mouse(1,count).syl_name = sprintf('Voc%s_%s',num,count2);
        new_mouse(1,count).syl_name_old = this_mouse.syl_name;
        new_mouse(1,count).lf_fine = this_mouse.lf_fine;
        new_mouse(1,count).hf_fine = this_mouse.hf_fine;
        new_mouse(1,count).start_sample_fine = ts1;
        new_mouse(1,count).stop_sample_fine = ts2;        
        new_mouse(1,count).filtering = 'y';
        new_mouse(1,count).index = index1;
        new_mouse(1,count).frame_range = frame_number;
        new_mouse(1,count).frame_range_ts = frame_number_ts;
        new_mouse(1,count).frame_number = frame_number(t);
        clear frame_start frame_end ts1 ts2
    end
    clear this_mouse start_ts stop_ts
    %         disp([new_mouse(1,count).start_sample_fine new_mouse(1,count).stop_sample_fine])
    %           new_mouse(1,count).frame_range =
    %              pos_data: [1x1 struct]
    %     frame_number(count,1) = :
end



