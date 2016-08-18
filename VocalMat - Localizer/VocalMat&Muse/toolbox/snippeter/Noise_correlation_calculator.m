clc
clear
close all

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
for i = 1:size(dir1_list,1)
    cd (dir1_list{i,1})
    for j = 1:size(filename_list,2)
        if ~isempty(filename_list{i,j})
            count = count + 1;
%             check = sprintf('%s     %d',filename_list{i,j},count);
%             disp(check)
            load (filename_list{i,j})
            tmp1 = 1000*[mouse.TDOA]; %ms
            tmp2 = [mouse.max_corr];
            tmp3 = 1000*[mouse.estimated_delta_t];  %ms
            tmp4 = tmp1-tmp3;
            data_set_count(count,1) = size(mouse,2);
%             tmp1 = cat(1,tmp1,data_set_num);
%             tmp2 = cat(1,tmp2,data_set_num);
%             tmp3 = cat(1,tmp3,data_set_num);
%             tmp4 = cat(1,tmp4,data_set_num);
            %tmp4 = reshape(tmp1,6,size(mouse,2))';
            if i == 1 && j == 1
                TDOA = tmp1;
                MAX_CORR = tmp2;
                E_TDOA = tmp3;
                DIF_T_E = tmp4;
            else
                TDOA = cat(2,TDOA,tmp1);
                MAX_CORR = cat(2,MAX_CORR,tmp2);
                E_TDOA = cat(2,E_TDOA,tmp3);
                DIF_T_E = cat(2,DIF_T_E,tmp4);
            end
            clear tmp*
            
        end
    end
end
clear tmp*
tmp1 = ones(1,data_set_count(1,1));
tmp2 = 2*ones(1,data_set_count(2,1));
tmp3 = 3*ones(1,data_set_count(3,1));
tmp4 = 4*ones(1,data_set_count(4,1));
tmp5 = 5*ones(1,data_set_count(5,1));
tmp6 = 6*ones(1,data_set_count(6,1));
tmp7 = 7*ones(1,data_set_count(7,1));
tmp8 = 8*ones(1,data_set_count(8,1));
data_marker = cat(2,tmp1,tmp2,tmp3,tmp4,tmp5,tmp6,tmp7,tmp8);
clear tmp*

TDOA2 = reshape(TDOA,6,sum(data_set_count));
TDOA2 = cat(1,TDOA2,data_marker);

MAX_CORR2 = reshape(MAX_CORR,6,sum(data_set_count));
MAX_CORR2 = cat(1,MAX_CORR2,data_marker);

E_TDOA2 = reshape(E_TDOA,6,sum(data_set_count));
E_TDOA2 = cat(1,E_TDOA2,data_marker);

DIF_T_E2 = reshape(DIF_T_E,6,sum(data_set_count));
DIF_T_E2 = cat(1,DIF_T_E2,data_marker);

%TDOAs
topEdge_TDOA = max(TDOA(1,:)); % define limits
botEdge_TDOA = min(TDOA(1,:)); % define limits
bin_size_TDOA = 0.1;%10th of a ms bins
numBins_TDOA = (topEdge_TDOA-botEdge_TDOA)/bin_size_TDOA; % define number of bins
binEdges_TDOA = linspace(botEdge_TDOA, topEdge_TDOA, numBins_TDOA+1);
figure
hist(TDOA(1,:),binEdges_TDOA);
title('Calculated TDOA')

%Max correlations
topEdge_MAX_CORR = max(MAX_CORR(1,:)); % define limits
botEdge_MAX_CORR = min(MAX_CORR(1,:)); % define limits
bin_size_MAX_CORR = 0.01;%100th of corr ranging from 1 -1;
numBins_MAX_CORR = (topEdge_MAX_CORR-botEdge_MAX_CORR)/bin_size_MAX_CORR; % define number of bins
binEdges_MAX_CORR = linspace(botEdge_MAX_CORR, topEdge_MAX_CORR, numBins_MAX_CORR+1);
figure
hist(MAX_CORR(1,:),binEdges_MAX_CORR);
title('Max Corr')

