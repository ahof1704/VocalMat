function fim(I,iFigureNumber)
if exist('iFigureNumber','var')
    figure(iFigureNumber);
else
    figure;
end
imshow(I,[]);
impixelinfo
