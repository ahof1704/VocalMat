function fnOptimizeSegmentationParamsFileBased(strSegmentationParamsInFN, ...
                                               strClipFN, ...
                                               strClipFloorFN, ...
                                               strClipBackgroundFN, ...
                                               strGTEllipsesFN, ...
                                               strSegmentationParamsOutFN)

% Load the input segmentation parameters
strctSegParams0=fnLoadAnonymous(strSegmentationParamsInFN);

% show initial params
strctSegParams0  %#ok

% Load the floorplan
a2bFloor=fnLoadAnonymous(strClipFloorFN);
figure; imagesc(a2bFloor,[0 1]); colormap(gray); title('floor');

% Load the background image
%a2fBackground=fnLoadAnonymous('clip5_background.mat');
a2fBackground=fnLoadAnonymous(strClipBackgroundFN);
figure; imagesc(a2fBackground); colormap(gray); title('background');

% Load the GT ellipse data
[a2strctEllipseGT,iFrameGT]= ...
  fnLoadSegmentationGT(strGTEllipsesFN);

% Create the file "object"
strctClip=fnReadSeqInfo(strClipFN);

% Read all the frames we'll need from the video  
[iH,iW]=size(a2fBackground);
[iNumMice,iNumSamples]=size(a2strctEllipseGT);  %#ok
a3iFramesGT=zeros(iH,iW,iNumSamples,'uint8');
for i=1:iNumSamples
  a3iFramesGT(:,:,i)=fnReadFrameFromSeq(strctClip,iFrameGT(i));
end
clear iFrameGT;

% Show the first frame, and the GT ellipses
i=randi(iNumSamples,1);
a2iFrameGTExample=a3iFramesGT(:,:,i);
astrctEllipseGTExample=a2strctEllipseGT(:,i);
fnFigureFrameSegmentationGT(a2iFrameGTExample,astrctEllipseGTExample);
title(sprintf('GT frame %d',i));
drawnow;

% Run the core routine
strctSegParams = ...
  fnOptimizeSegmentationParamsCore(strctSegParams0, ...
                                   a2fBackground, ...
                                   a2bFloor, ...
                                   a3iFramesGT, ...
                                   a2strctEllipseGT)  %#ok

% Compare the before-and-after segmentations on the example frame
a2fFrameGTExample=double(a2iFrameGTExample)/255;
a2iForegroundCC0 = ...
  fnSegmentForeground3(a2fFrameGTExample, ...
                       strctSegParams0, ...
                       a2fBackground, ...
                       a2bFloor);
a2bForeground0=(a2iForegroundCC0>0);      
figure; imagesc(a2bForeground0,[0 1]); colormap(gray); 
title('foreground before');

a2iForegroundCC = ...
  fnSegmentForeground3(a2fFrameGTExample, ...
                       strctSegParams, ...
                       a2fBackground, ...
                       a2bFloor);
a2bForeground=(a2iForegroundCC>0);                     

figure; imagesc(a2bForeground ,[0 1]); colormap(gray); 
title('foreground after');

% Save new segmentaion parameters to the output file.
fnSaveAnonymous(strSegmentationParamsOutFN,strctSegParams);

end
