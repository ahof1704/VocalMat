function [convex_set_x, convex_set_y, convex_hull, area_convex_hull, in] = fn_probability_convexhull(dir2, dir3, num_iteration, randomized_cords_r, random_mean_mice, trv, mouse_num, vfilename, j, mouse, meters_2_pixels )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
cd (dir2)
x = mouse(1,j).pos_data(1,mouse_num).x_head;
y = mouse(1,j).pos_data(1,mouse_num).y_head;

if mouse_num==1
    col = [1,2];
elseif mouse_num==2
    col = [3,4];
end

if mouse_num == 1
    x = mouse(1,j).pos_data(1,mouse_num).x_head; %true x pos of mouse 1
    y = mouse(1,j).pos_data(1,mouse_num).y_head; %true y pos of mouse 1
    x2 = mouse(1,j).pos_data(1,mouse_num+1).x_head; %true x pos of mouse 2
    y2 = mouse(1,j).pos_data(1,mouse_num+1).y_head; %true y pos of mouse 2
elseif mouse_num == 2
    x = mouse(1,j).pos_data(1,mouse_num-1).x_head;%true x pos of mouse 1
    y = mouse(1,j).pos_data(1,mouse_num-1).y_head;%true y pos of mouse 1
    x2 = mouse(1,j).pos_data(1,mouse_num).x_head;%true x pos of mouse 2
    y2 = mouse(1,j).pos_data(1,mouse_num).y_head;%true y pos of mouse 2
end
% frame_range(1) = mouse(1,j).frame_range(1,1);
% mouse_imagefile = sprintf('%s%d',imagefile_mice_prefix,frame_range(1));
% fn_load_picture(dir2,mouse_imagefile);
fn_FigureTrackFrame_jpn(vfilename,mouse(j).frame_range(1))
hold on
number_below = 0;
% distance_distrubtion = zeros(1,3);
convex_set_x = zeros(1,1);
convex_set_y = zeros(1,1);
for i = 1:num_iteration
    if random_mean_mice(i,mouse_num)<=trv%need flexiblity in this if then statement
        number_below = number_below+1;
%         distance_distrubtion(number_below,1) = mouse_num;
%         distance_distrubtion(number_below,2) = fn_calculate_distance( x, y, randomized_cords_r(i,col(1,1):col(1,2)));
%         distance_distrubtion(number_below,3) = fn_calculate_distance( x2, y2, randomized_cords_r(i,col(1,1):col(1,2)));
        %added on 4/9/2012 by jpn
        convex_set_x(number_below,1) = randomized_cords_r(i,col(1,1));
        convex_set_y(number_below,1) = randomized_cords_r(i,col(1,2));
        sym = 'b.';
    elseif random_mean_mice(i,mouse_num)>trv
        sym = 'r.';
    end
    plot(randomized_cords_r(i,col(1,1)),randomized_cords_r(i,col(1,2)),sym)
    clear sym
end
if size(convex_set_x,1)>=2
    [convex_hull area_convex_hull] = convhull(convex_set_x,convex_set_y);
    in(1) = inpolygon(x,y,convex_set_x(convex_hull),convex_set_y(convex_hull));
    in(2) = inpolygon(x2,y2,convex_set_x(convex_hull),convex_set_y(convex_hull));
    
    plot(x,y,'y.','MarkerSize',10)
    plot(x2,y2,'g.','MarkerSize',10)
    plot(convex_set_x(convex_hull),convex_set_y(convex_hull),'k-','linewidth',2)
else
    convex_hull = NaN;
    area_convex_hull = NaN;
    if mouse_num == 1
        in(1) = NaN;
        in(2) = NaN;
    elseif mouse_num == 2
        in(1) = NaN;
        in(2) = NaN;
    end
    
    plot(x,y,'y.','MarkerSize',10)
    plot(x2,y2,'g.','MarkerSize',10)
end

set(gca,'dataaspectratio',[1 1 1])
cd (dir3)
if isdir('probability_plots')==0
    mkdir('probability_plots')
    cd 'probability_plots'
else
    cd 'probability_plots'
end

saveas(gcf,sprintf('Prob_abs_diff_%s_mouse%g.jpg',mouse(1,j).syl_name(1:end-4),mouse_num),'jpg')
close (gcf)

% distance_distrubution_mm = distance_distrubtion * meters_2_pixels * 1000;
% 
% figure
% [n1,xout1] = hist(distance_distrubution_mm(:,3),50);
% area(xout1,n1,'LineWidth',3,'FaceColor','g','EdgeColor','g');
% 
% hold on
% [n2,xout2] = hist(distance_distrubution_mm(:,2),50);
% area(xout2,n2,'LineWidth',3,'FaceColor','y','EdgeColor','y');
% 
% 
% if xout1(end)>=xout2(end)
%     max_xlim = ceil(xout1(end)+5);
% else
%     max_xlim = ceil(xout2(end)+5);
% end
% xlim([0 max_xlim])
% xlabel('Distance (mm)')
% ylabel('Count')
% 
% [p,h,stats] = ranksum(distance_distrubtion(:,2),distance_distrubtion(:,3));
% title(sprintf('P = %g Ranksum = %g N = %g',p,stats.ranksum, size(distance_distrubtion(:,3),1))) 
% cd (dir3)
% if isdir('distance_distribution')==0
%     mkdir('distance_distribution')
%     cd 'distance_distribution'
% else
%     cd 'distance_distribution'
% end
% saveas(gcf,sprintf('Distance_distribution_%s_mouse%g.jpg',mouse(1,j).syl_name(1:end-4),mouse_num),'jpg')
% close (gcf)
end

