function [ randomized_cords abstheta mags] = fn_random_select_theta_region_cords(cage_x, cage_y, i, randomized_cords,num_virtual_mice,step_angle,abstheta, mags)
%fn_random_select_cords
%
%   function that randomly selects possible locations (x and y) in the box
%
%   OUTPUT 
%       1) randomized_cords is a matrix with all randomly generated cords  
%           1st column is the x cords for mouse 1 and 2nd column is the y  
%           cords for mouse 1 3rd column is the x cords for mouse 2 and 4th  
%           column is the y cords for mouse 2
%       2) foo is a signal randomization trial that will be stored in 
%           randomized_cords and used for determing mean diff between
%           position and TDOA
%
%   Variables
%       range_x = matrix with the largest and smallest x coords in pixels
%       range_y = matrix with the largest and smallest y coords in pixels
%       i = iteration number
%       randomized_cords = matrix with the previously generated random
%           cords
scale_factor = 10;
mag = 50 + 1; %ranging from 1 num + 1;
            walls(1,:) = cage_x(1);
            walls(2,:) = cage_x(2);
            walls(3,:) = cage_y(1);
            walls(4,:) = cage_y(2);
            walls = walls/10;
            
for j = 1:2:(2*num_virtual_mice)-1
    count2 = 0;
    tmp_x1 = (randomized_cords(i-2,j)*scale_factor);
    tmp_y1 = (randomized_cords(i-2,j+1)*scale_factor);
    tmp_x2 = (randomized_cords(i-1,j)*scale_factor);
    tmp_y2 = (randomized_cords(i-1,j+1)*scale_factor);
    
    d_x = tmp_x1-tmp_x2;
    d_y = tmp_y1-tmp_y2;
    tmp = atan2(d_y,d_x)*180/pi;
    if tmp<0
        theta = 360+tmp;%in degrees
    else
        theta = tmp;%in degrees
    end
    count = 0;
    for l = [step_angle 180]%step_angle:step_angle:180
        count = count + 1;
        tmp_angle1 = theta+l;
        tmp_angle2 = theta-l;
        angles(count,1) = round(tmp_angle2);
%         count = count+1;
%         angles(count,1) = round(tmp_angle2);
        angles(count,2) = round(tmp_angle1);
    end
%     unit = ones(size(angles,1),1);
%     [x2,y2] = pol2cart((angles*2*pi)/180,unit);
%     figure
%     compass(x2,y2)
    
%     for l = 1:size(angles,1)
%         tmp = angles(l,1):10:angles(l,2);
%         if l == 1
%             poss_angles = tmp;
%         else
%             poss_angles = cat(2,poss_angles,tmp);
%         end
%         clear tmp
%     end

    for l = 1:size(angles,1)
        
        if l == 1
            tmp = angles(l,1):1:angles(l,2);
            poss_angles = [tmp tmp tmp tmp tmp];
            poss_angles = [poss_angles poss_angles poss_angles poss_angles poss_angles poss_angles poss_angles poss_angles poss_angles poss_angles];
            poss_angles = [poss_angles poss_angles poss_angles poss_angles];
            clear tmp
        else
            tmp1 = angles(l-1,1):-60:angles(l,1);
            tmp1(1) = [];
            tmp1(end) = [];
            tmp2 = angles(l-1,2):60:angles(l,2);
            tmp2(1) = [];
            tmp2(end) = [];
            tmp = [tmp1 tmp2];
            poss_angles = [poss_angles tmp];%cat(2,poss_angles,tmp);
            change_dir = tmp;
            clear tmp1 tmp2 tmp
        end        
    end

    theta_new = poss_angles(1,randi(size(poss_angles,2))); %degrees
    mag_new = randi(mag)-1;
    [tmp_x,tmp_y] = pol2cart((theta_new*2*pi)/180,mag_new);
    x = tmp_x2+tmp_x*scale_factor;
    y = tmp_y2+tmp_y*scale_factor;
    while (x<cage_x(1) || x>cage_x(2) || y<cage_y(1) || y>cage_y(2))
        theta_new = poss_angles(1,randi(size(change_dir,2))); %degrees
        mag_new = randi(mag)-1;
        [tmp_x,tmp_y] = pol2cart((theta_new*2*pi)/180,mag_new);
        x = tmp_x2+tmp_x*scale_factor;
        y = tmp_y2+tmp_y*scale_factor;
    end
    
%     count2 = count2+1;
    abstheta(i,j) = abs(theta-theta_new);
    mags(i,j) = mag_new;
    x = x/scale_factor;
    y = y/scale_factor;
    randomized_cords(i,j) = x;
    randomized_cords(i,j+1) = y;
    if i>7
        if (randomized_cords(i,j)==randomized_cords(i-6,j)) && (randomized_cords(i,j+1)==randomized_cords(i-6,j+1))
            abs_diff(1) = abs(walls(1)-randomized_cords(i,j));
            abs_diff(2) = abs(walls(2)-randomized_cords(i,j));
            abs_diff(3) = abs(walls(3)-randomized_cords(i,j+1));
            abs_diff(4) = abs(walls(4)-randomized_cords(i,j+1));
            [dummy,I] = min(abs_diff);
            if I == 1
                randomized_cords(i,j) = randomized_cords(i,j) + 50;
                [dummy,I2] = min(abs_diff(3:4));
                if I2 == 1
                    randomized_cords(i,j+1) = randomized_cords(i,j+1) + 50;
                else
                    randomized_cords(i,j+1) = randomized_cords(i,j+1) - 50;
                end
            elseif I == 2
                randomized_cords(i,j) = randomized_cords(i,j) - 50;
                [dummy,I2] = min(abs_diff(3:4));
                if I2 == 1
                    randomized_cords(i,j+1) = randomized_cords(i,j+1) + 50;
                else
                    randomized_cords(i,j+1) = randomized_cords(i,j+1) - 50;
                end
            elseif I == 3
                randomized_cords(i,j+1) = randomized_cords(i,j+1) + 50;
                [dummy,I2] = min(abs_diff(1:2));
                if I2 == 1
                    randomized_cords(i,j) = randomized_cords(i,j) + 50;
                else
                    randomized_cords(i,j) = randomized_cords(i,j) - 50;
                end
            else 
                randomized_cords(i,j+1) = randomized_cords(i,j+1) - 50;
                [dummy,I2] = min(abs_diff(1:2));
                if I2 == 1
                    randomized_cords(i,j) = randomized_cords(i,j) + 50;
                else
                    randomized_cords(i,j) = randomized_cords(i,j) - 50;
                end
            end
            clear dummy I I2 abs_diff
        end
    end
    clear x y tmp_x* tmp_y* range_x range_y mag_new theta_new poss_angles 
    clear tmp* angles d_* theta
end
end


