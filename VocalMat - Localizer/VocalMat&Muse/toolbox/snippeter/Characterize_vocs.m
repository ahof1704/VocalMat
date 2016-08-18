clc
clear
close all

fc = 450450;

load_matrix_data = 'y';

dir1_list{1,1} = 'A:\Neunuebel\ssl_sys_test\sys_test_06052012\Data_analysis';
dir1_list{2,1} = 'A:\Neunuebel\ssl_sys_test\sys_test_06062012\Data_analysis';
dir1_list{3,1} = 'A:\Neunuebel\ssl_sys_test\sys_test_06102012\Data_analysis';
dir1_list{4,1} = 'A:\Neunuebel\ssl_sys_test\sys_test_06112012\Data_analysis';
dir1_list{5,1} = 'A:\Neunuebel\ssl_sys_test\sys_test_06122012\Data_analysis';
dir1_list{6,1} = 'A:\Neunuebel\ssl_sys_test\sys_test_06132012\Data_analysis';

filename_list{1,1} = 'Test_D_1_Mouse.mat';
filename_list{2,1} = 'Test_E_1_Mouse.mat';
filename_list{3,1} = 'Test_E_1_Mouse.mat';
filename_list{4,1} = 'Test_D_1_Mouse.mat';
filename_list{5,1} = 'Test_D_1_Mouse.mat';
filename_list{5,2} = 'Test_E_1_Mouse.mat';
filename_list{6,1} = 'Test_D_1_Mouse.mat';
filename_list{6,2} = 'Test_E_1_Mouse.mat';
%saving directory
% dir1 = 'A:\Neunuebel\ssl_sys_test\sys_test_07032012\Data_analysis';
count = 0;
if strcmp(load_matrix_data,'y') == 0
    for i = 1:size(dir1_list,1)
        cd (dir1_list{i,1})
        for j = 1:size(filename_list,2)
            if ~isempty(filename_list{i,j})
                count = count + 1;
                %             check = sprintf('%s     %d',filename_list{i,j},count);
                %             disp(check)
                load (filename_list{i,j})
                tmp_lf = [mouse.lf_fine]/1000; %kHz
                tmp_hf = [mouse.hf_fine]/1000; %kHz
                check_f = tmp_hf-tmp_lf;
                reverse = check_f<0;
                if any(reverse==1)
                    for reverse_check_loop = 1:size(reverse,2)
                        if reverse(1,reverse_check_loop)==1
                            tmpl = tmp_lf(1,reverse_check_loop);
                            tmph = tmp_hf(1,reverse_check_loop);
                            tmp_lf(1,reverse_check_loop)=tmph;
                            tmp_hf(1,reverse_check_loop)=tmpl;
                            clear tmpl tmph
                        end
                    end
                end
                
                tmp_start_ts = [mouse.start_sample_fine];
                tmp_stop_ts = [mouse.stop_sample_fine];
                tmp_bw = tmp_hf-tmp_lf;
                tmp_meanf = mean(cat(1,tmp_lf,tmp_hf),1);
                tmp_dur = 1000*((tmp_stop_ts-tmp_start_ts)/fc);
                tmp_ivi_ss = 1000*(diff(tmp_start_ts)/fc);
                tmp_ivi_es = 1000*((tmp_start_ts(2:end)-tmp_stop_ts(1:end-1))/fc);
                data_set_count(count,1) = size(mouse,2);
                cd ..
                cd demux
                data_dir = pwd;
                cd (dir1_list{i,1})
                %                 tmp_v_ch1 = zeros(1,size(mouse,2));
                %                 tmp_v_ch2 = zeros(1,size(mouse,2));
                %                 tmp_v_ch3 = zeros(1,size(mouse,2));
                %                 tmp_v_ch4 = zeros(1,size(mouse,2));
                %                 for k = 1:size(mouse,2)
                %                     [tmp1 tmp2 tmp3 tmp4] = fn_read_voc_audio_trace( data_dir, filename_list{i,j}(1:8), mouse, k);
                %                     tmp_v_ch1(1,k) = max(tmp1);
                %                     tmp_v_ch2(1,k) = max(tmp2);
                %                     tmp_v_ch3(1,k) = max(tmp3);
                %                     tmp_v_ch4(1,k) = max(tmp4);
                %                     clear tmp1 tmp2 tmp3 tmp4
                %                 end
                
                if i == 1 && j == 1
                    lf = tmp_lf;
                    hf = tmp_hf;
                    mean_freq = tmp_meanf;
                    bw = tmp_bw;
                    dur = tmp_dur;
                    ivi_ss = tmp_ivi_ss;
                    ivi_es = tmp_ivi_es;
                    %                     v_ch1 = tmp_v_ch1;
                    %                     v_ch2 = tmp_v_ch2;
                    %                     v_ch3 = tmp_v_ch3;
                    %                     v_ch4 = tmp_v_ch4;
                else
                    lf = cat(2,lf,tmp_lf);
                    hf = cat(2,hf,tmp_hf);
                    mean_freq = cat(2,mean_freq,tmp_meanf);
                    bw = cat(2,bw,tmp_bw);
                    dur = cat(2,dur,tmp_dur);
                    ivi_ss = cat(2,ivi_ss,tmp_ivi_ss);
                    ivi_es = cat(2,ivi_es,tmp_ivi_es);
                    %                     v_ch1 = cat(2,v_ch1,tmp_v_ch1);
                    %                     v_ch2 = cat(2,v_ch2,tmp_v_ch2);
                    %                     v_ch3 = cat(2,v_ch3,tmp_v_ch3);
                    %                     v_ch4 = cat(2,v_ch4,tmp_v_ch4);
                end
                clear tmp*
            end
        end
    end
    clear tmp*
    tmp1 = 1*ones(1,data_set_count(1,1));
    tmp2 = 2*ones(1,data_set_count(2,1));
    tmp3 = 3*ones(1,data_set_count(3,1));
    tmp4 = 4*ones(1,data_set_count(4,1));
    tmp5 = 5*ones(1,data_set_count(5,1));
    tmp6 = 6*ones(1,data_set_count(6,1));
    tmp7 = 7*ones(1,data_set_count(7,1));
    tmp8 = 8*ones(1,data_set_count(8,1));
    data_marker1 = cat(2,tmp1,tmp2,tmp3,tmp4,tmp5,tmp6,tmp7,tmp8);
    clear tmp*
    
    tmp1 = 1*ones(1,data_set_count(1,1)-1);
    tmp2 = 2*ones(1,data_set_count(2,1)-1);
    tmp3 = 3*ones(1,data_set_count(3,1)-1);
    tmp4 = 4*ones(1,data_set_count(4,1)-1);
    tmp5 = 5*ones(1,data_set_count(5,1)-1);
    tmp6 = 6*ones(1,data_set_count(6,1)-1);
    tmp7 = 7*ones(1,data_set_count(7,1)-1);
    tmp8 = 8*ones(1,data_set_count(8,1)-1);
    data_marker2 = cat(2,tmp1,tmp2,tmp3,tmp4,tmp5,tmp6,tmp7,tmp8);
    clear tmp*
    
    lf = cat(1,lf,data_marker1);
    hf = cat(1,hf,data_marker1);
    mean_freq = cat(1,mean_freq,data_marker1);
    bw = cat(1,bw,data_marker1);
    dur = cat(1,dur,data_marker1);
    ivi_ss = cat(1,ivi_ss,data_marker2);
    ivi_es = cat(1,ivi_es,data_marker2);
    %     v_ch1 = cat(1,v_ch1,data_marker1);
    %     v_ch2 = cat(1,v_ch2,data_marker1);
    %     v_ch3 = cat(1,v_ch3,data_marker1);
    %     v_ch4 = cat(1,v_ch4,data_marker1);
    
    cd A:\Neunuebel\ssl_sys_test\ISH_POSTER\data_analysis
    save('data_matrices','lf','hf','mean_freq','bw','dur','ivi_ss','ivi_es','data_set_count')%,'v_ch1','v_ch2','v_ch3','v_ch4')
