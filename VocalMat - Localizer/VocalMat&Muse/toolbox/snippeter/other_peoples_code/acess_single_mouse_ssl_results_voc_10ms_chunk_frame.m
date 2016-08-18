clc
clear
close all

fc = 450450;
% load('U:\Matlab\progs\v33_multiple_mice_cleaned_up\r_est_raw_for_06052012_D_voc_frame_chunk_DA3_pdfs.mat')
% load('A:\Neunuebel\ssl_sys_test\sys_test_06052012\Data_analysis3\Test_D_1_Mouse.mat')

load('U:\Matlab\progs\v33_multiple_mice_cleaned_up\r_est_raw_for_06052012_D_voc_10ms_chunk_DA5_pdfs.mat')
load('A:\Neunuebel\ssl_sys_test\sys_test_06052012\Data_analysis5\Test_D_1_Mouse.mat')

%% asigns name
% date_str=date_str_raw;
% letter_str=letter_str_raw;
% i_syl=i_syl_raw;
r_est = [r_est_blob_per_voc_per_trial{1,1}.r_est];
r_head = [r_est_blob_per_voc_per_trial{1,1}.r_head];
r_tail = [r_est_blob_per_voc_per_trial{1,1}.r_tail];
i_syl = [r_est_blob_per_voc_per_trial{1,1}.i_syl];
% N=N_raw;
% N_filt=N_filt_raw;
% R=R_raw;
%%
error = fn_calculate_distance3( r_head, r_est);
%%
index = [mouse.index];
start_ts = [mouse.start_sample_fine];
stop_ts = [mouse.stop_sample_fine];
dur = (stop_ts-start_ts)/fc;
dur = dur*1000; %ms
%%
min_seg_time = 5;%ms
%%
[n, bin] = histc(index, unique(index));
multiple = find(n > 1);
loc_repeats  = find(ismember(bin, multiple));

uniqueX = unique(index);
countOfX = hist(index,uniqueX);
indexToRepeatedValue = (countOfX~=1);
repeatedValues = uniqueX(indexToRepeatedValue);
numberOfAppearancesOfRepeatedValues = countOfX(indexToRepeatedValue);

num_vocs = max(index);
max_num_chunks = max(numberOfAppearancesOfRepeatedValues);
head_error = nan(num_vocs,max_num_chunks);
dur_mat = head_error;
color_list = zeros(1,size(i_syl,2));
%%

for i = 1:size(i_syl,2)
    voc_num = char(i_syl{i});
    pos1 = strfind(voc_num,'_');
    char_value = str2num(sprintf('%d',voc_num(pos1+1:end)));
    if char_value == 48;
        col = 1;
    else
        col = char_value - 95;
    end
    %     color_list{1,i} = color_v;
    color_list(1,i) = col;
    head_error(mouse(i).index,col) = error(i);
    dur_mat(mouse(i).index,col) = dur(i);
    %      num{i} = regexprep(fileName{i},'[^\d]*','');
end
%  disp(1)

 
%%

% for i = 1:size(head_error,2)
%     tmp1 = head_error(:,i);
%     figure
%     hist(tmp1,0:0.01:1)
%     clear tmp1
% end
%

%%
color_v = colormap(lines(max_num_chunks));
close all
for i = 1:size(head_error,2)
    color_loc = find(color_list==i);
    tmp_dur = dur(color_loc);
    tmp_error = error(color_loc);
    hf(i) = figure('color','w');
    ha(i) = gca;
    scatter(tmp_dur,tmp_error,'filled','MarkerFaceColor',color_v(i,:),'MarkerEdgeColor','none')%,'color',color_v(i,:))
    xlim_val(i,:) = get(gca,'xlim');
    ylim_val(i,:) = get(gca,'ylim');
    xlabel('Duration (ms)')
    ylabel('Error (m)')
    title('06052012-D-solo male')
    disp(1)
    
end
set(ha,'ylim',[min(min(ylim_val)) max(max(ylim_val))],...
    'xlim',[min(min(xlim_val)) max(max(xlim_val))],...
    'box','off')
close all
%%
color_loc = find(color_list>1);
tmp_dur = dur(color_loc);
tmp_error = error(color_loc);
% hf(i) = figure('color','w');
% ha(i) = gca;
% scatter(tmp_dur,tmp_error,'filled',color_v)
% xlim_val(i,:) = get(gca,'xlim');
% ylim_val(i,:) = get(gca,'ylim');
% xlabel('Duration (ms)')
% ylabel('Error (m)')
% title('06052012-D-solo male')

% figure('color','w');
% semilogy(tmp_dur,tmp_error,'bo')
% xlabel('Duration (ms)')
% ylabel('Error (m)')
% title('Semilogy')
% 
% figure('color','w');
% loglog(tmp_dur,tmp_error,'bo')
% xlabel('Duration (ms)')
% ylabel('Error (m)')
% title('Loglog')

