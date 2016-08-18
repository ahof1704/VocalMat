clc
clear
close all

fc = 450450;
font_size_a = 30;

load_matrix_data = 'n';

dir1_list{1,1} = 'A:\Neunuebel\ssl_sys_test\sys_test_06052012\Data_analysis';
dir1_list{2,1} = 'A:\Neunuebel\ssl_sys_test\sys_test_06062012\Data_analysis';
dir1_list{3,1} = 'A:\Neunuebel\ssl_sys_test\sys_test_06102012\Data_analysis';
dir1_list{4,1} = 'A:\Neunuebel\ssl_sys_test\sys_test_06112012\Data_analysis';
dir1_list{5,1} = 'A:\Neunuebel\ssl_sys_test\sys_test_06122012\Data_analysis';
dir1_list{6,1} = 'A:\Neunuebel\ssl_sys_test\sys_test_06132012\Data_analysis';

filename_list{1,1} = 'Test_D_1_Mouse.mat';%1
filename_list{2,1} = 'Test_E_1_Mouse.mat';%2
filename_list{3,1} = 'Test_E_1_Mouse.mat';%3
filename_list{4,1} = 'Test_D_1_Mouse.mat';%4
filename_list{5,1} = 'Test_D_1_Mouse.mat';%5
filename_list{5,2} = 'Test_E_1_Mouse.mat';%6
filename_list{6,1} = 'Test_D_1_Mouse.mat';%7
filename_list{6,2} = 'Test_E_1_Mouse.mat';%8

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
                
                %removes noise vocs that were not found during manual check
                size(mouse)
                for ii = size(mouse,2):-1:1
                    if mouse(ii).lf_fine<30e3;
                        mouse(ii) = [];
                    end
                end
                size(mouse)
                
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
                
                if i == 1 && j == 1
                    lf = tmp_lf;
                    hf = tmp_hf;
                    mean_freq = tmp_meanf;
                    bw = tmp_bw;
                    dur = tmp_dur;
                    ivi_ss = tmp_ivi_ss;
                    ivi_es = tmp_ivi_es;
                else
                    lf = cat(2,lf,tmp_lf);
                    hf = cat(2,hf,tmp_hf);
                    mean_freq = cat(2,mean_freq,tmp_meanf);
                    bw = cat(2,bw,tmp_bw);
                    dur = cat(2,dur,tmp_dur);
                    ivi_ss = cat(2,ivi_ss,tmp_ivi_ss);
                    ivi_es = cat(2,ivi_es,tmp_ivi_es);
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
%     save('data_matrices','lf','hf','mean_freq','bw','dur','ivi_ss','ivi_es','data_set_count')%,'v_ch1','v_ch2','v_ch3','v_ch4')
else
    cd A:\Neunuebel\ssl_sys_test\ISH_POSTER\data_analysis
    load data_matrices
end

