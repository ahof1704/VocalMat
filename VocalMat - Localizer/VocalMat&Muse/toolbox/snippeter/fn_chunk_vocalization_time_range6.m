function new_mouse = fn_chunk_vocalization_time_range6(mouse,frame_rate,fc, video_pulse_start_ts,dur_chunk,freq_contours2)
%assign frame number to chunk of vocal segment
%frame number assignment based on chunk of vocal segment start and stop
%falling within the range of time stamps associated with the frame
count = 0;
id = 'MATLAB:sprintf:InputForPercentSIsNotOfClassChar';
warning('off',id)
c =[0,0,1.0000;
    0,0.5000,0;
    1.0000,0,0;
    0,0.7500,0.7500;
    0.7500,0,0.7500;
    0.7500,0.7500,0;
    0.2500,0.2500,0.2500;
    0,0,1.0000;
    0,0.5000,0;
    1.0000,0,0;
    0,0.7500,0.7500;
    0.7500,0,0.7500];

for index1 = 1:size(mouse,2)
%     disp(index1)
    this_mouse = mouse(index1);
    start_ts = this_mouse.start_sample_fine;
    stop_ts = this_mouse.stop_sample_fine;
    
    [ frame_number,frame_number_ts ] = fn_extract_frames2( video_pulse_start_ts, start_ts, stop_ts );
    
    [smallest_value smallest_loc] = min(abs(frame_number_ts-start_ts));
    closest_frame = frame_number(smallest_loc);
    
    count = count + 1;
    num = num2str(index1);
    num = fn_numPad(num,6);
    
    new_mouse(1,count).syl_name = sprintf('Voc%s_0',num);
    new_mouse(1,count).syl_name_old = this_mouse.syl_name;
    new_mouse(1,count).lf_fine = this_mouse.lf_fine;
    new_mouse(1,count).hf_fine = this_mouse.hf_fine;
    new_mouse(1,count).start_sample_fine = start_ts;
    new_mouse(1,count).stop_sample_fine = stop_ts;
%     new_mouse(1,count).filtering = 'y';
    new_mouse(1,count).index = index1;
    new_mouse(1,count).frame_range = frame_number;
    new_mouse(1,count).frame_range_ts = frame_number_ts;
    new_mouse(1,count).frame_number = closest_frame;%frame_number(1);
    new_mouse(1,count).hot_pix = NaN;
    tmp_name = new_mouse(1,count).syl_name_old;
    pos1 = strfind(tmp_name,'Voc');
    
    voc_list_orig_loc = str2double(tmp_name(pos1+3:end));
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
    
    for i = 1:size(freq_contours2{1,voc_list_orig_loc},2)
        count2 = 96;
        count3 = 0;
        color_s = c(i,:);
        edges = cell(1,2);
        b1 = freq_contours2{1,voc_list_orig_loc}{1,i};
        t = b1(:,1);
        f = b1(:,2);
%         (t(end)-t(1))*fc
        edges{1,1} = t_bins_sec;
        edges{1,2} = f_bins;
%         figure; hist3([t f],'Edges',edges)
        N = hist3([t f],'Edges',edges);
        N(:,end) = [];
        N(end,:) = [];        
%         figure; scatter(t,f,'marker','o','markerfacecolor',color_s);
        [toi foi] = find(N>0);
        clear foi
        for t_find = min(toi):max(toi)%1:size(toi,1)%t_find = 1:size(N,1)
            count2 = count2 + 1;
            foi = find(N(t_find,:)>0);
            cur_start_ts = t_bins_samples(t_find);
            cur_stop_ts = t_bins_samples(t_find+1)-1;
            %             cur_start_ts = t_bins_samples(t_find);
            %             cur_stop_ts = t_bins_samples(t_find+1);
            [smallest_value smallest_loc] = min(abs(frame_number_ts-cur_start_ts));
            closest_frame = frame_number(smallest_loc);
            for f_find = 1:size(foi,2)                
                count = count + 1;
                count3 = count3 + 1;                
                count3_s = fn_numPad(count3,3); %for turning count3 into a string
                i_s = fn_numPad(i,2);
                new_mouse(1,count).syl_name = sprintf('Voc%s_%s%s_%s',num,count2,i_s,count3_s);
                new_mouse(1,count).syl_name_old = this_mouse.syl_name;
                new_mouse(1,count).lf_fine = f_bins(foi(f_find));%
                new_mouse(1,count).hf_fine = f_bins(foi(f_find)+1)-1;%f+1999;
                new_mouse(1,count).start_sample_fine = cur_start_ts;
                new_mouse(1,count).stop_sample_fine = cur_stop_ts;
%                 new_mouse(1,count).filtering = 'y';
                new_mouse(1,count).index = index1;
                new_mouse(1,count).frame_range = frame_number;
                new_mouse(1,count).frame_range_ts = frame_number_ts;
                new_mouse(1,count).frame_number = closest_frame;
                new_mouse(1,count).hot_pix = N(t_find,foi(f_find));
                clear smallest_loc smallest_value
            end
            clear foi
        end
        clear toi
    end
    clear closest_frame_ts
end
% disp(1)