%Estimated TDOAs
topEdge_E_TDOA = max(E_TDOA(1,:)); % define limits
botEdge_E_TDOA = min(E_TDOA(1,:)); % define limits
bin_size_E_TDOA = 0.1;%10th of a ms bins
numBins_E_TDOA = (topEdge_E_TDOA-botEdge_E_TDOA)/bin_size_E_TDOA; % define number of bins
binEdges_E_TDOA = linspace(botEdge_E_TDOA, topEdge_E_TDOA, numBins_E_TDOA+1);
figure
hist(E_TDOA(1,:),binEdges_E_TDOA);
title('Estimated TDOA')

%%%%%diff
topEdge_DIF_T_E = max(DIF_T_E(1,:)); % define limits
botEdge_DIF_T_E = min(DIF_T_E(1,:)); % define limits
bin_size_DIF_T_E = 0.1;%10th of a ms bins
numBins_DIF_T_E = (topEdge_DIF_T_E-botEdge_DIF_T_E)/bin_size_DIF_T_E; % define number of bins
binEdges_DIF_T_E = linspace(botEdge_DIF_T_E, topEdge_DIF_T_E, numBins_DIF_T_E+1);
[bin_counts,bins] = hist(DIF_T_E(1,:),binEdges_DIF_T_E); % Histogram bin counts
N = max(bin_counts); % Maximum bin count
mu3 = mean(DIF_T_E); % Data mean
sigma3 = std(DIF_T_E); % Data standard deviation

figure
hist(DIF_T_E(1,:),binEdges_DIF_T_E);
hold on
plot([mu3 mu3],[0 N],'r','LineWidth',2) % Mean
X1 = repmat(mu3+(1:3)*sigma3,2,1);
X2 = repmat(mu3-(1:3)*sigma3,2,1);
X = cat(2,X1,X2);
Y = repmat([0;N],1,6);
plot(X,Y,'g','LineWidth',2) % Standard deviations
legend('Data','Mean','Stds')
title('Differences between Calcuated and Estimated TDOA Outliers Included')
hold off

outliers = abs(DIF_T_E - mu3) > 2*sigma3;
DIF_T_Em = DIF_T_E; % Copy c3 to c3m
DIF_T_Em(outliers) = NaN; % Add NaN values

figure
hist(DIF_T_Em(1,:),binEdges_DIF_T_E);
hold on
plot([mu3 mu3],[0 N],'r','LineWidth',2) % Mean
plot(X,Y,'g','LineWidth',2) % Standard deviations
legend('Data','Mean','Stds')
title('Differences between Calcuated and Estimated TDOA Outliers Gone')
hold off

num_outliers = sum(isnan(DIF_T_Em));
DIF_T_E2m = reshape(DIF_T_Em,6,sum(data_set_count));
DIF_T_E2m = cat(1,DIF_T_E2m,data_marker);

std_diff_T_E = zeros(size(DIF_T_E2m,1)-1,1);
for i = 1:size(DIF_T_E2m,1)-1
    tmp = DIF_T_E2m(i,:);
    good = ~isnan(tmp);
    tmp2 = tmp(good);
    std_diff_T_E(i,1) = std(tmp2);
    clear tmp* good
end

figure
bar(std_diff_T_E)
title('STD of Differences between Calcuated and Estimated TDOA')
% std_diff_T_E = std(DIF_T_E2m,0,1);

count = 0;
for i = 'B':'F'
    for j = 1:8
        
        filename = ['Test_',i,num2str(j),'_1_Mouse.mat'];
        exp_list{count,1} = filename;
    end
end
label_axis_str{1,1} = 'TDOA_1_2';
label_axis_str{1,2} = 'TDOA_1_3';
label_axis_str{1,3} = 'TDOA_1_4';
label_axis_str{1,4} = 'TDOA_2_3';
label_axis_str{1,5} = 'TDOA_2_4';
label_axis_str{1,6} = 'TDOA_3_4';

