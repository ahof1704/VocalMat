function fn_plot_ring_hist(dir2, dir3, mouse, meters_2_pixels, theta, positions_out, Vsound, imagefile_mice_prefix )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
cd (dir3)
for j = 1:size(mouse,2)
    num_iteration = 10000;%mouse(j).num_iteration;
    for k = 1:size(mouse(1,j).pos_data,2)
        if k == 1
            x = mouse(1,j).pos_data(1,k).x;
            y = mouse(1,j).pos_data(1,k).y;
            x2 = mouse(1,j).pos_data(1,k+1).x;
            y2 = mouse(1,j).pos_data(1,k+1).y;
        elseif k == 2
            x = mouse(1,j).pos_data(1,k).x;
            y = mouse(1,j).pos_data(1,k).y;
            x2 = mouse(1,j).pos_data(1,k-1).x;
            y2 = mouse(1,j).pos_data(1,k-1).y;
        end
        radius = 200;
        radius_step_size = 200;
        range_r = fn_random_radii(radius, radius_step_size, meters_2_pixels);
        for i = 1:num_iteration %setup parallel processing
            if i == 1
                randomized_cords_r = zeros(num_iteration,2);
                clear TDOA
                TDOA = mouse(1,j).TDOA;
            end
            [randomized_cords_r foo] = fn_random_select_cords_radius( range_r, theta, i, x, y, randomized_cords_r);
            estimated_delta_t = fn_equations( positions_out, Vsound, foo, meters_2_pixels);
            random_mean_mice(i,:) = fn_mean_mice( TDOA, estimated_delta_t);
            clear foo estimated_delta_t
        end
        %can plot random ring points here
        
        trv = mouse(1,j).mean_diff_mice(1,k);
        for number_index = 1:num_iteration  %maybe setup parallel processing
            if random_mean_mice(number_index,1)<=trv
                sym = 'b.';
            elseif random_mean_mice(number_index,1)>trv
                sym = 'r.';
            end
            if number_index == 1
                frame_range(1) = mouse(1,j).frame_range(1);
                mouse_imagefile = sprintf('%s%d',imagefile_mice_prefix,frame_range(1));
                fn_load_picture(dir2,mouse_imagefile);
                hold on
            end
            plot(randomized_cords_r(number_index,1),randomized_cords_r(number_index,2),sym)
            clear sym
        end
        plot(x,y,'y*','MarkerSize',10)
        plot(x2,y2,'g*','MarkerSize',10)
        set(gca,'dataaspectratio',[1 1 1])
        if strcmp(pwd,sprintf('%s\\%s',dir2,dir3))==0
            cd (dir3)
        end
        saveas(gcf,sprintf('Ring range 0-%g mm abs diff mouse %g %s.fig',radius,k,mouse(1,j).syl_name(1:end-4)),'fig')
        saveas(gcf,sprintf('Ring range 0-%g mm abs diff mouse %g %s.jpg',radius,k,mouse(1,j).syl_name(1:end-4)),'jpg')
        close (1)
        clear randomized_cords_r random_mean_mice
    end
end
end

