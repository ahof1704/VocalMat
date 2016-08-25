clear all
close all

[vfilename,vpathname] = uigetfile({'*.xlsx'},'Select the file');
filename = vfilename(1:end-5);
vfile = fullfile(vpathname,vfilename);

[type,sheetname] = xlsfinfo(vfile); 
m=size(sheetname,2); 

alldata = cell(1, m);
alldata_total = [];
mom =[];
% ch1 = [];
% ch2 = [];

n_points = 100; %Bin resolution (number of points)
Ndecimals = 1; %rounding for comparision
f = 10.^Ndecimals;
min_diff_intensity = 10; %Threshold for difference in intensity. If greater than this value, it is probably the mom.
min_diff_freq = 5000; %Threshold for difference in frequency. The detection in different channels can have up to 5kHz of difference.
min_diff_time = 0.01; %Threshold for difference in time. The detection in different channels can have up to 0.01 of time shiffting.
max_freq = 0;
min_freq = inf;
max_dur = 0;
min_dur = inf;

%Load all sheets
for i=1:1:m;
Sheet = char(sheetname(1,i)) ;
alldata{i} = xlsread(vfile, Sheet);
end

for i=1:size(alldata,2) %Run through all animals
    % Check table for '0Hz' fundamental freq and correct it
    freq_zero = find(alldata{1,i}(:,12)==0);
    if ~isempty(freq_zero)
        for j=1:size(freq_zero,1)
            if ~isnan(alldata{1,i}(freq_zero(j),11)) && ~isnan(alldata{1,i}(freq_zero(j),10))
                alldata{1,i}(freq_zero(j),12) = (alldata{1,i}(freq_zero(j),10)+alldata{1,i}(freq_zero(j),11))/2;    
            elseif ~isnan(alldata{1,i}(freq_zero(j),11)) && alldata{1,i}(freq_zero(j),11)~=0
                alldata{1,i}(freq_zero(j),12) = alldata{1,i}(freq_zero(j),11);
            else
                 alldata{1,i}(freq_zero(j),12) = alldata{1,i}(freq_zero(j),10);
                 if  alldata{1,i}(freq_zero(j),12)==0 % Verify again if it is still zero and forget about this shitty point. 
                    alldata{1,i}(freq_zero(j),12) = NaN;
                 end
            end
        end
    end
%     if max(alldata{1,i}(:,12))>max_freq
%         max_freq = max(alldata{1,i}(:,12));
%     end
%     if min(alldata{1,i}(:,12))<min_freq
%         min_freq = min(alldata{1,i}(:,12));
%     end
%     if max(alldata{1,i}(:,2))>max_dur
%         max_dur = max(alldata{1,i}(:,2));
%     end
%     if min(alldata{1,i}(:,2))<min_dur
%         min_dur = min(alldata{1,i}(:,2));
%     end
%         
end

for i=1:size(alldata,2)
%    %Min and Max Fundamental Freq
%    max_freq = max((alldata{1,i}(:,12))); 
%    min_freq = min((alldata{1,i}(:,12))); 
%    %Min and Max duration
%    max_dur = max((alldata{1,i}(:,2))); 
%    min_dur = min((alldata{1,i}(:,2))); 

%Remove noise (thinking that if it appears in both channels with close intensity and almost same time, then it is noise).
if mod(i,2) %Only enters here every two sheets
    ch1 = [];
    ch2 = [];
    [C,index_a,index_b] = intersect(round(f*alldata{1,i}(:,5))/f,round(f*alldata{1,i+1}(:,5))/f); %Verify if there is intersections in time (in decimal sec)

    if ~isempty(C)
        for j = 1:size(index_a,1)
            if abs((alldata{1,i}(index_a(j),5))-(alldata{1,i+1}(index_b(j),5))) < min_diff_time %Verify if they are close enough in time.
                ch1 = [ch1; alldata{1,i}(index_a(j),:)];
                ch2 = [ch2; alldata{1,i+1}(index_b(j),:)];
            end
        end
    end
    %Plotting fundamental freq
       figure('Name',[sheetname{i} ' and ' sheetname{i+1}],'NumberTitle','off','units','normalized','outerposition',[0 0 1 1])
       [y2,x2] = ecdf(ch1(:,12));
       [y1,x1] = hist((ch1(:,12)),n_points); 
       subplot(3,2,1),
       [AX,H1,H2] = plotyy(x1,y1,x2,y2,@(x,y)bar(x,y,1,'c'),'stairs','BinLimits',[40000 120000]);
       set(AX,'xlim',[40000 120000]);
       title(['Frequency distribution ' sheetname{i}]);
       
%        subplot(2,2,1), hist((pup_left(:,12)),n_points,'BinLimits',[40000,110000]); title(['Frequency distribution (Left Pup) ' sheetname{i}]);
       grid on
       xlabel('Frequency (Hz)');
       ylabel('Occurrences');
%        axis([40000 120000 -inf 100]);
       ylim([0 100])
       
       
       [y2,x2] = ecdf(ch1(:,2));
       [y1,x1] = hist((ch1(:,2)),n_points); 
       subplot(3,2,3),
       [AX,H1,H2] = plotyy(x1,y1,x2,y2,@(x,y)bar(x,y,1,'c'),'stairs');
       set(AX,'xlim',[0 0.30]);
       title(['Duration distribution ' sheetname{i}]);
       
