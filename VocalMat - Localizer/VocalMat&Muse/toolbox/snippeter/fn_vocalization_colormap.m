function [x3,y3,val_low,distance_m1,distance_m2] = fn_vocalization_colormap(dir2, dir3, cord_based_estimate, i_pos, j_pos, box_estimated_delta_t, syl_num, mouse, meters_2_pixels, vfilename)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

TDOA = mouse(syl_num).TDOA;
for count = 1:size(box_estimated_delta_t,1)
    tmp111 = box_estimated_delta_t(count,:);
    estimated_delta_t = cat(1,tmp111,tmp111);
    i = i_pos(count,1);
    j = j_pos(count,1);
    random_mean_mice(1,:) = fn_mean_mice( TDOA, estimated_delta_t);
    cord_based_estimate(j,i) = random_mean_mice(1,1);
    clear estimated_delta_t i j random_mean_mice
end
cd(dir2)
fn_FigureTrackFrame_jpn(vfilename,mouse(syl_num).frame_range(1))
h1 = gcf;
h1a = gca;
y_limits = get(h1a,'ylim');
x_limits = get(h1a,'xlim');
set(h1a,'dataaspectratio',[1 1 1])


x = mouse(1,syl_num).pos_data(1,1).x_head; %true x pos of mouse 1
y = mouse(1,syl_num).pos_data(1,1).y_head; %true y pos of mouse 1
x2 = mouse(1,syl_num).pos_data(1,2).x_head; %true x pos of mouse 2
y2 = mouse(1,syl_num).pos_data(1,2).y_head; %true y pos of mouse 2

close (h1)

figure
h2 = gcf;
h2a = gca;
imagesc(cord_based_estimate)
colormap(jet(256))
xlim(x_limits)
ylim(y_limits)
hold on

plot(x,y,'w^','MarkerSize',7,'MarkerFaceColor','w')%w.
plot(x2,y2,'ws','MarkerSize',7,'MarkerFaceColor','w')%w*
set(h2a,'dataaspectratio',[1 1 1])

[foo_v foo_l] = min(cord_based_estimate);
[val_low foo_l2] = min(min(cord_based_estimate));

y3 = foo_l(foo_l2);
x3 = foo_l2;
plot(x3,y3,'wo','MarkerSize',7,'MarkerFaceColor','w')%w+

point(1)=x3;
point(2)=y3;

distance_m1 = fn_calculate_distance( x, y, point);
distance_m1 = distance_m1*meters_2_pixels;%in mm
distance_m2 = fn_calculate_distance( x2, y2, point);
distance_m2 = distance_m2*meters_2_pixels;%in mm

cd (dir3)
if isdir('colormaps')==0
    mkdir('colormaps')
    cd 'colormaps'
else
    cd 'colormaps'
end
saveas(h2,sprintf('Colormap_%s.jpg',mouse(1,syl_num).syl_name(1:end-4)),'jpg')
close (h2)

end

