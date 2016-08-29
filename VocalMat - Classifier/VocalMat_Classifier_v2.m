% close all
tic
clc
clear all
raiz = pwd;
[vfilename,vpathname] = uigetfile({'*.mat'},'Select the output file');
cd(vpathname);
list = dir('*.mat');

for Name = 1:size(list,1)
vfilename = list(Name).name;
% vfilename = vfilename(1:end-4);
vfile = fullfile(vpathname,vfilename);
% vfilename = vfilename(1:end-4);
% vfile = fullfile(vpathname,vfilename);

disp(['Reading ' vfilename])
load([vfile]);
dx = 0.4;

% general_analysis.Animal.name = vfilename;
% eval(['general_analysis.' num2str(k) '.interval = interval;'])

if ~isempty(strfind(vfilename,'Control'))
    eval(['general_analysis.Animal_' vfilename '.Categorie = ''Control'';'])
else
%     vfilename(6:15) = 'Agrp_Trpv1';
    vfilename(strfind(vfilename,'-')) = '_';
    eval(['general_analysis.Animal_' vfilename '.Categorie = ''Agrp-Trpv1'';'])
end

if ~isempty(strfind(vfilename,'1st'))
    eval(['general_analysis.Animal_' vfilename '.Stage = ''1st'';'])
else
%     general_analysis.Animal.Stage = '2nd';
    eval(['general_analysis.Animal_' vfilename '.Stage = ''2nd'';'])
end

% figure('Name',vfilename,'NumberTitle','off')
% hold on
% grid on
% plot3(T,F(nd),q,'r','linewidth',4)
% disp('Showing segmented points')
% for k=1:size(time_vocal,2)
%     scatter3(time_vocal{k},freq_vocal{k},intens_vocal{k},'filled')
% end
% hold off
% c = colorbar;
% c.Label.String = 'dB';
% view(2)

%Remove too small vocalizations (< 5 points)
% disp('Finding jumps')
% dist_vocal = {};
% for k=1:size(time_vocal,2)
% 
%    dista = [];
%    for j = 1:size(time_vocal{k},2)-1
%        dista = [dista; pdist([time_vocal{k}(j:j+1)' freq_vocal{k}(j:j+1)'],'euclidean')];
%    end
%    dist_vocal{k} = dista;
% %    
% %    if median(dist) > 1000 %in general, when it is a real vocalization, the median is exaclty 244.1406!!
% %        time_vocal{k}=[];
% %        freq_vocal{k}=[];
% %        intens_vocal{k}=[];
% %    end
% end

disp('Separating in bins of 5min');
bin_1 = {};
bin_2 = {};
bin_3 = {};
bin_4 = {};
% for k=1:size(time_vocal,2)
%      if time_vocal{k}(1) < 5*60 %5min
%         bin_1 = [bin_1, time_vocal{k}];
%      elseif time_vocal{k}(1) >= 5*60 && time_vocal{k}(1) < 10*60
%         bin_2 = [bin_2, time_vocal{k}];
%      elseif time_vocal{k}(1) >= 10*60 && time_vocal{k}(1) < 15*60
%          bin_3 = [bin_3, time_vocal{k}];
%      else
%          bin_4 = [bin_4, time_vocal{k}];
%      end
% end
% 
% eval(['general_analysis.Animal_' vfilename '.bin1' '.total_vocal = bin_1;'])
% eval(['general_analysis.Animal_' vfilename '.bin2' '.total_vocal = bin_2;'])
% eval(['general_analysis.Animal_' vfilename '.bin3' '.total_vocal = bin_3;'])
% eval(['general_analysis.Animal_' vfilename '.bin4' '.total_vocal = bin_4;'])
% general_analysis.Animal.bin1.total_vocal = bin_1;
% general_analysis.Animal.bin2.total_vocal = bin_2;
% general_analysis.Animal.bin3.total_vocal = bin_3;
% general_analysis.Animal.bin4.total_vocal = bin_4;

for k=1:size(time_vocal,2)
     if time_vocal{k}(1) < 5*60 %5min
        bin_1 = [bin_1, time_vocal{k}];
     elseif time_vocal{k}(1) >= 5*60 && time_vocal{k}(1) < 10*60
        bin_2 = [bin_2, time_vocal{k}];
     elseif time_vocal{k}(1) >= 10*60 && time_vocal{k}(1) < 15*60
         bin_3 = [bin_3, time_vocal{k}];
     else
         bin_4 = [bin_4, time_vocal{k}];
     end
