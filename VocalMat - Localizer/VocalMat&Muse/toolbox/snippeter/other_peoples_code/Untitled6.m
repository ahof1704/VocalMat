clc
close all

prefix_file1 = 'Test_A_1';
noise_rms = zeros(size(i_syl_flat,1),1);
noise_segments = 30;
for chan_num = 4%1:4
    count = 1;
    while count<=size(date_str_flat,1)
        current_date = date_str_flat(count,1);
        current_let = letter_str_flat(count,1);
        count2 = 0;
        range1 = ismember(date_str_flat,current_date);
        range2 = ismember(letter_str_flat,current_let);
        range_date = range1 == 1;
        range_let = range2 == 1;
        merged_date_let = range_date + range_let;
        range = find(merged_date_let==2);
        for i = range(1):range(end)
            count2 = count2 + 1;
            if i==range(1)
                dir1 = sprintf('A:\\Neunuebel\\ssl_sys_test\\sys_test_%s\\demux\\',char(current_date));
                dir2 = sprintf('A:\\Neunuebel\\ssl_sys_test\\sys_test_%s\\',char(current_date));
                filename_prefix2 = sprintf('Test_%s_1.ch%d',char(current_let),chan_num); %signal
                filename_prefix1 = sprintf('%s.ch%d',prefix_file1,chan_num);%noise
                cd (dir2)
                load('Test_A_1_video_pulse_start_ts')
                start_ts_n = video_pulse_start_ts(1);
                stop_ts_n = video_pulse_start_ts(end);
                cd (dir1)
                foo = start_ts_n:stop_ts_n;
                fid = fopen(filename_prefix1,'r');
                fseek(fid, start_ts_n*4, -1);
                signal = fread(fid,size(foo,2),'float32');
                fclose(fid);
                clear m_n start_ts_n stop_ts_n 
            end
            hf = high_f(count,1);
            lf = low_f(count,1);
            size_signal = size(signal,1);
            signal_steps = floor(linspace(1,size_signal,noise_segments));
            nrms = zeros(noise_segments-1,1);
            for ii = 2:size(signal_steps,2)
                signal2 = signal(signal_steps(1,ii-1):(signal_steps(1,ii)-1));
                nrms(ii-1,1) = calculate_channel_rms2(signal2, hf, lf, fc);
                clear signal2
            end
            %             noise_rms(count,chan_num) = mean(nrms);noise_rms(count,chan_num) = mean(nrms);
            noise_rms(count,1) = mean(nrms);
            count = count + 1;
            clear start_point end_point low_f_t high_f_t signal_steps
        end
        clear range range2 current mouse signal nrms
    end
end