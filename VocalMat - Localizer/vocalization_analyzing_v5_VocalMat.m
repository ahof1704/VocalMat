%May 28th, 2016
%Since the method for separating the overlappings seems to be working, now it is time to also count the vocalizations detected by just one of the
%mics and sum it to the ones separated from the overlapping (made in May 27th).

%May 27th, 2016
%Imports infos from XY coordinates table (mom) and concatantes with the  vocalization table. By doing this, we can check where the mom was when the
%vocalization happened. IF the a vocalization happens and it is detected in both channels at same time and the mom is close to channel where we had
%greater intensity, then we don't know who made the vocalization. On other hand, IF the mom is in opposite side to the channel where we got greater
%intensity, SO we can affirm this is a pup vocalization.


clear all
close all

%Import vocalization files
% [vfilename,vpathname] = uigetfile({'*.xls'},'Select the vocalization file');
% filename = vfilename(1:end-5);
% vfile = fullfile(vpathname,vfilename);
% cd(vpathname);
% [type,sheetname] = xlsfinfo(vfile);

tic
clc
clear all
raiz = pwd;
[vfilename,vpathname] = uigetfile({'*.mat'},'Select the output file');
cd(vpathname);
list = dir('*.mat');
% m=size(list,1);
cd(vpathname);

alldata = cell(1, size(list,1));
alldata_total = [];


%Load all sheets from the vocalization file
for Name = 1:size(list,1)
    vfilename = list(Name).name;
    vfile = fullfile(vpathname,vfilename);
    disp(['Reading ' vfilename])
    alldata{Name} = load(vfile);
end

%Import XY coordinates of the files
[vfilename_xy,vpathname_xy] = uigetfile({'*.xlsx'},'Select the tracking file');
filename_xy = vfilename_xy(1:end-5);
vfile_xy = fullfile(vpathname_xy,vfilename_xy);

[type,sheetname_xy] = xlsfinfo(vfile_xy);
m=size(sheetname_xy,2);

alldata_xy = cell(1, m);
ID = {};
txt = {};

%Load all sheets from the tracking file
for i=1:1:m;
    Sheet = char(sheetname_xy(1,i)) ;
    alldata_xy{i} = xlsread(vfile_xy, Sheet);
    [ID_aux,txt_aux] = xlsread(vfile_xy, Sheet, 'E1:H3');
    ID{i} = ID_aux;
    txt{i} = txt_aux;
end


n_points = 100; %Bin resolution (number of points)
Ndecimals = 1; %rounding for comparision
f = 10.^Ndecimals;
min_diff_intensity = 10; %Threshold for difference in intensity. If greater than this value, it is probably the mom.
min_diff_freq = 5000; %Threshold for difference in frequency. The detection in different channels can have up to 5kHz of difference.
min_diff_time = 0.01; %Threshold for difference in time. The detection in different channels can have up to 0.01 of time shiffting.
xy_file = 0;


%Correcting time in all the sheets
for h=1:size(alldata_xy,2)
    %     t = alldata_xy{1,h}(:,1);
    alldata_xy{1,h}((isnan(alldata_xy{1,h}(:,1))),:)=[];
    t = datestr(alldata_xy{1,h}(:,1),'HH:MM:SS.FFF');  %Transforms time from excel (which was converted to number) to this format
    t = datevec(t);  %Separates time in columns (hours, minutes, seconds, mili)
    t = t(:,5)*60+t(:,6);
    alldata_xy{1,h}(:,1)=t;
end

% for i=1:size(alldata,2) %Run through all animals
%     % Check table for '0Hz' fundamental freq and correct it
%     freq_zero = find(alldata{1,i}(:,7)==0);
%     if ~isempty(freq_zero)
%         for j=1:size(freq_zero,1)
%             if ~isnan(alldata{1,i}(freq_zero(j),11)) && ~isnan(alldata{1,i}(freq_zero(j),10))
%                 alldata{1,i}(freq_zero(j),12) = (alldata{1,i}(freq_zero(j),10)+alldata{1,i}(freq_zero(j),11))/2;
%             elseif ~isnan(alldata{1,i}(freq_zero(j),11)) && alldata{1,i}(freq_zero(j),11)~=0
%                 alldata{1,i}(freq_zero(j),12) = alldata{1,i}(freq_zero(j),11);
%             else
%                  alldata{1,i}(freq_zero(j),12) = alldata{1,i}(freq_zero(j),10);
%                  if  alldata{1,i}(freq_zero(j),12)==0 % Verify again if it is still zero and forget about this shitty point.
%                     alldata{1,i}(freq_zero(j),12) = NaN;
%                  end
%             end
%         end
%     end
% end

