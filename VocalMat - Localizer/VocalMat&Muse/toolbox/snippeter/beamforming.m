clc
clear
close all

dir1 = 'C:\Users\neunuebelj\Documents\Lab\Beamforming\Exp2';%location of enviroment images
dir2 = 'data';%location of data
dir3 = 'demux';%location of sound recordings
dir4 = 'analysis';%location of analysis and saving processed data
dir5 = 'plot';
dir6 = 'spectrogram';
dir7 = 'xcorr';
dir8 = 'transfer_function';
dir9 = 'voltage';
dir10 = 'full';
dir11 = 'trunc';
dir12 = 'Camera 1';
dir13 = 'summation';
dir14 = 'circle_shift';

if ispc == 1
    slash_type = '\';
else
    slash_type = '/';
end

imagefile = '4ch_posA';
mic_pos = 'A';
fmt = 'jpg';
x_m = 0.6096;  %size of one wall of square box in meters
fname_prefix = '4ch_posA_1';
center_sample = 3;
window_s = .05;
precision = 'float32';
plot_abride = 'y';
summing = 'y';
corr_cal = 'n';
create_shift_sig = 'y';
plot_full = 'y';
fc = 200000;

if strcmp(create_shift_sig,'y')==1
    t_dir = sprintf('%s%s%s%s%s',dir1,slash_type,dir2,slash_type,dir12);
    if isdir(t_dir) == 0
        mkdir (t_dir)
    end
    cd (t_dir)
    image_matrix = imread(imagefile, fmt);
    image_matrix_r = image_matrix;% imrotate(image_matrix,270);%rotates camera position so that microphone 1 is located in upper left corner
    info = imfinfo(imagefile,fmt);
    [positions_out,poi,meters_per_pixel] = position_calib(image_matrix_r,x_m);
    
    t_dir = sprintf('%s%s%s%s%s',dir1,slash_type,dir2,slash_type,dir3);
    if isdir(t_dir) == 0
        mkdir (t_dir)
    end
    cd (t_dir)
    signal_out = shift_signal(positions_out,poi,fname_prefix,center_sample,window_s,fc,precision,t_dir);
    
    t_dir = sprintf('%s%s%s',dir1,slash_type,dir2);
    if isdir(t_dir) == 0
        mkdir (t_dir)
    end
    cd (t_dir)
    sfname = sprintf('signal_out%s',mic_pos);
    save(sfname,'signal_out')
    
    t_dir = sprintf('%s%s%s%s%s',dir1,slash_type,dir2,slash_type,dir12);
    if isdir(t_dir) == 0
        mkdir (t_dir)
    end
    cd (t_dir)
    saveas(gcf,sprintf('%s%s',imagefile,'_image_rotated.jpg'),'jpg')
else
    t_dir = sprintf('%s%s%s',dir1,slash_type,dir2);
    cd (t_dir)
    load signal_outA
end
clear imagefile x_m center_sample window_s precision

if strcmp (plot_full,'y') == 1
    t_dir = sprintf('%s%s%s%s%s',dir1,slash_type,dir2,slash_type,dir3);
    if isdir(t_dir) == 0
        mkdir (t_dir)
    end
    cd (t_dir)
    number_sample = fc;
    for i=1:4
        % load in each channel
        fname=[fname_prefix '.ch' num2str(i)];
        x=read_file_chunk(fname,number_sample,0,'float32');
        switch isnumeric(i)
            case i == 1
                tmp1 = x;
            case i == 2
                tmp2 = x;
            case i == 3
                tmp3 = x;
            case i == 4
                tmp4 = x;
        end
        clear x
    end
    figure;
    plot (tmp1)
    hold on
    plot(tmp2,'r')
    plot (tmp3,'g')
    plot(tmp4,'y')
    title('Full Recording All Mics')
    
    t_dir = sprintf('%s%s%s%s%s',dir1,slash_type,dir4,slash_type,dir5,slash_type,dir9,slash_type,dir10);
    if isdir(t_dir) == 0
        mkdir (t_dir)
    end
    cd (t_dir)
    saveas(gcf,sprintf('Full_recording_all_mics_speaker_pos_%s.jpg',mic_pos),fmt)
end

