function [ meters_2_pixels, handle ] = fn_scale_factor(dir_name, image_file_name, scale_size, load_saved_conversion_factor)
%fn_scale_factor
%   function calculates the converstion factor from known length of a tape
%   measure that has been recorded as a video using stream pix,
%   which is the last recording session of the experiment
%
%   user indicates the ends of the tape measure by selecting them with the
%   mouse
%
%   OUTPUT (meters_2_pixels) is the conversion factor
%
%   Variables
%
%   dir1 = name of directory with image of tape measure
%   imagefile = name of the file that has a jpg picture of the tape measure
%       this needs to be converted from the .seq file recorded with stream
%       pix and is NOT automatically done in this program
%   scale_size = length of tape measure in INCHES
%   load_saved_conversion_factor = if calcution has been done and is saved,
%       the fuction will load the matlab file called meters_2_pixels
%   
%   **********************************************************************
%
%   NOTE:
%       Program rotates the image 90 degrees clockwise, so that microphone
%       1 is located in upper left corner
%
if strcmp(load_saved_conversion_factor,'n')==1
%     fmt = 'jpg';
    x_m = scale_size*0.0254; %0.3556; %1 inche = 0.0254 meters
    
    %cd (dir_name)
    image_file_name_abs = fullfile(dir_name,image_file_name);
    fn_FigureTrackFrame_jpn(image_file_name_abs,6);
    handle = gcf;
    disp('Zoom with mouse, then press any left arrow key')
    zoom
    pause
    zoom off
%     image_matrix = imread(imagefile, fmt);
%     image_matrix_r = imrotate(image_matrix,270);%rotates camera position so that microphone 1 is located in upper left corner
%     % plot the image
%     imagesc(image_matrix_r);
%     colormap(gray)
%     set(gca,'dataaspectratio',[1 1 1])
%     axis ij
    % extract the two points on a ruler to calculate meter_per_pixel
    [new(1:2).x]=deal([]);
    for i=1:2
        switch isnumeric(i)
            case i == 1
                position_label = 'top side';
            case i == 2
                position_label = 'bottom side';
        end
        label = sprintf('measure %s edge of ruler',position_label);
        disp(label);
        [new(i).x,new(i).y]=get_pos;
        disp(['     x = ' num2str(new(i).x) ' y = ' num2str(new(i).y)])
    end;
    
    x_pix_1=fn_position_to_distance([new(1).x, new(1).y],[new(2).x,new(2).y]);
    meters_2_pixels =x_m/x_pix_1;
    meters_2_pixels_file_name_abs=fullfile(dir_name,'meters_2_pixels');
    save(meters_2_pixels_file_name_abs,'meters_2_pixels')    
else
    %cd (dir_name) %added on 2/26/2013
    meters_2_pixels_file_name_abs=fullfile(dir_name,'meters_2_pixels');
    load(meters_2_pixels_file_name_abs);
    figure('Visible','off')
    handle = gcf;
end
end

function [x,y]=get_pos

cur_pos=ginput(1);
x=cur_pos(1,1);
y=cur_pos(1,2);
end