% while size(alldata,2)>1
    for i=[1 2]%1:size(alldata,2) %Run through all animals
        
        %Remove noise (thinking that if it appears in both channels with close intensity and almost same time, then it is noise).
%         if mod(i,2) %Only enters here every two sheets
            pup_left =[];
            pup_right = [];
            unknown = [];
            xy_file = xy_file+1; %To advance to next tracking sheet
            
            %Find where was the mom when each vocalization happened
            for animal = [0 2] %Two animals per tracking sheet
                alldata{1,i+animal}.output.Center = zeros(size(alldata{1,i+animal}.output,1),1);
                alldata{1,i+animal}.output.Left = zeros(size(alldata{1,i+animal}.output,1),1);
                alldata{1,i+animal}.output.Right = zeros(size(alldata{1,i+animal}.output,1),1);
                for j=1:size(alldata{1,i+animal}.output,1)
                    small_time = abs(alldata{1,i+animal}.output{j,'Start_sec'}-alldata_xy{1,xy_file}(:,1));
                    [min_time,index] = min(small_time);
                    alldata{1,i+animal}.output{j,'Center'} = alldata_xy{1,xy_file}(index,4);
                    alldata{1,i+animal}.output{j,'Left'} = alldata_xy{1,xy_file}(index,5);
                    alldata{1,i+animal}.output{j,'Right'} = alldata_xy{1,xy_file}(index,6);
                    %             alldata{1,i+animal}.output{j,'Center'} = alldata_xy{1,xy_file}(index,7);
                    %             alldata{1,i+animal}.output{j,'Center'} = alldata_xy{1,xy_file}(index,8);
                end
            end
            
            %Separating vocalization from noise and dealing with channel's overlapping
            [C,index_a,index_b] = intersect(round(f*alldata{1,i}.output{:,'Start_sec'})/f,round(f*alldata{1,i+2}.output{:,'Start_sec'})/f); %Verify if there is intersections in time (in decimal sec)
            
            if ~isempty(C)
                for j = 1:size(index_a,1)
                    if abs((alldata{1,i}.output{index_a(j),'Start_sec'})-(alldata{1,i+2}.output{index_b(j),'Start_sec'})) < min_diff_time %Verify if they are close enough in time.
                        if abs(alldata{1,i+2}.output{index_b(j),'Mean_dB'}-alldata{1,i}.output{index_a(j),'Mean_dB'}) < min_diff_intensity %Compare the intensity and if they are simmilar, it is noise.
                            %                     if abs(alldata{1,i}(index_a(j),12) - alldata{1,i+1}(index_b(j),12)) < min_diff_freq %Verify if the fundamental freq is also equal doesn't work. The noise can present huge difference in frequency.
                            disp(['Vocalization starting in ' num2str(alldata{1,i}.output{index_a(j),'Start_sec'}) ' is noise']);
                            alldata{1,i}.output{index_a(j),:} = NaN;   %Eliminates the noise in both tables
                            alldata{1,i+2}.output{index_b(j),:} = NaN;
                        else %If there is a significant diff in intensity, and the mom is at the other side of this cage, then it is pup. Otherwise, we have no idea who made this sound
                            if alldata{1,i+2}.output{index_b(j),'Mean_dB'} > alldata{1,i}.output{index_a(j),'Mean_dB'}   %Who has greater intensity?
                                [max_val,where_mom] = max(alldata{1,i+2}.output{index_b(j),13:15}); %Center = 13; Left = 14; Right 15
                                if where_mom==2 %The mom was in opposite side (Pup who made the vocalization is on the right side and the mom was on the left)
                                    pup_right = [pup_right;  alldata{1,i+2}.output{index_b(j),:}];
                                    alldata{1,i+2}.output{index_b(j),:} = NaN; %I can't really remove (like =[]) because I get a list of overlapping at the beginning of this loop and I cant shift the indexes there.
                                else
                                    unknown = [unknown; alldata{1,i+2}.output{index_b(j),:}];
                                    alldata{1,i+2}.output{index_b(j),:} = NaN;
                                end
                            else
                                [max_val,where_mom] = max(alldata{1,i}.output{index_a(j),13:15});
                                if where_mom==3 %The mom was in opposite side
                                    pup_left = [pup_left;  alldata{1,i}.output{index_a(j),:}];
                                    alldata{1,i}.output{index_a(j),:} = NaN; %Remove this vocalization from the list
                                else
                                    unknown = [unknown; alldata{1,i}.output{index_a(j),:}];
                                    alldata{1,i}.output{index_a(j),:} = NaN;
                                end
                            end
                        end
                    end
                end
            end
            
            %Selects all the vocalizations that happened when the mom was at the other side of the cage
            mom_right = find(alldata{1,i}.output{:,'Right'}==1); %Center = 13; Left = 14; Right = 15
            for temp = mom_right'
                pup_left = [pup_left; alldata{1,i}.output{temp,:}]; %Shouldn't be necessary to remove these vocalizations from the original list...
                alldata{1,i}.output{temp,:} = NaN; %But I will do just to see if the alldata ends up empty at the end of the process.
            end
            
            mom_left = find(alldata{1,i+2}.output{:,'Left'}==1);
            for temp = mom_left'
                pup_right = [pup_right; alldata{1,i+2}.output{temp,:}];
                alldata{1,i+2}.output{temp,:} = NaN;
            end
            
            %Plotting fundamental freq
            figure('Name',[list(i).name ' and ' list(i+2).name],'NumberTitle','off','units','normalized','outerposition',[0 0 1 1])
            %        figure
            [y2,x2] = ecdf(pup_left(:,7));
            [y1,x1] = hist((pup_left(:,7)),n_points,'BinLimits',[40000,110000]);
            subplot(2,2,1),plotyy(x1,y1,x2,y2,@(x,y)bar(x,y,1,'c'),'stairs')
            title(['Frequency distribution (Left Pup) ' list(i).name],'interpreter', 'none');
            
            %        subplot(2,2,1), hist((pup_left(:,12)),n_points,'BinLimits',[40000,110000]); title(['Frequency distribution (Left Pup) ' sheetname{i}]);
            grid on
            xlabel('Frequency (Hz)');
            ylabel('Occurrences');