if strcmp (plot_abride,'y')==1
    for j = 1:2
        switch isnumeric(j)
            case j == 1
                range_end = 1000;
            case j == 2
                range_end = 200000;
        end
        for i = 1:4
            t = sprintf('%s%d','speaker',i);
            t1 = sprintf('%s %s speaker pos %s %d',t,'unshifted',mic_pos,range_end);
            figure
            plot(signal_out(1,i).unshifted(1:range_end))
            title(t1)
            t_dir = sprintf('%s%s%s',dir1,slash_type,dir4,slash_type,dir5,slash_type,dir9,slash_type,dir11);
            if isdir(t_dir) == 0
                mkdir (t_dir)
            end
            cd (t_dir)
            saveas(gcf,t1,fmt)
            close all
            tmp = find(signal_out(1,i).unshifted(1:range_end)>0);
            unshifted_nonzero(i,1) = tmp(1,1);
            clear tmp
            
            t2 = sprintf('%s %s speaker pos %s %d',t,'shifted',mic_pos,range_end);
            figure
            plot(signal_out(1,i).shifted(1:range_end),'r')
            title(t2)
            saveas(gcf,t2,fmt)
            close all
            tmp = find(signal_out(1,i).shifted(1:range_end)>0);
            shifted_nonzero(i,1) = tmp(1,1);
            clear tmp
        end
        max_shift = max(shifted_nonzero);
        max_unshift = max(unshifted_nonzero);
        
        if max_shift>max_unshift
            start_point(j,1) = max_shift;
        else
            start_point(j,1) = max_unshift;
        end
        clear unshifted_nonzero shifted_nonzero
    end
    
end

