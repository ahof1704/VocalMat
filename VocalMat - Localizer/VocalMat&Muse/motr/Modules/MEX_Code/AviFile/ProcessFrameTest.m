function [OutImage] = ProcessFrameTest(InImage,K);

OutImage = InImage;
figure(10);imshow(InImage);
disp(['Frame : ',num2str(K)]);
drawnow;
