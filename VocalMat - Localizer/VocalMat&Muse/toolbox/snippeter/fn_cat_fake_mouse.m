function [ vc_cat ] = fn_cat_fake_mouse(num_virtual_mice,range_x, range_y, scale_factor)
%Function that generates fake mouse position
%
%Input:
%  num_virtual_mice = number of random data points (x/y position) generated
%  range_x (1X2) = range of x dimensions of cage (cm);
%  range_y (1X2) = range of y dimensions of cage (cm);
%  scale_factor =  used to convert to x/y coords from cm to meters
%
%Output:
%  vc_cat = concatenated structure with random mouse head position

%Virtual mice
if num_virtual_mice==1
    vc_cat = fn_random_select_cords3( range_x, range_y, scale_factor)';
end
if num_virtual_mice==2
    vc_tmp1 = fn_random_select_cords3( range_x, range_y, scale_factor)';
    vc_tmp2 = fn_random_select_cords3( range_x, range_y, scale_factor)';
    vc_cat = cat(2,vc_tmp1,vc_tmp2);
end
if num_virtual_mice==3
    vc_tmp1 = fn_random_select_cords3( range_x, range_y, scale_factor)';
    vc_tmp2 = fn_random_select_cords3( range_x, range_y, scale_factor)';
    vc_tmp3 = fn_random_select_cords3( range_x, range_y, scale_factor)';
    vc_cat = cat(2,vc_tmp1,vc_tmp2,vc_tmp3);
end
if num_virtual_mice==4
    vc_tmp1 = fn_random_select_cords3( range_x, range_y, scale_factor)';
    vc_tmp2 = fn_random_select_cords3( range_x, range_y, scale_factor)';
    vc_tmp3 = fn_random_select_cords3( range_x, range_y, scale_factor)';
    vc_tmp4 = fn_random_select_cords3( range_x, range_y, scale_factor)';
    vc_cat = cat(2,vc_tmp1,vc_tmp2,vc_tmp3,vc_tmp4);
end

end

