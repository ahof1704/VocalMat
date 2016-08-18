function r_corners=load_corner_file(corner_file_name)

corners=load_anonymous(corner_file_name);
r_corners=[corners.x_m;corners.y_m];

end