if strcmp (summing,'y')==1
    %not normalized
    for j = 1:2
        switch isnumeric(j)
            case j == 1
                range_end = 1000;
            case j == 2
                range_end = 200000;
        end
        
        for i = 1:4
            
            tmp = signal_out(1,i).unshifted(1:range_end);
            signal_range(1,i).unshifted = tmp;
            clear tmp
            
            tmp = signal_out(1,i).shifted(1:range_end);
            signal_range(1,i).shifted = tmp;
            clear tmp
        end
        
        %shift point first above 0
        tmp1 = signal_range(1,1).shifted(start_point(j,1):range_end);
        tmp2 = signal_range(1,2).shifted(start_point(j,1):range_end);
        tmp3 = signal_range(1,3).shifted(start_point(j,1):range_end);
        tmp4 = signal_range(1,4).shifted(start_point(j,1):range_end);
        shift_sum = tmp1 + tmp2 + tmp3 + tmp4;
        
        tmp5 = signal_range(1,1).unshifted(start_point(j,1):range_end);
        tmp6 = signal_range(1,2).unshifted(start_point(j,1):range_end);
        tmp7 = signal_range(1,3).unshifted(start_point(j,1):range_end);
        tmp8 = signal_range(1,4).unshifted(start_point(j,1):range_end);
        unshifted_sum = tmp5 + tmp6 + tmp7 + tmp8;
        %         shift_sum = signal_range(1,1).shifted(start_point(j,1):range_end) + signal_range(1,2).shifted(start_point(j,1):range_end) + signal_range(1,3).shifted(start_point(j,1):range_end) + signal_range(1,4).shifted(start_point(j,1):range_end);
        %         usshift_sum = signal_range(1,1).unshifted(start_point(j,1):range_end) + signal_range(1,2).unshifted(start_point(j,1):range_end) + signal_range(1,3).unshifted(start_point(j,1):range_end) + signal_range(1,4).unshifted(start_point(j,1):range_end);
        figure
        plot(unshifted_sum)
        hold on
        plot(shift_sum,'r')
        title(sprintf('Summation %d %d',start_point(j,1),range_end))
        legend('unshifted','shifted','location','NorthEastOutside')
        t_dir = sprintf('%s%s%s',dir1,slash_type,dir4,slash_type,dir5,slash_type,dir9,slash_type,dir13);
        if isdir(t_dir) == 0
            mkdir (t_dir)
        end
        cd (t_dir)
        saveas(gcf,sprintf('Summation speaker pos %s %d %d.%s',mic_pos,start_point(j,1),range_end,fmt),fmt)
        clear shift_sum unshifted_sum tmp*
        close all
        %no shift point start from begin 1 on all traces
        %shift point first above 0
        tmp1 = signal_range(1,1).shifted(1:range_end);
        tmp2 = signal_range(1,2).shifted(1:range_end);
        tmp3 = signal_range(1,3).shifted(1:range_end);
        tmp4 = signal_range(1,4).shifted(1:range_end);
        shift_sum = tmp1 + tmp2 + tmp3 + tmp4;
        
        tmp5 = signal_range(1,1).unshifted(1:range_end);
        tmp6 = signal_range(1,2).unshifted(1:range_end);
        tmp7 = signal_range(1,3).unshifted(1:range_end);
        tmp8 = signal_range(1,4).unshifted(1:range_end);
        unshifted_sum = tmp5 + tmp6 + tmp7 + tmp8;
        figure
        plot(unshifted_sum)
        hold on
        plot(shift_sum,'r')
        title(sprintf('Summation %d %d',1,range_end))
        legend('unshifted','shifted','location','NorthEastOutside')
        t_dir = sprintf('%s%s%s',dir1,slash_type,dir4,slash_type,dir5,slash_type,dir9,slash_type,dir13);
        if isdir(t_dir) == 0
            mkdir (t_dir)
        end
        cd (t_dir)
        saveas(gcf,sprintf('Summation Speaker Pos %s %d %d.%s',mic_pos,1,range_end,fmt),fmt)
        clear shift_sum unshifted_sum signal_range tmp*
        close all
    end
    %normalized
    for j = 1:2
        switch isnumeric(j)
            case j == 1
                range_end = 1000;
            case j == 2
                range_end = 200000;
        end
        for i = 1:4
            
            tmp = signal_out(1,i).unshifted(1:range_end);
            min_tmp = min(tmp);
            tmp2 = tmp+abs(min_tmp);
            max_tmp2 = max(tmp2);
            tmp3 = tmp2/max_tmp2;
            signal_range(1,i).unshifted = tmp3;
            clear tmp tmp2 tmp3 min_tmp max_tmp2
            
            tmp = signal_out(1,i).shifted(1:range_end);
            min_tmp = min(tmp);
            tmp2 = tmp+abs(min_tmp);
            max_tmp2 = max(tmp2);
            tmp3 = tmp2/max_tmp2;
            signal_range(1,i).shifted = tmp3;
            clear tmp tmp2 tmp3 min_tmp max_tmp2
        end
        
        %shift point first above 0
        tmp1 = signal_range(1,1).shifted(start_point(j,1):range_end);
        tmp2 = signal_range(1,2).shifted(start_point(j,1):range_end);
        tmp3 = signal_range(1,3).shifted(start_point(j,1):range_end);
        tmp4 = signal_range(1,4).shifted(start_point(j,1):range_end);
        shift_sum = tmp1 + tmp2 + tmp3 + tmp4;
        
        tmp5 = signal_range(1,1).unshifted(start_point(j,1):range_end);
        tmp6 = signal_range(1,2).unshifted(start_point(j,1):range_end);
        tmp7 = signal_range(1,3).unshifted(start_point(j,1):range_end);
        tmp8 = signal_range(1,4).unshifted(start_point(j,1):range_end);
        unshifted_sum = tmp5 + tmp6 + tmp7 + tmp8;
        %         shift_sum = signal_range(1,1).shifted(start_point(j,1):range_end) + signal_range(1,2).shifted(start_point(j,1):range_end) + signal_range(1,3).shifted(start_point(j,1):range_end) + signal_range(1,4).shifted(start_point(j,1):range_end);
        %         usshift_sum = signal_range(1,1).unshifted(start_point(j,1):range_end) + signal_range(1,2).unshifted(start_point(j,1):range_end) + signal_range(1,3).unshifted(start_point(j,1):range_end) + signal_range(1,4).unshifted(start_point(j,1):range_end);
        figure
        plot(unshifted_sum)
        hold on
        plot(shift_sum,'r')
        title(sprintf('Normalized Summation %d %d',start_point(j,1),range_end))
        legend('unshifted','shifted','location','NorthEastOutside')
        t_dir = sprintf('%s%s%s',dir1,slash_type,dir4,slash_type,dir5,slash_type,dir9,slash_type,dir13);
        if isdir(t_dir) == 0
            mkdir (t_dir)
        end
        cd (t_dir)
        saveas(gcf,sprintf('Normalized Summation Speaker Pos %s %d %d.%s',mic_pos,start_point(j,1),range_end,fmt),fmt)
        clear shift_sum unshifted_sum tmp*
        close all
        %no shift point start from begin 1 on all traces
        %shift point first above 0
        tmp1 = signal_range(1,1).shifted(1:range_end);
        tmp2 = signal_range(1,2).shifted(1:range_end);
        tmp3 = signal_range(1,3).shifted(1:range_end);
        tmp4 = signal_range(1,4).shifted(1:range_end);
        shift_sum = tmp1 + tmp2 + tmp3 + tmp4;
        
        tmp5 = signal_range(1,1).unshifted(1:range_end);
        tmp6 = signal_range(1,2).unshifted(1:range_end);
        tmp7 = signal_range(1,3).unshifted(1:range_end);
        tmp8 = signal_range(1,4).unshifted(1:range_end);
        unshifted_sum = tmp5 + tmp6 + tmp7 + tmp8;
        figure
        plot(unshifted_sum)
        hold on
        plot(shift_sum,'r')
        title(sprintf('Normalized Summation %d %d',1,range_end))
        legend('unshifted','shifted','location','NorthEastOutside')
        t_dir = sprintf('%s%s%s',dir1,slash_type,dir4,slash_type,dir5,slash_type,dir9,slash_type,dir13);
        if isdir(t_dir) == 0
            mkdir (t_dir)
        end
        cd (t_dir)
        saveas(gcf,sprintf('Normalized Summation Speaker Pos %s %d %d.%s',mic_pos,1,range_end,fmt),fmt)
        clear shift_sum unshifted_sum signal_range tmp*
        close all
    end
