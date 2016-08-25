% this should show an image of some mice
im=parsejpg8('test.seq',1028);
figure; imagesc(im); colormap(gray);

% this should throw a warning and return an empty matrix, but not
% crash
im=parsejpg8('test.seq',1024)