%             axis([40000 110000 -inf 300]);
            
            [y2,x2] = ecdf(pup_left(:,5));
            [y1,x1] = hist((pup_left(:,5)),n_points,'BinLimits',[40000,110000]);
            subplot(2,2,3),plotyy(x1,y1,x2,y2,@(x,y)bar(x,y,1,'c'),'stairs')
            title(['Duration distribution (Left Pup) ' list(i).name],'interpreter', 'none');
            
            %        subplot(2,2,3), hist((pup_left(:,2)),n_points); title(['Duration distribution (Left Pup) ' sheetname{i}]);
            grid on
            xlabel('Duration (s)');
            ylabel('Occurrences');
%             axis([0 0.25 0 80]);
            
            [y2,x2] = ecdf(pup_right(:,7));
            [y1,x1] = hist((pup_right(:,7)),n_points,'BinLimits',[40000,110000]);
            subplot(2,2,2),plotyy(x1,y1,x2,y2,@(x,y)bar(x,y,1,'c'),'stairs')
            title(['Frequency distribution (Right Pup) ' list(i+2).name],'interpreter', 'none');
            
            %        subplot(2,2,2), hist((pup_right(:,12)),n_points,'BinLimits',[40000,110000]); title(['Frequency distribution (Right Pup) ' sheetname{i+1}]);
            grid on
            xlabel('Frequency (Hz)');
            ylabel('Occurrences');
%             axis([40000 110000 -inf 300]);
            
            [y2,x2] = ecdf(pup_right(:,5));
            [y1,x1] = hist((pup_right(:,5)),n_points,'BinLimits',[40000,110000]);
            subplot(2,2,4),plotyy(x1,y1,x2,y2,@(x,y)bar(x,y,1,'c'),'stairs')
            title(['Duration distribution (Right Pup)' list(i+2).name],'interpreter', 'none');
            
            %        subplot(2,2,4), hist((pup_right(:,2)),n_points); title(['Duration distribution (Right Pup)' sheetname{i+1}]);
            grid on
            xlabel('Duration (s)');
            ylabel('Occurrences');