end

if strcmp(corr_cal,'y')==1
    t_dir = sprintf('%s%s%s%s%s',dir1,slash_type,dir2,slash_type,dir3);
    cd (t_dir)
    for j = 1:1
        switch isnumeric(j)
            case j == 1
                start_p = 1;
            case j == 2
                start_p = start_point(j,1);
        end
        end_point = 4000;%18000;
        
        for i=1:4
            % load in each channel
            fname=[fname_prefix '.ch' num2str(i)];
            x=read_file_chunk(fname,200000,0,'float32');
            switch isnumeric(i)
                case i == 1
                    tmp1 = x(start_p:end_point);
                case i == 2
                    tmp2 = x(start_p:end_point);
                case i == 3
                    tmp3 = x(start_p:end_point);
                case i == 4
                    tmp4 = x(start_p:end_point);
            end
            clear x
        end
        
        t_dir = sprintf('%s%s%s',dir1,slash_type,dir4,slash_type,dir5,slash_type,dir9,slash_type,dir14);
        if isdir(t_dir) == 0
            mkdir (t_dir)
        end
        cd (t_dir)
        figure;
        plot (tmp1)
        hold on
        plot(tmp2,'r')
        plot (tmp3,'g')
        plot(tmp4,'y')
        title(sprintf('Traces for circle shift %d %d',start_p,end_point))
        legend('Mic 1','Mic 2','Mic 3','Mic 4','location','NorthEastOutside')
        saveas(gca,sprintf('Traces for circle shift Speaker Pos %s %d %d.%s',mic_pos,start_p,end_point,fmt),fmt)
        close all
        tmp5 = cat(2,tmp1,tmp2,tmp3,tmp4);
        Corr_values = zeros(size(tmp1),5);
        for i = 1:size(tmp1,1)
            tmp6 = circshift(tmp5,-(i-1));
            Corr_values(i,1:4) = corr(tmp1, tmp6);
            Corr_values(i,5) = i-1;
            clear tmp6
        end
        
        Max_corr = zeros(4,2);
        for  i = 1:4
            [Max_corr(i,1) Max_corr(i,2)] = max(Corr_values(:,i));
        end
        
        [rank rank_l] = sort(Max_corr(:,1),'descend');
        clear rank
        
        for i = 1:4
            switch isnumeric(i)
                case rank_l(i,1) == 1
                    c='b';
                case rank_l(i,1) == 2
                    c='r';
                case rank_l(i,1) == 3
                    c='g';
                case rank_l(i,1) == 4
                    c='y';
            end
            if i == 1
                h = figure;
            end
            hold on
            plot(Corr_values(:,5),Corr_values(:,rank_l(i,1)),'color',c)
        end
        xlim([-100 end_point])
        title(sprintf('Circle shift %d %d',start_p,end_point))
        legend('1 vs 1','1 vs 2','1 vs 3','1 vs 4','location','NorthEastOutside')
        saveas(gca,sprintf('Correlations for circle shift speaker pos %s %d %d.%s',mic_pos,start_p,end_point,fmt),fmt)
        xlim([-5 100])
        saveas(gca,sprintf('Correlations for circle shift zoom speaker pos %s %d %d.%s',mic_pos,start_p,end_point,fmt),fmt)
        close all
    end
end