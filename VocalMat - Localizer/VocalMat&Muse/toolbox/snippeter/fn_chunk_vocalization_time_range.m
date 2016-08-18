function new_mouse = fn_chunk_vocalization_time_range(mouse,frame_rate,fc)
chunk_size = ceil((frame_rate/2)*fc);
count = 0;
for index1 = 1:size(mouse,2)
    this_mouse = mouse(index1);
    start_ts = this_mouse.start_sample_fine;
    stop_ts = this_mouse.stop_sample_fine;
    for t = start_ts:chunk_size:stop_ts
        stop_t = t+chunk_size-1;
        diff_stop_t_t = stop_ts-t;
        if diff_stop_t_t>2253%2253 is the ceil of 0.005 seconds worth of sampling
            count = count + 1;
            new_mouse(1,count).syl_name = sprintf('Voc%d',count);
            new_mouse(1,count).syl_name_old = this_mouse.syl_name;
            new_mouse(1,count).lf_fine = this_mouse.lf_fine;
            new_mouse(1,count).hf_fine = this_mouse.hf_fine;
            new_mouse(1,count).start_sample_fine = t;
            if stop_t < stop_ts
                new_mouse(1,count).stop_sample_fine = stop_t;
            else
                new_mouse(1,count).stop_sample_fine = stop_ts;
            end
            new_mouse(1,count).filtering = 'y';
            new_mouse(1,count).index = index1;
        end
        %         disp([new_mouse(1,count).start_sample_fine new_mouse(1,count).stop_sample_fine])
        %           new_mouse(1,count).frame_range =
        %              pos_data: [1x1 struct]
        %     frame_number(count,1) = :
    end
end


