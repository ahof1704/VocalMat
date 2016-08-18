clc
clear
close all

load('A:\Neunuebel\ssl_sys_test\sys_test_06052012\Data_analysis9\Results_who_said_it_single_mouse.mat')
num_virtual_mice = 3;
threshold_p = 0.95;

p_values_m = nan(size(p,2),4);

for i = 1:size(p,2)
    for j = 1:4
        if isnan(p(i).p_values(j,1))==0
            p_values_m(i,j) = p(i).p_values(j,1);
        else
            break
        end
    end
end
edges = 0:0.05:1;
% n = histc(p_values_m(:,1),edges);
% bar(edges,n)
% xlim([-0.1 1.1])
figure('color','w')
hold on
for j = 1:4
    %     subplot(4,1,j)
    %     figure('color','w')
    if j == 1
        color_s = 'g';
        size_l = 2;
    elseif j == 2
        color_s = 'k';
        size_l = 2;
    elseif j == 3
        color_s = 'r';
        size_l = 2;
    elseif j == 4
        color_s = 'c';
        size_l = 2;
    end
    tmp = find(isnan(p_values_m(:,j))==1);
    not_localizable = size(tmp,1);
    clear tmp
    tmp = find(p_values_m(:,j)>0.95);
    below(:,j) = p_values_m(:,j)<=0.95;
    winner(j,1) = size(tmp,1);
    n = histc(p_values_m(:,j),edges);
    %         bar(n',edges)
    pl = plot(edges,n,'.-');
    set(pl,'Color',color_s,...
        'LineWidth',size_l,...
        'MarkerEdgeColor',color_s,...
        'MarkerSize',20,...
        'MarkerFaceColor',color_s)
    %     hist(p_values_m(:,j),edges)
    %     [n bin] = histc(p_values_m(:,j),edges);
    clear tmp
    xlim([-0.1 1.1])
%     if j == 1
%         title(sprintf('Mouse %d',j))
%     else
%         title(sprintf('Vitual mouse %d',j))
%     end
    ylabel('Count')
    xlabel('P value')
end
legend({'Mouse 1','VM 1','VM 2','VM 3'})
localizable = size(p_values_m,1)-not_localizable;
winner/localizable
clear tmp; 
tmp = sum(below,2);
all_below = find(tmp==4);
below_ps = p_values_m(all_below,:);
disp(sprintf('Number localizable segements not assigned to any animal: %d',size(below_ps,1)))
[largeset_p_below loc_largest_p] = max(below_ps,[],2);
real_animal_highest_p_not_assignable = size(find(loc_largest_p==1),1);
disp(sprintf('Real animal number = %d',real_animal_highest_p_not_assignable))


disp(1)
% load('A:\Neunuebel\ssl_sys_test\sys_test_06052012\Data_analysis8\Results.mat')
% num_virtual_mice = 3;
% threshold_p = 0.05;
%
% ordered_p = zeros(4,size(p,2));
% ordered_p_loc = zeros(4,size(p,2));
%
% for i = 1:size(p,2)
%     tmp = p(i).p_values;
%     if isnan(tmp)==0
%         [ordered_p(:,i) ordered_p_loc(:,i)] = sort(tmp,'descend');
%     elseif isnan(tmp)==1
%         ordered_p(1,i) = 0;
%         ordered_p_loc(1,i) = 0;
%     end
%     clear tmp
% end
% largest_p = zeros(1,num_virtual_mice+2);
% for i = 1:num_virtual_mice + 2;
%     if i == 5
%         search_num = 0;
%     else
%         search_num = i;
%     end
%     tmp = find(ordered_p_loc(1,:)==search_num);
%     largest_p(1,i) = size(tmp,2);
%     clear tmp
% end
% figure
% bar(largest_p)
% title('Largest P Values')
% xlabel('Mouse Number')
% set(gca,'Xticklabel',{'1','2','3','4','NaN'})
% ylabel('Count')
% figure
% tmp = ordered_p_loc(1,:)==0;
% tmp1 = ordered_p;
% tmp1(:,tmp) = [];
% scatter(tmp1(1,:),tmp1(2,:),'filled')
% title('Two Largest P Values')
% xlabel('Largest')
% ylabel('2nd Largest')
%
% xlim([0 1])
% ylim([0 1])
% clear tmp tmp1 tmp2
% count = 0;
% for i = 1:size(ordered_p_loc,2)
%     tmp = ordered_p(:,i);
%     tmp1  = find(tmp>=threshold_p);
%     if size(tmp1,1)==1
%         count = count + 1;
%         if isnan(ordered_p_loc(1,i))==0
%             mouse(count,1) = ordered_p_loc(1,i);
%         end
%     end
% end
%
% who_it_be = zeros(1,num_virtual_mice+1);
% for i = 1:num_virtual_mice + 1;
%     tmp = find(mouse(:,1)==i);
%     who_it_be(1,i) = size(tmp,1);
%     clear tmp
% end
% figure
% bar(who_it_be)
% title('Mouse Assignment')
% xlabel('Mouse Number')
% ylabel('Count')
