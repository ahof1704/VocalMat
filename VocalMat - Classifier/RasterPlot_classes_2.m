%Aug 8th -  Receives the the original .mat calculated for each used for the
%playback experiment and plots the Raster plot, also plotting the moms
%localization.

% close all
clear all
close all
clc
raiz = pwd;

[vfilename,vpathname] = uigetfile({'*.xlsx'},'Select the Classifier output file');
[GT,txt,raw] = xlsread(vfilename);

raw_back_up = raw;
raw(1,:)=[];
table = raw(:,[2,end]);

chevron_stats = table(strcmp(table(:,2),'chevron'),:);
complex_stats = table(strcmp(table(:,2),'complex'),:);
down_fm_stats = table(strcmp(table(:,2),'down_fm'),:);
flat_stats = table(strcmp(table(:,2),'flat'),:);
mult_steps_stats = table(strcmp(table(:,2),'mult_steps'),:);
noise_dist_stats = table(strcmp(table(:,2),'noise_dist'),:);
rev_chevron_stats = table(strcmp(table(:,2),'rev_chevron'),:);
short_stats = table(strcmp(table(:,2),'short'),:);
step_down_stats = table(strcmp(table(:,2),'step_down'),:);
step_up_stats = table(strcmp(table(:,2),'step_up'),:);
two_steps_stats = table(strcmp(table(:,2),'two_steps'),:);
up_fm_stats = table(strcmp(table(:,2),'up_fm'),:);

raster_list{1} = cell2mat(chevron_stats(:,1)');
raster_list{2} = cell2mat(complex_stats(:,1)');
raster_list{3} = cell2mat(down_fm_stats(:,1)');
raster_list{4} = cell2mat(flat_stats(:,1)');
raster_list{5} = cell2mat(mult_steps_stats(:,1)');
raster_list{6} = cell2mat(noise_dist_stats(:,1)');
raster_list{7} = cell2mat(rev_chevron_stats(:,1)');
raster_list{8} = cell2mat(short_stats(:,1)');
raster_list{9} = cell2mat(step_down_stats(:,1)');
raster_list{10} = cell2mat(step_up_stats(:,1)');
raster_list{11} = cell2mat(two_steps_stats(:,1)');
raster_list{12} = cell2mat(up_fm_stats(:,1)');

list_selected = {'chevron','complex','down_fm','flat','mult_steps','noise_dist','rev_chevron','short','step_down','step_up','two_steps','up_fm'};

aux = cellfun('isempty',raster_list);
disp('Removing empty cells')
raster_list(aux) = num2cell(0);
% list_selected = list_selected(aux);

cd(raiz)
figure, plotSpikeRaster(raster_list,'PlotType','vertline');
set(gca,'TickLabelInterpreter','none','YTick',1:size(list_selected,2), 'YTickLabel',list_selected,'YColor','black','YTickLabelRotation',45);
title(vfilename(1:end-5),'Interpreter','none')
xlabel('Time(s)'), ylabel('Call Types');