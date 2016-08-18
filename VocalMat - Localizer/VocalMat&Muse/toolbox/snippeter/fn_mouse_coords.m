function [mouse_location ] = fn_mouse_coords(dir2,mouse,i,vfilename,num_mice)
%fn_mouse_coords
%   function allows user to manually extract the mouse's head position
%   using the mouse curser.  The order that mice are selected must be the
%   same for each frame.
%
%   OUTPUT (mouse_location) is a structure with the x and y position of all
%   mice (n = num_mice) recorded in experiment.  Values returned are in
%   pixels
%
%   Variables
%   
%   dir2 = directory with jpg image of mice positions during time of
%       vocalizations
%   mouse_imagefile = name of file
%   num_mice = number mice in experiment
%   
%   **********************************************************************
%
%   NOTE:
%       Program rotates the image 90 degrees clockwise, so that microphone
%       1 is located in upper left corner
%
% fmt = 'jpg';
% cd (dir2)
% image_matrix = imread(mouse_imagefile, fmt);
% image_matrix_r = imrotate(image_matrix,270);%rotates camera position so that microphone 1 is located in upper left corner
% % plot the image
% imagesc(image_matrix_r);
% 
% 
% 
% colormap(gray)
% set(gca,'dataaspectratio',[1 1 1])
% axis ij
clc
cd (dir2)
fn_FigureTrackFrame_jpn(vfilename,mouse(i).frame_range(1))
disp(sprintf('Syl number %g',i))
disp('Zoom with mouse, then press left arrow key')
zoom
pause
zoom off

[mouse_location(1:num_mice).x_head]=deal([]);
for i=1:num_mice 
    %mark tip of head
    label = sprintf('measure head of mouse %d',i);
    disp(label);
    [mouse_location(i).x_head,mouse_location(i).y_head]=get_pos;
    disp(['     x = ' num2str(mouse_location(i).x_head) ' y = ' num2str(mouse_location(i).y_head)])
    
    %mark base of tail
    label = sprintf('measure base of mouse %d tail',i);
    disp(label);
    [mouse_location(i).x_tail,mouse_location(i).y_tail]=get_pos;
    disp(['     x = ' num2str(mouse_location(i).x_tail) ' y = ' num2str(mouse_location(i).y_tail)])   
end;
close (gcf)
end

function [x,y]=get_pos

cur_pos=ginput(1);
x=cur_pos(1,1);
y=cur_pos(1,2);
end