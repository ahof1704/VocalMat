function fn_load_picture(dir2,mouse_imagefile)
%UNTITLED3 Summary of this function goes here

fmt = 'jpg';
cd (dir2)
image_matrix = imread(mouse_imagefile, fmt);
image_matrix_r = imrotate(image_matrix,270);%rotates camera position so that microphone 1 is located in upper left corner
% plot the image
figure
imagesc(image_matrix_r);
colormap(gray)
set(gca,'dataaspectratio',[1 1 1])
axis ij


end

