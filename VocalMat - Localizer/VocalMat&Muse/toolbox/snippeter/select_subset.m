clc
close all
clear all

load('A:\Neunuebel\ssl_vocal_structure\10072012\Data_analysis5\Test_B_1_Mouse.mat')
dir1 = 'A:\Neunuebel\ssl_vocal_structure\10072012\';
save_dir = 'Data_analysis7';
index = [mouse.index];
voc_of_interest = [35,41,44,53,59,63,72,75,88,91,95,97,102,108,113];
voc_list = zeros(size(voc_of_interest,2),12);
count = 0;
for i = voc_of_interest
    tmp = find(index==i);
    idx = tmp(1);
    count = count + 1;
    voc_list(count,1) = count;
    voc_list(count,2) = mouse(idx).start_sample_fine;
    voc_list(count,3) = mouse(idx).stop_sample_fine;
    voc_list(count,4) = mouse(idx).lf_fine;
    voc_list(count,5) = mouse(idx).hf_fine;
    voc_list(count,6) = 1;
end
if isdir([dir1 save_dir])==0
    mkdir([dir1 save_dir])
end
cd ([dir1 save_dir])
save('Subset_overlaps_voc_list','voc_list')