else
    cd A:\Neunuebel\ssl_sys_test\ISH_POSTER\data_analysis
    load data_matrices
end

ylabel_l = 'Percent of total vocalizations';
for i = 1:7
    if i == 1
        tmp = lf;
        bin_size = 1;%khz bins
        plot_name = 'Low Frequency';
        xlabel_l = 'Frequency (kHz)';
    elseif i == 2
        tmp = hf;
        bin_size = 1;%khz bins
        plot_name = 'High Frequency';
        xlabel_l = 'Frequency (kHz)';
    elseif i == 3
        tmp = mean_freq;
        bin_size = 1;%khz bins
        plot_name = 'Mean Frequency';
        xlabel_l = 'Frequency (kHz)';
    elseif i == 4
        tmp = bw;
        bin_size = 2;%k hz bins
        plot_name = 'Bandwidth';
        xlabel_l = 'Frequency (kHz)';
    elseif i == 5
        tmp = dur;
        bin_size = 5;%1 ms bins
        plot_name = 'Duration';
        xlabel_l = 'Duration (ms)';
    elseif i == 6
        tmp = ivi_ss;
        bin_size = 0.01;%1000th of a ms bins
        plot_name = 'Inter Vocal Interval--Start to Start';
        xlabel_l = 'Duration (ms)';
    else
        tmp = ivi_es;
        bin_size = 0.01;%1000th of a ms bins
        plot_name = 'Inter Vocal Interval--End to Start';
        xlabel_l = 'Duration (ms)';
    end
    
    if i < 6
        topEdge = max(tmp(1,:)); % define limits
        botEdge = min(tmp(1,:)); % define limits
        numBins = (topEdge-botEdge)/bin_size; % define number of bins
        binEdges = linspace(botEdge, topEdge, numBins+1);
    else
        topEdge = max(log10(tmp(1,:))); % define limits
        botEdge = min(log10(tmp(1,:))); % define limits
        numBins = (topEdge-botEdge)/bin_size; % define number of bins
        binEdges = logspace(botEdge, topEdge, numBins+1);
    end
    
    h = figure;
    ha(1) = gca;
    [n,xout] = hist(tmp(1,:),binEdges);
    n = n/sum(data_set_count);
    if i<6
        bar(xout,n,'FaceColor','k','EdgeColor','k')
        clear n xout
    else
        semilogx(binEdges,n,'k','LineWidth',3);
    end
    
    discriptive_stats_struct(i).comparison_name = plot_name;
    discriptive_stats_struct(i).group(1).median = median(tmp(1,:));
    discriptive_stats_struct(i).group(1).iqr = prctile(tmp(1,:),[25 75],2);
    
    for j = 1:8%num sessions with vocs
        if j == 1
            color_l = ([255,140,0])/255;
        elseif j == 2
            color_l = 'b';
        elseif j == 3
            color_l = ([80,80,80])/255;
        elseif j == 4
            color_l = 'c';
        elseif j == 5
            color_l = ([220,220,220])/255;
        elseif j == 6
            color_l = 'r';
        elseif j == 7
            color_l = 'w';
        elseif j == 8
            color_l = ([128,128,128])/255;
        end
        ses_loc = find(tmp(2,:)==j);
        doi = tmp(1,ses_loc);
        h = figure;
        ha(j+1) = gca;
        [n,xout] = hist(doi,binEdges);
        n = n/sum(data_set_count(j,1));
        if i < 6
            bar(xout,n,'FaceColor',color_l,'EdgeColor','k')
        else
            semilogx(binEdges,n,'color',color_l,'LineWidth',3);
        end
        discriptive_stats_struct(i).group(j+1).median = median(doi);
        discriptive_stats_struct(i).group(j+1).iqr = prctile(doi,[25 75],2);
        
        clear doi n xout ses_loc
    end
    
    for j = 1:size(ha,2)
        max_y_lim(j+1,:) = get(ha(1,j),'ylim');
        figure(j)
        set(j,'color','w')
        xlabel(xlabel_l,'FontName','Arial','FontSize',20,'FontWeight','B')
        if j == 1
            ylabel(ylabel_l,'FontName','Arial','FontSize',20,'FontWeight','B')
        else
            set(ha(j),'YTickLabel',[])
        end
    end
    y_lim_val = max(max_y_lim(:,2));
    set(ha,'ylim',[0 y_lim_val],'box','off','FontName','Arial','FontSize',20,'LineWidth',2)
    
    for j = 1:size(ha,2)
        figure(j)
        hold on
        m = discriptive_stats_struct(i).group(j).median;
        plot([m m],[0 y_lim_val],'r-.','LineWidth',1.5) % median
        if j == 1
            hl = legend('  Data','  Median');
            set(hl,'box','off','FontName','Arial','FontSize',20);
        end
    end
    
    if i >= 6
        for j = 1:size(ha,2)
            set(ha(j),'XScale','log')
        end
    end
    
    cd A:\Neunuebel\ssl_sys_test\ISH_POSTER\data_analysis
    for j = 1:size(ha,2)
        figure(j)
        saveas(j,sprintf('%s %d.eps',plot_name,j),'eps')
    end
    
    if i == 1
        print -f1 -dwinc  Descriptive_Stats_Mouse_USV
        print -f2  -dwinc -append Descriptive_Stats_Mouse_USV
        print -f3  -dwinc -append Descriptive_Stats_Mouse_USV
        print -f4  -dwinc -append Descriptive_Stats_Mouse_USV
        print -f5  -dwinc -append Descriptive_Stats_Mouse_USV
        print -f6  -dwinc -append Descriptive_Stats_Mouse_USV
        print -f7  -dwinc -append Descriptive_Stats_Mouse_USV
        print -f8  -dwinc -append Descriptive_Stats_Mouse_USV
        print -f9  -dwinc -append Descriptive_Stats_Mouse_USV
    else
        print -f1 -dwinc  -append Descriptive_Stats_Mouse_USV
        print -f2  -dwinc -append Descriptive_Stats_Mouse_USV
        print -f3  -dwinc -append Descriptive_Stats_Mouse_USV
        print -f4  -dwinc -append Descriptive_Stats_Mouse_USV
        print -f5  -dwinc -append Descriptive_Stats_Mouse_USV
        print -f6  -dwinc -append Descriptive_Stats_Mouse_USV
        print -f7  -dwinc -append Descriptive_Stats_Mouse_USV
        print -f8  -dwinc -append Descriptive_Stats_Mouse_USV
        print -f9  -dwinc -append Descriptive_Stats_Mouse_USV
    end
    
    close all
    clear tmp topEdge botEdge numBins binEdges ha h hl max_y_lim y_lim_val
end
save('discriptive_stats_struct','discriptive_stats_struct')