%      eval(['general_analysis.Animal_' vfilename '.bin' num2str(k) '.total_vocal = bin_' num2str(k) ';']);
end

eval(['general_analysis.Animal_' vfilename '.bin1' '.total_vocal = bin_1;'])
eval(['general_analysis.Animal_' vfilename '.bin2' '.total_vocal = bin_2;'])
eval(['general_analysis.Animal_' vfilename '.bin3' '.total_vocal = bin_3;'])
eval(['general_analysis.Animal_' vfilename '.bin4' '.total_vocal = bin_4;'])

disp('Calculating interval between vocalizations');
for k=1:4
   interval = [];
   for j=1:size(eval(['bin_' num2str(k)]),2)-1
      interval = [interval, time_vocal{j+1}(1)- time_vocal{j}(end)];
   end
   eval(['general_analysis.Animal_' vfilename '.bin' num2str(k) '.interval = interval;'])
%    eval(['general_analysis.Animal.bin' num2str(k) '.interval = interval;']) 
end

disp('Calculating duration');
for k=1:4
   duration = [];
   for j=1:size(eval(['bin_' num2str(k)]),2)
      duration = [duration, time_vocal{j}(end)- time_vocal{j}(1)];
   end
   eval(['general_analysis.Animal_' vfilename '.bin' num2str(k) '.duration = duration;'])
%    eval(['general_analysis.Animal.bin' num2str(k) '.duration = duration;']) 
end

disp('Calculating frequency range');
for k=1:4
   freq_range = [];
   for j=1:size(eval(['bin_' num2str(k)]),2)
      freq_range = [freq_range, max(freq_vocal{j})-min(freq_vocal{j})];
   end
   eval(['general_analysis.Animal_' vfilename '.bin' num2str(k) '.freq_range = freq_range;'])
%    eval(['general_analysis.Animal.bin' num2str(k) '.freq_range = freq_range;']) 
end

% 
% output = [];
% %Plot names on spectrogram and organize table
disp('Plotting names on spectrogram and organizing table')
for i=1:size(time_vocal,2)
    text(time_vocal{i}(round(end/2)),freq_vocal{i}(round(end/2))+5000,[num2str(i)],'HorizontalAlignment','left','FontSize',20,'Color','r');
%     output = [output; i, size(time_vocal{i},2) , min(time_vocal{i}), max(time_vocal{i}), (max(time_vocal{i})-min(time_vocal{i})) , max(freq_vocal{i}), mean(freq_vocal{i}),(max(freq_vocal{i})-min(freq_vocal{i})) , min(freq_vocal{i}), min(intens_vocal{i}), max(intens_vocal{i}), mean(intens_vocal{i})];
end


% output = array2table(output,'VariableNames', {'ID','Num_points','Start_sec','End_sec','Duration_sec','Max_Freq_Hz','Mean_Freq_Hz','Range_Freq_Hz','Min_Freq_Hz','Min_dB','Max_dB','Mean_dB'});
% warning('off','MATLAB:xlswrite:AddSheet');

% xlswrite(vfile,output,filename)
% writetable(output,[vpathname '_VocalMat'],'FileType','spreadsheet','Sheet',vfilename)
% vfilename
% size(time_vocal,2)
% size(output,1)
% cd(raiz)
% 
% X = [vfilename,' has ',num2str(size(output,1)),' vocalizations.'];
% disp(X)
% 
% set(gca,'xlim',[0 dx]);
% set(gca,'ylim',[0 max(F)]);
% % Generate constants for use in uicontrol initialization
% pos=get(gca,'position');
% % Newpos=[pos(1) pos(2)-0.1 pos(3) 0.05];
% % xmax=max(T);
% % maxF = max(F);
% yourcell = 1:size(time_vocal,2);
% % Newpos=[pos(1) pos(2)-0.1 pos(3) 0.05];
% hb = uicontrol('Style', 'listbox','Position',[pos(1)+10 pos(2)+100 100 pos(4)+700],...
%      'string',yourcell,'Callback',... 
%      ['if get(hb, ''Value'')>0 ',...
%      ' Stri=[''set(gca,''''xlim'''',[-dx/2 dx/2]+['' num2str(time_vocal{get(hb, ''Value'')}(1)) '' '' num2str(time_vocal{get(hb, ''Value'')}(1)) ''])'']; ',...
%      ' eval(Stri); ', ...
%      'end']);
%  %      ' update_slide(get(hb, ''Value''), time_vocal,xmax, maxF), ',...
% 
% % This avoids flickering when updating the axis
% % set(gca,'xlim',[0 dx]);
% % set(gca,'ylim',[0 max(F)]);
% % Generate constants for use in uicontrol initialization
% % pos=get(gca,'position');
% Newpos=[pos(1) pos(2)-0.1 pos(3) 0.05];
% xmax=max(T);
% Stri=['set(gca,''xlim'',get(gcbo,''value'')+[0 ' num2str(dx) '])'];
% h=uicontrol('style','slider',...
%     'units','normalized','position',Newpos,...
%     'callback',Stri,'min',0,'max',xmax-dx,'SliderStep',[0.0001 0.010]);
% % set(gcf,'Renderer','OpenGL')
% 
% % close all
% % save(['output_' vfilename])
% warning('off', 'MATLAB:save:sizeTooBigForMATFile')
% disp('Cleaning variables: y y1 S F T P fs q nd vocal id' ) 
% clear y y1 S F T P fs q nd vocal id
toc 

