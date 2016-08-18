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
            tmp5 = [mouse.TDOA_p_val];
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
                TDOA_P = tmp5;
            else
                TDOA = cat(2,TDOA,tmp1);
                MAX_CORR = cat(2,MAX_CORR,tmp2);
                E_TDOA = cat(2,E_TDOA,tmp3);
                DIF_T_E = cat(2,DIF_T_E,tmp4);
                TDOA_P = cat(2,TDOA_P,tmp5);
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

% % remove max_corr less than .7
% bad = MAX_CORR < .7;
% tmp_dif = DIF_T_E;
% tmp_dif(bad)=[];%used to  calculate mu and std
% DIF_T_E(bad)=NaN;

% remove abs DIF_T_E greater than 1 ms
% bad = abs(DIF_T_E) > 0.5;
% tmp_dif = DIF_T_E;
% tmp_dif(bad)=NaN;%used to  calculate mu and std
% DIF_T_E(bad)=NaN;
% DIF_T_E2 = reshape(DIF_T_E,6,sum(data_set_count));
figure('position',[100   100   560   420],'color','w');
scatter(MAX_CORR,abs(DIF_T_E),3,'k','filled')

bin_size = 0.05;%10th of a ms bins
numBins = (1-0)/bin_size; % define number of bins
binEdges = linspace(0, 1, numBins+1);

for i = 1:size(binEdges,2)-1
    bot = binEdges(1,i);
    top = binEdges(1,i+1);
    loc_corr = find(MAX_CORR(1,:)>bot & MAX_CORR(1,:)<=top);
    needed_DIF_T_E = abs(DIF_T_E(1,loc_corr));
    
    bins_DIF_T_E(1,i)=std(needed_DIF_T_E);
    
    
end
binEdges(2:end) = binEdges(2:end)-(bin_size/2);
hold on
plot(binEdges(2:end),bins_DIF_T_E,'r','LineWidth',4)
set(gca,'FontName','Arial','FontSize',24,'LineWidth',3)
ylabel('|TDOA-E TDOA| (ms)','FontWeight','B','Color','w')
xlabel('Correlation','FontWeight','B')
cd A:\Neunuebel\ssl_sys_test\ISH_POSTER\data_analysis

figure(1)
shohid = get(0,'ShowHiddenHandles');
set(0,'ShowHiddenHandles','on')
saveas(gcf,'Diff E T vs Corr.eps','epsc')
close all

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
% mu3 = mean(DIF_T_E); % Data mean
% sigma3 = std(DIF_T_E); % Data standard deviation

mu3 = mean(tmp_dif); % Data mean
sigma3 = std(tmp_dif); % Data standard deviation

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

label_axis_str{1,1} = 'DIFF R&E_1_2';
label_axis_str{1,2} = 'DIFF R&E_1_3';
label_axis_str{1,3} = 'DIFF R&E_1_4';
label_axis_str{1,4} = 'DIFF R&E_2_3';
label_axis_str{1,5} = 'DIFF R&E_2_4';
label_axis_str{1,6} = 'DIFF R&E_3_4';

count = 1;
rho_count = 0;
figure
f1 = gcf;
set(f1,'Position',[520 143 1033 955])
for y = 1:6
    for x = y+1:6
        count = count+1;
        
        x_data = DIF_T_E2m(x,:);
        y_data = DIF_T_E2m(y,:);
        
        %         [h_x,whichBin_x] = histc(x_data, binEdges);
        %         [h_y,whichBin_y] = histc(y_data, binEdges);
        z2 = 0;
        for z = 1:size(x_data,2)
            if ~isnan(x_data(1,z)) && ~isnan(y_data(1,z))
                z2 = z2 + 1;
                %                 binned_data(whichBin_y(z,1),whichBin_x(z,1)) = binned_data(whichBin_y(z,1),whichBin_x(z,1))+1;
                x_data2(1,z2) = x_data(1,z);
                y_data2(1,z2) = y_data(1,z);
            end
        end
        %
        %         imagesc(binned_data);
        %         axis xy
        %
        %         if set_color_map==0
        %             c = colormap;
        %             c_m = c(1:55,:);
        %             set_color_map = 1;
        %         end
        %         colormap(c_m);
        
        %         h = gca;
        %         set(h,'YTick',1:10:size(binEdges,2))
        %         set(h,'XTick',1:10:size(binEdges,2))
        %         set(h,'YTickLabel',binEdges(1:10:end))
        %         set(h,'XTickLabel',binEdges(1:10:end))
        
        % %         hold on
        %         plot(axis_numbers(1:2:end),(deminsions/2)*ones(1,size(binEdges(1:2:end),2)),'y.','MarkerSize',1)
        %         plot((deminsions/2)*ones(1,size(binEdges(1:2:end),2)),axis_numbers(1:2:end),'y.','MarkerSize',1)
        
        %         xlabel ([label_axis_str{1,x} '(ms)']);
        %         ylabel ([label_axis_str{1,y} '(ms)']);
        %         axis equal
        
        
        
        subplot(4,4,count)
        scatter(x_data2,y_data2,1,'k','filled')
        
        xlabel ([label_axis_str{1,x} '(ms)']);
        ylabel ([label_axis_str{1,y} '(ms)']);
        
        rho_count = rho_count + 1;
        [r p] = corr(x_data2',y_data2');
        RHO(rho_count,1) = r;
        PVAL(rho_count,1) = p;
        %         max_bin(rho_count,1) = max(max(binned_data));
        clear r p
        
        %         plot_t = sprintf('r=%3.2f  p=%3.2f  bin=%g',RHO(rho_count,1),PVAL(rho_count,1),max_bin(rho_count,1));
        plot_t = sprintf('r=%3.2f  p=%3.2f',RHO(rho_count,1),PVAL(rho_count,1));
        title(plot_t)
        
%         xlim([-2*sigma3 2*sigma3])
%         ylim([-2*sigma3 2*sigma3])
        
        clear x_data y_data
        
    end
end

cd A:\Neunuebel\ssl_sys_test

print -f1 -dwinc  Real_Single_Mouse_USV_7_STDx2
print -f2  -dwinc -append Real_Single_Mouse_USV_7_STDx2
print -f3  -dwinc -append Real_Single_Mouse_USV_7_STDx2
print -f4  -dwinc -append Real_Single_Mouse_USV_7_STDx2
print -f5  -dwinc -append Real_Single_Mouse_USV_7_STDx2
print -f6  -dwinc -append Real_Single_Mouse_USV_7_STDx2
print -f7  -dwinc -append Real_Single_Mouse_USV_7_STDx2

%     end
close 'all'
% clear filename mouse linear_TDOA filename2
% clear TDOA*
%     end
% end