%             axis([0 0.25 0 80]);
            
            %Plotting some infos...
            not_identified = size(find(~isnan(alldata{1,i}.output{:,1})),1) + size(unknown,1) + size(find(~isnan(alldata{1,i+2}.output{:,1})),1);
            identified = size(pup_left,1) + size(pup_right,1);
            %        ylim=get(gca,'YLim');
            %        xlim=get(gca,'XLim');
            %        text(xlim(2)-400,ylim(2),['Identifie: ' num2str(identified); 'Not ident: ' num2str(not_identified);...
            %            ],'VerticalAlignment','top','HorizontalAlignment','left')
%             MinAreainputLable = uicontrol('Style','text','String',['Identified as Left Pup:   ' num2str(size(pup_left,1));...
%                 'Identified as Right Pup:   ' num2str(size(pup_right,1));
%                 'Not identied: ' num2str(not_identified)],...
%                 'Position',[5,400,70,100], ...
%                 'Horizontalalignment', 'left');
            ax1 = axes('Position',[0 0 1 1],'Visible','off');
            axes(ax1)
            descr = {'Identified as Left Pup: '; num2str(size(pup_left,1));...
                'Identified as Right Pup: '; num2str(size(pup_right,1));
                'Not identified: '; num2str(not_identified)};
            text(0.05,0.5,descr)
            
            %    saveas(gcf,sheetname{i},'jpg')
            saveas(gcf, [vpathname [list(i).name ' and'  list(i+2).name] '.jpg']);
            xlswrite([vpathname 'All_pups'],pup_left,[list(i).name(8:end-4) '_Left'])
            xlswrite([vpathname 'All_pups'],pup_right,[list(i+2).name(8:end-4) '_Right'])
            %    subplot(2,2,3), hist((alldata{1,i}(:,12)),n_points); title(['Number of points: ', num2str(n_points)]);
            %    subplot(2,2,4), hist((alldata{1,i}(:,12)),n_points+10); title(['Number of points: ', num2str(n_points+10)]);
            
%         end
        
        % %Plot histogram with smoothing line
        % [N,X]=hist((alldata{1,i}(:,12)),n_points+10);
        % H=bar(X,N,1);
        % set(H,'FaceColor','k') %Make the bars black
        %
        % N=conv(N,ones(1,3),'same')/3; %Smooth the bar heights, averaging over 5 bins
        % H=line(X,N); %Plot the smoothed line
        % title(['Number of points: ', sheetname{i}]);
        % set(H,'color','r','linewidth',2) %make it red and thicker
        
        alldata_total = [alldata_total; alldata{i}.output{:,1:12}];
        
%         list([i i+2]) = [];
%         alldata{i} = [];
%         alldata{i+2} = [];
%         alldata = alldata(~cellfun('isempty',alldata));
        
    end
% end

figure('Name',['All Data_' vfilename],'NumberTitle','off','units','normalized','outerposition',[0 0 1 1])

[y2,x2] = ecdf(alldata_total(:,7));
[y1,x1] = hist((alldata_total(:,7)),n_points,'BinLimits',[40000,110000]); title('Frequency distribution');
subplot(2,1,1),plotyy(x1,y1,x2,y2,@(x,y)bar(x,y,1,'c'),'stairs')
% subplot(2,1,1), hist((alldata_total(:,12)),n_points,'BinLimits',[40000,110000]); title(['Frequency distribution']);
grid on
xlabel('Frequency (Hz)');
ylabel('Occurrences');

[y2,x2] = ecdf(alldata_total(:,5));
[y1,x1] = hist((alldata_total(:,5)),n_points,'BinLimits',[40000,110000]); title('Duration distribution');
subplot(2,1,2),plotyy(x1,y1,x2,y2,@(x,y)bar(x,y,1,'c'),'stairs')

% subplot(2,1,2), hist((alldata_total(:,2)),n_points); title(['Duration distribution']);
grid on
xlabel('Duration (s)');
ylabel('Occurrences');
saveas(gcf, [vpathname 'All Data_' vfilename '.jpg']);


% figure('Name',['All Data_PUPs_' vfilename],'NumberTitle','off')
% subplot(2,1,1), hist([pup_left(:,12); pup_right(:,12)],n_points,'BinLimits',[40000,110000]); title(['Frequency distribution']);
% grid on
% xlabel('Frequency (Hz)');
% ylabel('Occurrences');
%
% subplot(2,1,2), hist([pup_left(:,2); pup_right(:,2)]),n_points , title(['Duration distribution']);
% grid on
% xlabel('Duration (s)');
% ylabel('Occurrences');
% saveas(gcf, [vpathname 'All Data_pup_' vfilename '.jpg']);