end

general_analysis = orderfields(general_analysis);
disp('Plotting # calls Control vs Agrp_Trpv1')
list_names = fieldnames(general_analysis);
% Convert to Struct
Asorted = cell2struct(Acell, list_names, 1);


control_bin1 = [];
control_bin2 = [];
control_bin3 = [];
control_bin4 = [];
agrp_bin1 = [];
agrp_bin2 = [];
agrp_bin3 = [];
agrp_bin4 = [];

for k=1:size(list_names,1)
    for bin_num=1:4
        if ~isempty(cell2mat(strfind(list_names(k),'Control')))
           eval(['control_bin' num2str(bin_num) '= [control_bin' num2str(bin_num) ';'  'size(general_analysis.' char(list_names(k)) '.bin' num2str(bin_num) '.total_vocal,2)];']) 
        else
           eval(['agrp_bin' num2str(bin_num) '= [agrp_bin' num2str(bin_num) ';'  'size(general_analysis.' char(list_names(k)) '.bin' num2str(bin_num) '.total_vocal,2)];'])  
        end
    end
end

disp('Calculating total vocalizations through all the files')
% figure
agrp = [agrp_bin1, agrp_bin2, agrp_bin3, agrp_bin4];
list_size = 1:size(agrp,1);
agrp1 = agrp(find(mod(list_size,2)>0),:);
agrp1 = sum(agrp1,1);
subplot(2,1,1), plot(agrp1,'--*');
title('1st stage')
control = [control_bin1, control_bin2, control_bin3, control_bin4];
list_size2 = 1:size(control,1);
control1 = control(find(mod(list_size2,2)>0),:);
control1 = sum(control1,1);
hold on
plot(control1,'--*')
legend('agrp1','control')

agrp1 = agrp(find(mod(list_size,2)==0),:);
agrp1 = sum(agrp1,1);
subplot(2,1,2), plot(agrp1,'--*' );
title('2nd stage')
control1 = control(find(mod(list_size2,2)==0),:);
control1 = sum(control1,1);
hold on
plot(control1, '--*')
legend('agrp1','control')

disp('Calculating interval distribution through all the files')
control_bin1 = [];
control_bin2 = [];
control_bin3 = [];
control_bin4 = [];
agrp_bin1 = [];
agrp_bin2 = [];
agrp_bin3 = [];
agrp_bin4 = [];

for k=1:size(list_names,1)
    for bin_num=1:4
        if ~isempty(cell2mat(strfind(list_names(k),'Control')))
           eval(['control_bin' num2str(bin_num) '= [control_bin' num2str(bin_num) ','  'general_analysis.' char(list_names(k)) '.bin' num2str(bin_num) '.interval];']) 
        else
           eval(['agrp_bin' num2str(bin_num) '= [agrp_bin' num2str(bin_num) ','  'general_analysis.' char(list_names(k)) '.bin' num2str(bin_num) '.interval];'])  
        end
    end
end

figure
agrp = [agrp_bin1, agrp_bin2, agrp_bin3, agrp_bin4];
% list_size = 1:size(agrp,1);
% agrp1 = agrp(find(mod(list_size,2)>0),:);
% agrp1 = reshape(agrp1,1,[]);
% h = histogram(agrp,10000,'Normalization','pdf');
% h.FaceColor = [0 0.5 0.5];
[f,x] = ecdf(agrp);
h = plot(x,f);
control = [control_bin1, control_bin2, control_bin3, control_bin4];
% list_size2 = 1:size(control,1);
% control1 = control(find(mod(list_size2,2)>0),:);
% control1 = reshape(control1,1,[]);
hold on
[f,x] = ecdf(control);
% h1 = histogram(control,10000,'Normalization','pdf');
h1 = plot(x,f);
legend('agrp1','control')
xlim([0 3])

