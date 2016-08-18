function new_mouse = fn_chunk_vocalization_time_range5(mouse,frame_rate,fc, video_pulse_start_ts,dur_chunk)
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
    
    [smallest_value smallest_loc] = min(abs(frame_number_ts-start_ts));
    closest_frame = frame_number(smallest_loc);
    
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
    new_mouse(1,count).frame_number = closest_frame;%frame_number(1);
    
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
    
    clear closest_frame_ts smallest_loc smallest_value
    count2 = 96;
    count3 = 0;
    for t = start_ts:ceil(dur_chunk*fc)+1:stop_ts
        count2 = count2 + 1;
        cur_start_ts = t;
        %need if then statement to
        cur_stop_ts = t+ceil(dur_chunk*fc);
        if cur_stop_ts>stop_ts
            cur_stop_ts = stop_ts;
        end
        if ((cur_stop_ts-cur_start_ts)<((fc/1000)*5))
            break
        end
        
        [smallest_value smallest_loc] = min(abs(frame_number_ts-cur_start_ts));
        closest_frame = frame_number(smallest_loc);
        
        for f = freql:2000:freqh
            count3 = count3 + 1;
            %             need to add zeros in front of count3 for ordering
            if (count3<10)
                count3_s = sprintf('000%g',count3);
            elseif (count3>=10) && (count3<100)
                count3_s = sprintf('00%g',count3);
            elseif (count3>=100) && (count3<1000)
                count3_s = sprintf('0%g',count3);
            elseif (count3>=1000)
                count3_s = sprintf('%g',count3);
            end
            
            count = count + 1;
            new_mouse(1,count).syl_name = sprintf('Voc%s_%s_%s',num,count2,count3_s);
            new_mouse(1,count).syl_name_old = this_mouse.syl_name;
            new_mouse(1,count).lf_fine = f;
            new_mouse(1,count).hf_fine = f+1999;
            new_mouse(1,count).start_sample_fine = cur_start_ts;
            new_mouse(1,count).stop_sample_fine = cur_stop_ts;
            new_mouse(1,count).filtering = 'y';
            new_mouse(1,count).index = index1;
            new_mouse(1,count).frame_range = frame_number;
            new_mouse(1,count).frame_range_ts = frame_number_ts;
            new_mouse(1,count).frame_number = closest_frame;
        end
        clear frame_start frame_end ts1 ts2 smallest_value smallest_loc closest_frame f 
    end
    clear this_mouse start_ts stop_ts freql freqh
    %         disp([new_mouse(1,count).start_sample_fine new_mouse(1,count).stop_sample_fine])
    %           new_mouse(1,count).frame_range =
    %              pos_data: [1x1 struct]
    %     frame_number(count,1) = :
end
disp(1)




