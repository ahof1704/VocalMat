close all
clear
clc

load('A:\Neunuebel\ssl_sys_test\merged_data\merged1\Data_analysis2\Results_who_said_it_single_mouse.mat')
load('A:\Neunuebel\ssl_sys_test\merged_data\merged1\no_merge_Har\Merged_results_1-out20130405T172917\manual_overlaps_info_Merged_results_1_no_merge_no_har.mat')
load('A:\Neunuebel\ssl_sys_test\merged_data\merged1\Data_analysis2\Merged_results_1_Mouse.mat')

step_size = 0.05;

index = [mouse.index];
num_vocs = max(index);
voc_list_used = nan(1,num_vocs);
for i = 1:num_vocs
    tmp = find(index==i);
    idx = tmp(1);
    voc_list_used(1,i) = str2double(mouse(idx).syl_name_old(4:end));    
end
mouse_number = overlap_info(voc_list_used,2); 

mouse1 = find(mouse_number==1);
mouse2 = find(mouse_number==2);
mouse_both = find(mouse_number==3);

CE_mouse1 = area(mouse1);
CE_mouse2 = area(mouse2);
CE_mouse_double = area(mouse_both);
CE_mouse_single = cat(2,CE_mouse1,CE_mouse2);
largest_value = max([CE_mouse_double CE_mouse_single]);

[ns,xouts] = hist(CE_mouse_single,0:step_size:largest_value);
[nd,xoutd] = hist(CE_mouse_double,0:step_size:largest_value);
ns = ns./sum(ns);
nd = nd./sum(nd);

hf = figure('color','w');
hp(1) = plot(xouts,ns,'k');
hold on
hp(2) = plot(xoutd,nd,'r');
set(hp,'linewidth',3)
ylabel('Proportion total segments')
xlabel('CE area (m^2)');
l1 = sprintf('Single source (n = %d)',size(CE_mouse_single,2));
l2 = sprintf('Two sources (n = %d)',size(CE_mouse_double,2));
hl = legend({l1,l2});
set(gca,'box','off')
set(hl,'box','off')