figure
% agrp = [agrp_bin1, agrp_bin2, agrp_bin3, agrp_bin4];
% list_size = 1:size(agrp,1);
% agrp1 = agrp(find(mod(list_size,2)>0),:);
% agrp1 = reshape(agrp1,1,[]);
h = histogram(agrp,10000,'Normalization','pdf');
h.FaceColor = [0 0.5 0.5];
% [f,x] = ecdf(agrp);
% h = plot(x,f);
% control = [control_bin1, control_bin2, control_bin3, control_bin4];
% list_size2 = 1:size(control,1);
% control1 = control(find(mod(list_size2,2)>0),:);
% control1 = reshape(control1,1,[]);
hold on
% [f,x] = ecdf(control);
h1 = histogram(control,10000,'Normalization','pdf');
% h1 = plot(x,f);
legend('agrp1','control')
xlim([0 3])

figure
disp('Identify # of vocalization in clusters')
max_interval_cluster = 2; % if >max_interval_cluster , then it is a new cluster
idxs_agrp = find(agrp>max_interval_cluster);
vocal_in_cluster = idxs_agrp' - circshift(idxs_agrp',[1,0]);
vocal_in_cluster = vocal_in_cluster+2*ones(size(vocal_in_cluster));
vocal_in_cluster = vocal_in_cluster(2:end);
h = histogram(vocal_in_cluster',100,'Normalization','pdf');
h.FaceColor = [0 0.5 0.5];
hold on
idxs_control = find(control>2);
vocal_in_cluster = idxs_control' - circshift(idxs_control',[1,0]);
vocal_in_cluster = vocal_in_cluster+2*ones(size(vocal_in_cluster));
vocal_in_cluster = vocal_in_cluster(2:end);
h1 = histogram(vocal_in_cluster',100,'Normalization','pdf');

legend('agrp1','control')

figure
disp('Identify # of vocalization in clusters')
max_interval_cluster = 2; % if >max_interval_cluster , then it is a new cluster
idxs_agrp = find(agrp>max_interval_cluster);
vocal_in_cluster = idxs_agrp' - circshift(idxs_agrp',[1,0]);
vocal_in_cluster = vocal_in_cluster+2*ones(size(vocal_in_cluster));
vocal_in_cluster = vocal_in_cluster(2:end);
[counts,centers]  = hist(vocal_in_cluster',100);
plot(centers,counts);

hold on
idxs_control = find(control>max_interval_cluster);
vocal_in_cluster1 = idxs_control' - circshift(idxs_control',[1,0]);
vocal_in_cluster1 = vocal_in_cluster1+2*ones(size(vocal_in_cluster1));
vocal_in_cluster1 = vocal_in_cluster1(2:end);
[counts,centers] = hist(vocal_in_cluster1',100);
plot(centers,counts);

legend('agrp1','control')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

raster_list = {};
list_selected = {};
disp('Raster plot for control animals')
for k=1:size(list_names,1)
    if ~isempty(cell2mat(strfind(list_names(k),'Control'))) && ~isempty(cell2mat(strfind(list_names(k),'1st')))
        all = [];
        for bin_num=1:4
            eval(['all'  '= [all' ','  'general_analysis.' char(list_names(k)) '.bin' num2str(bin_num) '.total_vocal];']) 
        end
        raster_list{k} = cell2mat(all); 
        list_selected{k} = char(list_names(k));
    end
end

disp('Removing empty cells')
raster_list = raster_list(~cellfun('isempty',raster_list));
list_selected = list_selected(~cellfun('isempty',list_selected));
figure, plotSpikeRaster(raster_list,'PlotType','vertline');
set(gca,'TickDir','out','TickLabelInterpreter','none','YTick',[1:size(list_selected,2)], 'YTickLabel',list_selected');


raster_list = {};
list_selected = {};
disp('Raster plot for control animals')
for k=1:size(list_names,1)
    if ~isempty(cell2mat(strfind(list_names(k),'Control'))) && ~isempty(cell2mat(strfind(list_names(k),'2nd')))
        all = [];
        for bin_num=1:4
            eval(['all'  '= [all' ','  'general_analysis.' char(list_names(k)) '.bin' num2str(bin_num) '.total_vocal];']) 
        end
        raster_list{k} = cell2mat(all); 
        list_selected{k} = char(list_names(k));
    end
end

disp('Removing empty cells')
raster_list = raster_list(~cellfun('isempty',raster_list));
list_selected = list_selected(~cellfun('isempty',list_selected));
figure, plotSpikeRaster(raster_list,'PlotType','vertline');
set(gca,'TickDir','out','TickLabelInterpreter','none','YTick',[1:size(list_selected,2)], 'YTickLabel',list_selected');


raster_list = {};
list_selected = {};
disp('Raster plot for control animals')
for k=1:size(list_names,1)
    if ~isempty(cell2mat(strfind(list_names(k),'Agrp'))) && ~isempty(cell2mat(strfind(list_names(k),'2nd')))
        all = [];
        for bin_num=1:4
            eval(['all'  '= [all' ','  'general_analysis.' char(list_names(k)) '.bin' num2str(bin_num) '.total_vocal];']) 
        end
        raster_list{k} = cell2mat(all); 
        list_selected{k} = char(list_names(k));
    end
end

disp('Removing empty cells')
raster_list = raster_list(~cellfun('isempty',raster_list));
list_selected = list_selected(~cellfun('isempty',list_selected));
figure, plotSpikeRaster(raster_list,'PlotType','vertline');
set(gca,'TickDir','out','TickLabelInterpreter','none','YTick',[1:size(list_selected,2)], 'YTickLabel',list_selected');

raster_list = {};
list_selected = {};
disp('Raster plot for control animals')
for k=1:size(list_names,1)
    if ~isempty(cell2mat(strfind(list_names(k),'Agrp'))) && ~isempty(cell2mat(strfind(list_names(k),'1st')))
        all = [];
        for bin_num=1:4
            eval(['all'  '= [all' ','  'general_analysis.' char(list_names(k)) '.bin' num2str(bin_num) '.total_vocal];']) 
        end
        raster_list{k} = cell2mat(all); 
        list_selected{k} = char(list_names(k));
    end
end

disp('Removing empty cells')
raster_list = raster_list(~cellfun('isempty',raster_list));
list_selected = list_selected(~cellfun('isempty',list_selected));
figure, plotSpikeRaster(raster_list,'PlotType','vertline');
set(gca,'TickDir','out','TickLabelInterpreter','none','YTick',[1:size(list_selected,2)], 'YTickLabel',list_selected');


disp('Putting together 1st and 2nd stage of each animal')
raster_list = {};
list_selected = {};
disp('Raster plot for control animals')
for k=1:size(list_names,1)
    if ~isempty(cell2mat(strfind(list_names(k),'Agrp'))) && ~isempty(cell2mat(strfind(list_names(k),'1st')))
        if ~isempty(cell2mat(strfind(list_names(k+1),'Agrp'))) && ~isempty(cell2mat(strfind(list_names(k+1),'2nd')))
            all = [];
            for j=k:k+1
                for bin_num=1:4
                    eval(['all'  '= [all' ','  '(j-k)*600+cell2mat(general_analysis.' char(list_names(j)) '.bin' num2str(bin_num) '.total_vocal)];']) 
                end
            end
            raster_list{k} = all; 
            list_selected{k} = char(list_names(k));
        end
    end
end

disp('Removing empty cells')
raster_list = raster_list(~cellfun('isempty',raster_list));
list_selected = list_selected(~cellfun('isempty',list_selected));
figure, plotSpikeRaster(raster_list,'PlotType','vertline');
set(gca,'TickDir','out','TickLabelInterpreter','none','YTick',[1:size(list_selected,2)], 'YTickLabel',list_selected');


raster_list = {};
list_selected = {};
disp('Raster plot for control animals')
for k=1:size(list_names,1)
    if ~isempty(cell2mat(strfind(list_names(k),'Control'))) && ~isempty(cell2mat(strfind(list_names(k),'1st')))
        if ~isempty(cell2mat(strfind(list_names(k+1),'Control'))) && ~isempty(cell2mat(strfind(list_names(k+1),'2nd')))
            all = [];
            for j=k:k+1
                for bin_num=1:4
                    eval(['all'  '= [all' ','  '(j-k)*600+cell2mat(general_analysis.' char(list_names(j)) '.bin' num2str(bin_num) '.total_vocal)];']) 
                end
            end
            raster_list{k} = all; 
            list_selected{k} = char(list_names(k));
        end
    end
end

disp('Removing empty cells')
raster_list = raster_list(~cellfun('isempty',raster_list));
list_selected = list_selected(~cellfun('isempty',list_selected));
figure, plotSpikeRaster(raster_list,'PlotType','vertline');
set(gca,'TickDir','out','TickLabelInterpreter','none','YTick',[1:size(list_selected,2)], 'YTickLabel',list_selected');