function [positions_out, handle] = fn_mic_pos_location(dir_name,image_file_name_local,meters_2_pixels,load_saved_positions)
% fn_mic_pos_location
%   This function allows one to create a structure with the the following 
%       vars x_pix, y_pix, x_m, y_m, and z_m
%
%   manual selection of mic location 
%
%   y_pix and x_pix is the pix number for y and y position of the 
%       microphone based on pixels in image
%   x_m, y_m and z_m are the position of the microphone in meters
%
%   top left corner is (0,0)
%
%   dir1 = directory where image of microphones and saved structure is 
%       located (string)
%   imagefile = name of jpg file with microphones and walls (string)
%   load_saved_positions = 'y' or 'n' and determines if mic positions 
%       are calculated or loads saved data
%   meters_2_pixels = conversion factor that can be used for  going 
%       from pixels to meters
%   
%**********************************************************************
%
%   NOTE:
%       Program rotates the image 90 degrees clockwise, so that microphone
%       1 is located in upper left corner
%

%cd (dir_name)
if strcmp(load_saved_positions,'n')==1  
%     image_matrix = imread(imagefile, fmt);
%     image_matrix_r = imrotate(image_matrix,270);%rotates camera position so that microphone 1 is located in upper left corner
    image_file_name_abs = fullfile(dir_name,image_file_name_local);
    [positions_out, handle] = fn_position_calib(image_file_name_abs,meters_2_pixels);%this function is a function from Roian Egnor and modified by jpn
    sfname1 = fullfile(dir_name,'positions_out');
    sfname2 = fullfile(dir_name,'meters_2_pixels');
    save(sfname1,'positions_out')
    save(sfname2,'meters_2_pixels');
else
    figure('Visible','off')
    handle = gcf;
    file_name=fullfile(dir_name,'positions_out.mat');
    load(file_name);
end