topEdge = 3; % define limits
botEdge = -3; % define limits
bin_size = 0.1;
numBins = (topEdge-botEdge)/bin_size; % define number of bins
binEdges = linspace(botEdge, topEdge, numBins+1);
deminsions = size(binEdges,2);
binned_data = zeros(deminsions,deminsions);
axis_numbers = 1:deminsions;

for threshold_val = 0:0.1:0.4;
    set_color_map = 0;
    rho_count = 0;
    p1 = sprintf('print -f1 -dwinc  Coarse_Playback_TDOA_TH%d_colorplot',threshold_val*10);
    p2 = sprintf('print -f1  -dwinc -append Coarse_Playback_TDOA_TH%d_colorplot',threshold_val*10);
    p3 = sprintf('print -f2 -dwinc Coarse_Playback_TDOA_TH%d',threshold_val*10);
    p4 = sprintf('print -f2  -dwinc -append Coarse_Playback_TDOA_TH%d',threshold_val*10);
    for i = 1:size(exp_list,1)
        filename = exp_list{i,1};
        filename2 = filename(1:9);
        load (filename)
        space_pos = strfind(filename2,'_');
        filename2(space_pos)= ' ';
        
        for j = 1:size(mouse,2)
            TDOA12(j,1) = mouse(j).TDOA(1);
            TDOA13(j,1) = mouse(j).TDOA(2);
            TDOA14(j,1) = mouse(j).TDOA(3);
            TDOA23(j,1) = mouse(j).TDOA(4);
            TDOA24(j,1) = mouse(j).TDOA(5);
            TDOA34(j,1) = mouse(j).TDOA(6);
            
            max_corr12(j,1) = mouse(j).max_corr(1);
            max_corr13(j,1) = mouse(j).max_corr(2);
            max_corr14(j,1) = mouse(j).max_corr(3);
            max_corr23(j,1) = mouse(j).max_corr(4);
            max_corr24(j,1) = mouse(j).max_corr(5);
            max_corr34(j,1) = mouse(j).max_corr(6);
        end
        
        TDOA12 = 1000*TDOA12;%ms
        TDOA13 = 1000*TDOA13;%ms
        TDOA14 = 1000*TDOA14;%ms
        TDOA23 = 1000*TDOA23;%ms
        TDOA24 = 1000*TDOA24;%ms
        TDOA34 = 1000*TDOA34;%ms
        
        lower = max_corr12<threshold_val;
        TDOA12(lower)=NaN;
        clear lower
        lower = max_corr13<threshold_val;
        TDOA13(lower)=NaN;
        clear lower
        lower = max_corr14<threshold_val;
        TDOA14(lower)=NaN;
        clear lower
        lower = max_corr23<threshold_val;
        TDOA23(lower)=NaN;
        clear lower
        lower = max_corr24<threshold_val;
        TDOA24(lower)=NaN;
        clear lower
        lower = max_corr34<threshold_val;
        TDOA34(lower)=NaN;
        clear lower
        
        TDOA = cat(2,TDOA12,TDOA13,TDOA14,TDOA23,TDOA24,TDOA34);
        max_corr = cat(2,max_corr12,max_corr13,max_corr14,max_corr23,max_corr24,max_corr34);
        
        fn = [filename(1:9) '.seq'];
        cd ..
        info=fnReadVideoInfo(fn);
        im=fnReadFrameFromVideo(info,9);
        image_matrix_r = imrotate(im,180);%rotates by 180
        
        f1 = figure;
        set(f1,'Position',[520 143 1033 955])
        subplot(4,4,1);
        imagesc(image_matrix_r);
        set(gca,'dataaspectratio',[1 1 1])
        axis ij
        title(filename2)
        cd (dir1)
        
        f2 = figure;
        set(f2,'Position',[520 143 1033 955])
        subplot(4,4,1);
        imagesc(image_matrix_r);
        set(gca,'dataaspectratio',[1 1 1])
        axis ij
        title(filename2)
        cd (dir1)
        
        count = 1;
        
        for y = 1:6
            for x = y+1:6
                count = count+1;
                figure(f1)
                subplot(4,4,count)
                
                x_data = TDOA(:,x);
                y_data = TDOA(:,y);
                
                [h_x,whichBin_x] = histc(x_data, binEdges);
                [h_y,whichBin_y] = histc(y_data, binEdges);
                z2 = 0;
                for z = 1:size(x_data,1)
                    if ~isnan(x_data(z,1)) && ~isnan(y_data(z,1))
                        z2 = z2 + 1;
                        binned_data(whichBin_y(z,1),whichBin_x(z,1)) = binned_data(whichBin_y(z,1),whichBin_x(z,1))+1;
                        x_data2(z2,1) = x_data(z,1);
                        y_data2(z2,1) = y_data(z,1);
                    end
                end
                
                imagesc(binned_data);
                axis xy
                
                if set_color_map==0
                    c = colormap;
                    c_m = c(1:55,:);
                    set_color_map = 1;
                end
                colormap(c_m);
                
                h = gca;
                set(h,'YTick',1:10:size(binEdges,2))
                set(h,'XTick',1:10:size(binEdges,2))
                set(h,'YTickLabel',binEdges(1:10:end))
                set(h,'XTickLabel',binEdges(1:10:end))
                
                hold on
                plot(axis_numbers(1:2:end),(deminsions/2)*ones(1,size(binEdges(1:2:end),2)),'y.','MarkerSize',1)
                plot((deminsions/2)*ones(1,size(binEdges(1:2:end),2)),axis_numbers(1:2:end),'y.','MarkerSize',1)
                
                xlabel ([label_axis_str{1,x} '(ms)']);
                ylabel ([label_axis_str{1,y} '(ms)']);
                axis equal
                
                figure(f2)
                subplot(4,4,count)
                scatter(x_data,y_data)
                
                xlabel ([label_axis_str{1,x} '(ms)']);
                ylabel ([label_axis_str{1,y} '(ms)']);
                
                xlim([-3 3])
                ylim([-3 3])
                
                rho_count = rho_count + 1;
                [r p] = corrcoef(x_data2,y_data2);
                RHO(rho_count,1) = r(1,2);
                PVAL(rho_count,1) = p(1,2);
                max_bin(rho_count,1) = max(max(binned_data));
                clear r p
                
                plot_t = sprintf('r=%3.2f  p=%3.2f  bin=%g',RHO(rho_count,1),PVAL(rho_count,1),max_bin(rho_count,1));
                
                figure(f1)
                title(plot_t)
                figure(f2)
                title(plot_t)
                
                binned_data = zeros(deminsions,deminsions);
                clear x_data y_data
                
            end
        end
        
        %     ht = gca;
        %     sp1_pos = get(ht,'position');
        %     delete(ht);
        %     annotation('textbox',sp1_pos,'string',filename2,'EdgeColor','none')
        %     figure(f2)
        %     annotation('textbox',sp1_pos,'string',filename2,'EdgeColor','none')
        
        if i == 1
            eval(p1);
            eval(p3);
        else
            eval(p2);
            eval(p4);
        end
        
        %     f3 = figure;
        %     set(f3,'Position',[520 143 1033 955])
        %     for j = 1:6
        %         subplot(2,3,j)
        %         hist(TDOA(:,j))
        %         if j == 1
        %             title([filename2 '    ' label_axis_str{1,j}])
        %         else
        %             title(label_axis_str{1,j})
        %         end
        %     end
        %     if i == 1
        %         print -f3 -dwinc Coarse_Playback_TDOA_TH0_Histogram
        %     else
        %         print -f3  -dwinc -append Coarse_Playback_TDOA_TH0_Histogram
        %     end
        close 'all'
        clear filename mouse linear_TDOA filename2
        clear TDOA*
    end
end