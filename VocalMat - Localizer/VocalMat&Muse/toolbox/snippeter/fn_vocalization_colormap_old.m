function [x3,y3,val_low,distance_m1,distance_m2] = fn_vocalization_colormap_old(dir2, dir3, range_x, range_y, imagefile_mice_prefix, syl_num, mouse, meters_2_pixels, Vsound, positions_out )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
cord_based_estimate = zeros(floor(range_y(2)/10),floor(range_x(2)/10));
cord_based_estimate(1:size(cord_based_estimate,1),1:size(cord_based_estimate,2))=NaN;
count = 0;
tic
for i = ceil(range_x(1)/10):floor(range_x(2)/10)
    for j = ceil(range_y(1)/10):floor(range_y(2)/10)
        count = count + 1;
        foo(1,1).x = i;
        foo(1,1).y = j;
        foo(1,2).x = i;
        foo(1,2).y = j;
        TDOA = mouse(syl_num).TDOA;
        estimated_delta_t = fn_equations( positions_out, Vsound, foo, meters_2_pixels);
        random_mean_mice(1,:) = fn_mean_mice( TDOA, estimated_delta_t);
        cord_based_estimate(j,i) = random_mean_mice(1,1);
%         id_min(count,1) = random_mean_mice(1,1);
%         id_min(count,2) = i;
%         id_min(count,3) = j;
        clear estimated_delta_t random_mean_mice foo
    end
    
end
toc
frame_range(1) = mouse(1,syl_num).frame_range(1,1);
mouse_imagefile = sprintf('%s%d',imagefile_mice_prefix,frame_range(1));
fn_load_picture(dir2,mouse_imagefile);
h1 = gcf;
h1a = gca;
y_limits = get(h1a,'ylim');
x_limits = get(h1a,'xlim');
set(h1a,'dataaspectratio',[1 1 1])


x = mouse(1,syl_num).pos_data(1,1).x; %true x pos of mouse 1
y = mouse(1,syl_num).pos_data(1,1).y; %true y pos of mouse 1
x2 = mouse(1,syl_num).pos_data(1,2).x; %true x pos of mouse 2
y2 = mouse(1,syl_num).pos_data(1,2).y; %true y pos of mouse 2

close (h1)

figure
h2 = gcf;
h2a = gca;
imagesc(cord_based_estimate)
colormap(jet(256))
xlim(x_limits)
ylim(y_limits)
hold on

plot(x,y,'w.','MarkerSize',10)
plot(x2,y2,'w*','MarkerSize',5)
set(h2a,'dataaspectratio',[1 1 1])

[foo_v foo_l] = min(cord_based_estimate);
[val_low foo_l2] = min(min(cord_based_estimate));

y3 = foo_l(foo_l2);
x3 = foo_l2;
plot(x3,y3,'w+','MarkerSize',5)

point(1)=x3;
point(2)=y3;

distance_m1 = fn_calculate_distance( x, y, point);
distance_m1 = distance_m1*meters_2_pixels;%in mm
distance_m2 = fn_calculate_distance( x2, y2, point);
distance_m2 = distance_m2*meters_2_pixels;%in mm

cd (dir2)
if strcmp(pwd,sprintf('%s\\%s',dir2,dir3))==0
    cd (dir3)
end
saveas(h2,sprintf('Colormap %s.jpg',mouse(1,syl_num).syl_name(1:end-4)),'jpg')
close (h2)

end