figure('color','w')
step_size = 100;
x2 = linspace(min(tmp_error), max(tmp_error),step_size);
y2 = linspace(min(tmp_dur), max(tmp_dur),step_size);
nbins = [size(x2,2),size(y2,2)];

data = [tmp_dur' tmp_error'];
hold on
n = hist3(data,nbins);
n1 = n';
n1( size(n,1) + 1 ,size(n,2) + 1 ) = 0;
xb = linspace(min(data(:,1)),max(data(:,1)),size(n,1)+1);
yb = linspace(min(data(:,2)),max(data(:,2)),size(n,1)+1);
imagesc(xb,yb,n1)
colormap(jet(254))
xlim([xb(1) xb(end)])
ylim([yb(1) yb(end)])
hl1 = line([min_seg_time min_seg_time],[0 0.9]);
hl2 = line([7 7],[0 0.9]);
colorbar
xlabel('Duration (ms)')
ylabel('Error (m)')
title('06052012-D-solo male')
set(hl1,'color','r','linestyle','-','linewidth',3)
set(hl2,'color','r','linestyle',':','linewidth',3)
%%
%Calculate number of chunks
chunk_time = min_seg_time;
% %number of chunks based on chunk_time in whole segments
% clear color_loc tmp_dur2
% color_loc = find(color_list==1);
% tmp_dur2 = dur(color_loc);
% chunk_num_vector = zeros(1,size(tmp_dur2,2));
% chunk0 = 0;
% for i = 1:size(tmp_dur2,2)
%     time = tmp_dur2(1,i);
%     chunk_num_vector(1,i) = floor(rdivide(time,chunk_time));
% %     disp(mod(time,chunk_time))
%     if mod(time,chunk_time) ~= 0
%         chunk0 = chunk0 + 1;
%     end
% end
% max_num_chunks = max(chunk_num_vector);
% num_chunks = nan(2,max_num_chunks+1);
% for i = 1:max_num_chunks
%     num_chunks(1,i+1) = numel(find(chunk_num_vector==i));
% end
% num_chunks(1,1) = chunk0;
% clear tmp_dur2
% 
% %number of chunks based on chunk_time in chunks associated with each frame
% clear color_loc tmp_dur2
% color_loc = find(color_list>1);
% tmp_dur2 = dur(color_loc);
% chunk_num_vector = zeros(1,size(tmp_dur2,2));
% chunk0 = 0;
% for i = 1:size(tmp_dur2,2)
%     time = tmp_dur2(1,i);
%     chunk_num_vector(1,i) = floor(rdivide(time,chunk_time));
% %     disp(mod(time,chunk_time))
%     if mod(time,chunk_time) ~= 0
%         chunk0 = chunk0 + 1;
%     end
% end
% max_num_chunks = max(chunk_num_vector);
% % num_chunks = nan(2,max_num_chunks+1);
% for i = 1:max_num_chunks
%     num_chunks(2,i+1) = numel(find(chunk_num_vector==i));
% end
% num_chunks(2,1) = chunk0;
% 
% figure('color','w'); 
% bar(0:size(num_chunks,2)-1,num_chunks',0.7)
% legend({'Chunks per Vocalization','Chunks per Frame'})
% set(gca,'box','off')
% title(sprintf('Number of possible %d ms chunks',min_seg_time))
% xlabel('Number of chunks')
% ylabel('Count')
% 
% figure('color','w'); 
% bar(1:size(num_chunks,2)-1,num_chunks(:,2:end)',0.7)
% legend({'Chunks per Vocalization','Chunks per Frame'})
% set(gca,'box','off')
% title(sprintf('Number of possible %d ms chunks',min_seg_time))
% xlabel('Number of chunks')
% ylabel('Count')
% clear tmp_dur2
% % close all
%%
tmp1 = head_error(:,3);
small = isnan(tmp1);
small_loc = find(small==1);
disp(size(small_loc))
head_error(small_loc,:)=[];%removed any vocalizations that are only part of chunk1 and whole vocalization
dur_mat(small_loc,:) = [];
clear tmp1
clear small_loc small
count = 0;
step_size = 500;
step_num = 0.005;
% for i = 1:size(head_error,2)
%     tmp1 = head_error(:,i);
%     tmp_dur = dur_mat(:,i);
%     small_loc = find(tmp_dur<min_seg_time);
%     tmp1(small_loc,1)=NaN;
%     switch isnumeric(i)
%         case i==1
%             color_v1 = 'm';
%         case i==2
%             color_v1 = 'r';
%         case i==3
%             color_v1 = 'b';
%         case i==4
%             color_v1 = 'c';
%         case i==5
%             color_v1 = 'k';
%         case i==6
%             color_v1 = 'g';
%     end
%     if i==1
%         labelx = 'Complete Voc Error (m)';
%     else
%         labelx = sprintf('Chunk %d Error (m)',i-1);
%     end
%     for j = i+1:size(head_error,2)
%         switch isnumeric(j)
%             case j==1
%                 color_v2 = 'm';
%             case j==2
%                 color_v2 = 'r';
%             case j==3
%                 color_v2 = 'b';
%             case j==4
%                 color_v2 = 'c';
%             case j==5
%                 color_v2 = 'k';
%             case j==6
%                 color_v2 = 'g';
%         end
%         labely = sprintf('Chunk %d Error (m)',j-1);
%         count = count + 1;
%         tmp2 = head_error(:,j);
%         tmp_dur = dur_mat(:,j);
%         small_loc = find(tmp_dur<min_seg_time);
%         tmp2(small_loc,1)=NaN;
%         figure('color','w','position',[200   300   560   560])%make it a square
%         x2 = 0:step_num:1;%linspace(min(tmp1), max(tmp1),step_size);
%         y2 = 0:step_num:1;%linspace(min(tmp2), max(tmp2),step_size);
%         nbins = [size(x2,2),size(y2,2)];
% %         
% %         data = [tmp1 tmp2];
% %         hold on
% %         n = hist3(data,nbins);
% %         n1 = n';
% %         n1( size(n,1) + 1 ,size(n,2) + 1 ) = 0;
% %         xb = linspace(min(data(:,1)),max(data(:,1)),size(n,1)+1);
% %         yb = linspace(min(data(:,2)),max(data(:,2)),size(n,1)+1);
% %         imagesc(xb,yb,n1)
% %         colormap(jet)
% %         xlim([xb(1) xb(end)])
% %         ylim([yb(1) yb(end)])
% %         hl1 = line([10 10],[0 0.9]);
% %         hl2 = line([12 12],[0 0.9]);
% %         colorbar
%         ha = scatterhist2(tmp1,tmp2,nbins,color_v1,color_v2,'k');
% %         xlabel('Complete Voc Error (m)')
% %         ylabel(sprintf('Chunk %d Error (m)',j-1))
%         xlabel(labelx)
%         ylabel(labely)
% 
%         hold on
%         plot(x2,y2,'r')
%         clear tmp2
%         bc=get(gcf,'color');
%         set(ha(2:3),'visible','on','color',bc,'box','off');
%         set(ha(2),'xtick',[],'xcolor',bc);
%         set(ha(2),'yticklabel',abs(get(ha(2),'ytick')));
%         set(ha(3),'ytick',[],'ycolor',bc);
%         set(ha(3),'xticklabel',abs(get(ha(3),'xtick')));
%         set(ha(1),'xlim',[0 1],'ylim',[0 1],'xtick',0:0.2:1,'ytick',0:0.2:1,'box','off')
%         set(ha(2),'xlim',[0 1])
%         set(ha(3),'ylim',[0 1])
% %         get(ha(1),'DataAspectRatio')
% %         get(ha(2),'DataAspectRatio')
% %         get(ha(3),'DataAspectRatio')
%         
%     end
%     clear tmp1
% end
%%
close all
tmp = head_error;

for i = size(head_error,2):-1:1
    tmp_dur = dur_mat(:,i);
    small_loc = find(tmp_dur<min_seg_time);
%     size(find(isnan(tmp(:,i))==1))
%     size(small_loc)
    tmp(small_loc,i)=NaN;
    clear small_loc tmp_dur
    
end
tmp_v = zeros(size(tmp,1),1);
for i = 1:size(tmp,1)
    locs = find(isnan(tmp(i,:))==0);
    tmp_v(i,1) = var(tmp(i,locs));
%     disp(tmp_v(i,1))
%     disp(1);
end

% clear small_loc tmp_dur
% [a b] = sort(dur_mat(:,1),'descend');
[a b] = sort(tmp_v,'descend');
sorted_tmp = tmp(b,:);
tmp = sorted_tmp;
disp(1)

color_v = colormap(lines(max_num_chunks));
close all
for i = 0:25:size(tmp,1)
    s = i+1;
    e = i+25;
    if e>size(tmp,1)
        e = size(tmp,1);
    end
    figure('color','w');
    hold on
    xlabel('Error (m)')
    xlim([0 1])
    axis ij
    ylabel('Vocalization')
    for j = 1:size(tmp,2) 
        color_f = color_v(j,:);
%         color_l
        plot(tmp(s:e,j),s:e,'o','MarkerFaceColor',color_f)
    end
    disp(1)
end
    