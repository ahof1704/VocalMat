function fn_plot_calculate_radius_probs(dir2, dir3, mouse, radius_step_size, meters_2_pixels, theta, positions_out, Vsound, imagefile_mice_prefix, video_fname_prefix)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

for j = 1:size(mouse,2)
    num_iteration = mouse(1,j).num_iteration;
    for k = 1:size(mouse(1,j).pos_data,2)
        x = mouse(1,j).pos_data(1,k).x;
        y = mouse(1,j).pos_data(1,k).y;
        p = 1;
        radius = 0;
        radius_number = 0;
        while p>=0.05
            radius = radius + radius_step_size;
            radius_number = radius_number + 1;
            %convert radius from inches-->meters-->pixels
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
            
            if radius_number == 1
                frame_range(1) = mouse(1,j).frame_range(1);
                mouse_imagefile = sprintf('%s%d',imagefile_mice_prefix,frame_range(1));
                fn_load_picture(dir2,mouse_imagefile);
                if k == 1
                    ring_image_file_name = sprintf('Image_mice_%s_%g_corr_thresh.jpg',...
                        mouse(1,j).syl_name(1:end-4),mouse(1,j).corr_thresh);
                    if strcmp(pwd,sprintf('%s\\%s',dir2,dir3))==0
                        cd (dir3)
                    end
                    saveas(gcf,ring_image_file_name,'jpg')
                    clear ring_image_file_name
                end
            end
            
            trv_m1 = mouse(1,j).mean_diff_mice(1,k);
            precent_m1 = size((find(trv_m1>random_mean_mice(:,1))),1)/num_iteration;
            mouse(1,j).mean_radii_sig(k,radius_number) = precent_m1;
            p = precent_m1;
            
            if p>=0.05
                color_change = 25;
                R = rem(radius,color_change);
                
                if R == 5
                    hold on
                    color_p = 'c.';
                    
                elseif R == 10
                    color_p = 'b.';
                    
                elseif R == 15
                    color_p = 'g.';
                    
                elseif R == 20
                    color_p = 'r.';
                    
                elseif R == 0
                    color_p = 'y.';
                end
                plot(randomized_cords_r(:,1),randomized_cords_r(:,2),color_p,'Markersize',3)
                clear color_p R
            end
            
            clear precent_m1 random_mean_mice randomized_cords_r range_r i
            if radius >= 200
                break
            end
        end
        ring_image_file_name = sprintf('Mouse%g_ring_prob_%s_%g_corr_thresh.jpg',...
            k,mouse(1,j).syl_name(1:end-4),mouse(1,j).corr_thresh);
        if strcmp(pwd,sprintf('%s\\%s',dir2,dir3))==0
            cd (dir3)
        end
        saveas(gcf,ring_image_file_name,'jpg')
        close all
        clear x y ring_image_file_name
    end
end

if strcmp(pwd,sprintf('%s\\%s',dir2,dir3))==0
    cd (dir3)
end
save(sprintf('%s_Mouse',video_fname_prefix),'mouse')

end