ylabel_l = 'Percent of USVs';
for i = 1:7
    if i == 1
        tmp = lf;
        bin_size = 2;%khz bins
        plot_name = 'Low Frequency';
        
        xlabel_l = 'Frequency (kHz)';
        xtick_val = [0 50 100 150];
        xticklabel_l = {' ' '50' '100' '150'};
        xlim_val = [-0.0001 150.0001];
        
        ytick_val = [0 0.1 0.2];
        yticklabel_l = {' ' ' 0.1 ' ' 0.2 '};
        ylim_val = [-0.0001 0.2001];
        ycolor_l = 'w';
    elseif i == 2
        tmp = hf;
        bin_size = 2;%khz bins
        plot_name = 'High Frequency';
        
        xlabel_l = 'Frequency (kHz)';
        xtick_val = [0 50 100 150];
        xticklabel_l = {' ' '50' '100' '150'};
        xlim_val = [-0.0001 150.0001];
        
        ytick_val = [0 0.05 0.1 0.15];
        yticklabel_l = {' ' ' 0.05 ' ' 0.1 ' ' 0.15 '};
        ylim_val = [-0.0001 0.1501];
        ycolor_l = 'k';
        
    elseif i == 3
        tmp = mean_freq;
        bin_size = 2;%khz bins
        plot_name = 'Mean Frequency';
        
        xlabel_l = 'Frequency (kHz)';
        %just copied low not using data for poster
        xtick_val = [0 50 100 150];
        xticklabel_l = {' ' '50' '100'};
        xlim_val = [-0.0001 100.0001];
        
        ytick_val = [0 0.1 0.2];
        yticklabel_l = {' ' ' 0.1 ' ' 0.2 '};
        ylim_val = [-0.0001 0.2001];
        ycolor_l = 'w';
    elseif i == 4
        tmp = bw;
        bin_size = 2;%k hz bins
        plot_name = 'Bandwidth';
        
        xlabel_l = 'Frequency (kHz)';
        xtick_val = [0 25 50 75];
        xticklabel_l = {' ' '25' '50' '75'};
        xlim_val = [-0.0001 75.0001];
        
        ytick_val = [0 0.05 0.1 0.15];
        yticklabel_l = {' ' ' 0.05 ' ' 0.1 ' ' 0.15 '};
        ylim_val = [-0.0001 0.1501];
        ycolor_l = 'w';
    elseif i == 5
        tmp = dur;
        bin_size = 5;%1 ms bins
        plot_name = 'Duration';
        
        xlabel_l = 'Duration (ms)';
        xticklabel_l = {' ' '50' '100' '150'};
        xtick_val = [0 50 100 150];
        xlim_val = [-0.0001 150.0001];
        
        ytick_val = [0.05 0.15 0.25];
        yticklabel_l = {' 0.05 ' ' 0.15 ' ' 0.25 '};
        ylim_val = [-0.0001 0.2501];
        ycolor_l = 'w';
        
    elseif i == 6
        tmp = ivi_es;
        bin_size = 0.01;%1000th of a ms bins
        plot_name = 'Inter Vocal Interval--End to Start';
        xlabel_l = 'Duration (ms)';
        
        %just copied low not using data for poster
        xtick_val = [0 50 100 150];
        xticklabel_l = {' ' '50' '100'};
        xlim_val = [-0.0001 100.0001];
        
        ytick_val = [0 0.1 0.2];
        yticklabel_l = {' ' ' 0.1 ' ' 0.2 '};
        ylim_val = [-0.0001 0.2001];
        ycolor_l = 'w';
    else
        tmp = ivi_ss;
        bin_size = 0.01;%1000th of a ms bins
        plot_name = 'Inter Vocal Interval--Start to Start';
        xlabel_l = 'Duration (ms)';
        
        %just copied low not using data for poster
        xtick_val = [0 50 100 150];
        xticklabel_l = {' ' '50' '100'};
        xlim_val = [-0.0001 100.0001];
        
        ytick_val = [0 0.1 0.2];
        yticklabel_l = {' ' ' 0.1 ' ' 0.2 '};
        ylim_val = [-0.0001 0.2001];
        ycolor_l = 'w';
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
    
    for j = 1:4%num sessions with vocs
        if j == 1
            animal = 1:8;
            ses_loc = find(tmp(2,:)<9);
            color_l = 'k';
        elseif j == 2
            animal = [1 2];
            ses_loc = find(tmp(2,:)==animal(1) | tmp(2,:)==animal(2));
            color_l = ([255,140,0])/255;
        elseif j == 3
            animal = [3 4 5 7];
            color_l = ([220,220,220])/255;
            if i>5
                color_l = ([150,150,150])/255;
            end
            ses_loc = find(tmp(2,:)==animal(1) | tmp(2,:)==animal(2) | tmp(2,:)==animal(3) | tmp(2,:)==animal(4));
        elseif j == 4
            animal = [6 8];
            color_l = 'b';
            ses_loc = find(tmp(2,:)==animal(1) | tmp(2,:)==animal(2));
        end
        
        doi = tmp(1,ses_loc);
        h = figure('position',[1   1   560   420]);
        ha(j) = gca;
        [n,xout] = hist(doi,binEdges);
        n = n/sum(data_set_count(animal,1));
        bar(xout,n,'FaceColor',color_l,'EdgeColor','k')
        discriptive_stats_struct(i).group(j).median = median(doi);
        discriptive_stats_struct(i).group(j).iqr = prctile(doi,[25 75],2);
        
        clear doi n xout ses_loc animal
    end
    
    for j = 1:size(ha,2)
        max_y_lim(j,:) = get(ha(1,j),'ylim');
        figure(j)
        set(j,'color','w')
        xlabel(xlabel_l,'FontName','Arial','FontSize',font_size_a,'FontWeight','B')
        ylabel(ylabel_l,'FontName','Arial','FontSize',font_size_a,'FontWeight','B','color',ycolor_l)
        set(ha(j),'ylim',ylim_val,'ytick',ytick_val,'yticklabel',yticklabel_l,...
            'xlim',xlim_val,'xtick',xtick_val,'xticklabel',xticklabel_l,...
            'box','off','FontName','Arial','FontSize',font_size_a,'LineWidth',3)
    end
    
    for j = 1:size(ha,2)
        figure(j)
        hold on
        m = discriptive_stats_struct(i).group(j).median;
        plot([m m],[0 ylim_val(2)],'k-.','LineWidth',2) % median
        if j == 2 && i == 5
            hl = legend('  Data','  Median');
            set(hl,'box','off','FontName','Arial','FontSize',font_size_a);
        end
    end
    
    cd A:\Neunuebel\ssl_sys_test\ISH_POSTER\data_analysis
    for j = 1:size(ha,2)
        figure(j)
        shohid = get(0,'ShowHiddenHandles');
        set(0,'ShowHiddenHandles','on')
%         saveas(j,sprintf('%s %d.eps',plot_name,j),'epsc')
    end
    
    if i == 1
        print -f1 -dwinc  Descriptive_Stats_Mouse_USV
        print -f2  -dwinc -append Descriptive_Stats_Mouse_USV
        print -f3  -dwinc -append Descriptive_Stats_Mouse_USV
        print -f4  -dwinc -append Descriptive_Stats_Mouse_USV
    else
        print -f1 -dwinc  -append Descriptive_Stats_Mouse_USV
        print -f2  -dwinc -append Descriptive_Stats_Mouse_USV
        print -f3  -dwinc -append Descriptive_Stats_Mouse_USV
        print -f4  -dwinc -append Descriptive_Stats_Mouse_USV
    end
    
    close all
    clear tmp topEdge botEdge numBins binEdges ha h hl max_y_lim y_lim_val
end
% save('Voc_discriptive_stats_struct','discriptive_stats_struct')