%        subplot(2,2,3), hist((pup_left(:,2)),n_points); title(['Duration distribution (Left Pup) ' sheetname{i}]);
       grid on
       xlabel('Duration (s)');
       ylabel('Occurrences');
%        axis([0 0.15 -inf 300]);
       ylim([0 100])
       
       [y2,x2] = ecdf(ch1(:,7));
       [y1,x1] = hist((ch1(:,7)),n_points); 
       subplot(3,2,5),
       [AX,H1,H2] = plotyy(x1,y1,x2,y2,@(x,y)bar(x,y,1,'c'),'stairs');
       set(AX,'xlim',[-70 -25]);
       title(['Intensity distribution ' sheetname{i}]);
       
%        subplot(2,2,3), hist((pup_left(:,2)),n_points); title(['Duration distribution (Left Pup) ' sheetname{i}]);
       grid on
       xlabel('Intensity (dB)');
       ylabel('Occurrences');
%        axis([-70 -15 0 300]);
        ylim([0 100])
       
       [y2,x2] = ecdf(ch2(:,12));
       [y1,x1] = hist((ch2(:,12)),n_points);
       subplot(3,2,2),
       [AX,H1,H2] = plotyy(x1,y1,x2,y2,@(x,y)bar(x,y,1,'c'),'stairs');
       set(AX,'xlim',[40000 120000]);
       title(['Frequency distribution ' sheetname{i+1}]);
       
%        subplot(2,2,2), hist((pup_right(:,12)),n_points,'BinLimits',[40000,110000]); title(['Frequency distribution (Right Pup) ' sheetname{i+1}]);
       grid on
       xlabel('Frequency (Hz)');
       ylabel('Occurrences');
%        axis([40000 120000 -inf 300]);
    ylim([0 100])
       
       [y2,x2] = ecdf(ch2(:,2));
       [y1,x1] = hist((ch2(:,2)),n_points); 
       subplot(3,2,4),
       [AX,H1,H2] = plotyy(x1,y1,x2,y2,@(x,y)bar(x,y,1,'c'),'stairs');
       set(AX,'xlim',[0 0.30]);
       title(['Duration distribution ' sheetname{i+1}]);
       
%        subplot(2,2,4), hist((pup_right(:,2)),n_points); title(['Duration distribution (Right Pup)' sheetname{i+1}]);
       grid on
       xlabel('Duration (s)');
       ylabel('Occurrences');
%        axis([0 0.15 -inf 300]);
        ylim([0 100])

       [y2,x2] = ecdf(ch2(:,7));
       [y1,x1] = hist((ch2(:,7)),n_points); 
       subplot(3,2,6),
       [AX,H1,H2] = plotyy(x1,y1,x2,y2,@(x,y)bar(x,y,1,'c'),'stairs');
       set(AX,'xlim',[-70 -25]);
       title(['Intensity distribution ' sheetname{i+1}]);
       
%        subplot(2,2,4), hist((pup_right(:,2)),n_points); title(['Duration distribution (Right Pup)' sheetname{i+1}]);
       grid on
       xlabel('Intensity (dB)');
       ylabel('Occurrences');
%        axis([-70 -15 0 300]);
       ylim([0 100])
       
       %Plotting some infos...
%        not_identified = size(find(~isnan(alldata{1,i}(:,1))),1) + size(unknown,1) + size(find(~isnan(alldata{1,i+1}(:,1))),1);
%        identified = size(pup_left,1) + size(pup_right,1);
%        ylim=get(gca,'YLim');
%        xlim=get(gca,'XLim');
%        text(xlim(2)-400,ylim(2),['Identifie: ' num2str(identified); 'Not ident: ' num2str(not_identified);...
%            ],'VerticalAlignment','top','HorizontalAlignment','left')
%      MinAreainputLable = uicontrol('Style','text','String',['Identified:   ' num2str(identified); 'Not identied: ' num2str(not_identified)],...
%     'Position',[5,400,70,100], ...
%     'Horizontalalignment', 'left');
       
    %    saveas(gcf,sheetname{i},'jpg')
       saveas(gcf, [vpathname [sheetname{i} ' and'  sheetname{i+1}] '.jpg']);
end
   
% alldata_total = [alldata_total; alldata{i}(:,1:12)];
   
end

% figure('Name',['All Data_' vfilename],'NumberTitle','off')
% subplot(2,1,1), hist((alldata_total(:,12)),n_points,'BinLimits',[40000,110000]); title(['Frequency distribution']);
% grid on
% xlabel('Frequency (Hz)');
% ylabel('Occurrences');
% 
% subplot(2,1,2), hist((alldata_total(:,2)),n_points); title(['Duration distribution']);
% grid on
% xlabel('Duration (s)');
% ylabel('Occurrences');
% saveas(gcf, [vpathname 'All Data_' vfilename '.jpg']);


% figure('Name',['All Data_MOM_' vfilename],'NumberTitle','off')
% subplot(2,1,1), hist((mom(:,12)),n_points,'BinLimits',[40000,110000]); title(['Frequency distribution']);
% grid on
% xlabel('Frequency (Hz)');
% ylabel('Occurrences');
% 
% subplot(2,1,2), hist((mom(:,2)),n_points); title(['Duration distribution']);
% grid on
% xlabel('Duration (s)');
% ylabel('Occurrences');
% saveas(gcf, [vpathname 'All Data_MOM_' vfilename '.jpg']);




