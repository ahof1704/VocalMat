function [a2iOnlyMouse,iNumBlobs] = ...
  fnSegmentForeground3(a2fFrame, ...
                       strctSegParams, ...
                       a2fBackground, ...
                       a2bFloor,...
                       a2fTimeStampBB)

% Segments a frame into a connected-components image.
% a2fFrame is the frame, as a double array on [0,1].
% strctSegParams is a set of parameters used in the segmentation
%   process.
% a2fMedian is the background image (pels on [0,1]).
% a2bFloor is the boolean floor mask.
% a2fTimeStampBB is a 2x2 array containing the corners of a bounding box
%   around the time stamp in it's columns.  It can also be empty or omitted 
%   if there's no timestamp in the frame.
%
% On return, a2iOnlyMouse is the connected components image, as a uint16
%   image
% On return, iNumBlobs contains the number of connect components.
%                     
% N.B.: Only method FrameDiff_v7 is implemented here

% Show inputs
%figure; imagesc(a2fFrame); colormap(gray); title('frame');
%figure; imagesc(a2bFloor,[0 1]); colormap(gray); title('floor');

% Deal with parameters
if nargin<5
  a2fTimeStampBB=[];
end

% Hard-coded params
fLargeMotionRatioThresholdWall = 0.4;

% Unpack the segmentation parameters.
iLargestSeparationDueToLightAndMarkingPix = ...
  strctSegParams.iLargestSeparationDueToLightAndMarkingPix;
fLargeMotionThreshold = strctSegParams.fLargeMotionThreshold;
iSmallestMouseRadiusPix = strctSegParams.iSmallestMouseRadiusPix;
fMinimalMinorAxes = strctSegParams.aiAxisBounds(1);
fIntensityThrOut = strctSegParams.fIntensityThrOut;
fIntensityThrIn = strctSegParams.fIntensityThrIn;
iGoodCCopenSize = strctSegParams.iGoodCCopenSize;

% Parameters derived from those in strctSegParams.
iLargeComponent = ceil(pi*iSmallestMouseRadiusPix^2);

% Calculate the difference image.
a2fDiff = abs(a2fFrame-a2fBackground);
%figure; imagesc(a2fDiff); colormap(jet); colorbar;

% Blank the time-stamp and floor
if ~isempty(a2fTimeStampBB)
  a2fDiff(a2fTimeStampBB(2,1):a2fTimeStampBB(2,2), ...
          a2fTimeStampBB(1,1):a2fTimeStampBB(1,2)) = 0;
end
a2fDiff(~a2bFloor) = 0;

% Write to log.
fnLog('a2fDiff with time stamp removed', 3, a2fDiff);

% Make a boolean image of floor pels that are close to the walls.
a2fDistToWall = bwdist(~a2bFloor);
a2bFloorNearWall = (a2fDistToWall < 20) & a2bFloor;
  % the part of the floor that is near the wall

% Write to log.
fnLog('Constract 20 pixels wide strech of floor at the edge of the cage', ...
      3, a2bFloorNearWall);

% Make a boolean image of wall pels that are close to the floor.
a2fDistToFloor = bwdist(a2bFloor);
a2bWallNearFloor = (a2fDistToFloor < 100) & ~a2bFloor;
a2bWallNearFloor(1:30,:) = false;  % Why? --ALT
  % the part of the wall that is near the floor

% Write to log.
fnLog('Constract 100 pixels wide strech of wall at the edge of the cage', ...
      3, a2bWallNearFloor);

% Make a boolean image showing all pels where there is deviation from
% the background, with different thresholds and such in different places.
a2bDeviationWall = (a2fFrame<fLargeMotionRatioThresholdWall*a2fBackground) & ...
                   a2bWallNearFloor;
%figure; imagesc(a2bDeviationWall,[0 1]); colormap(gray); title('deviation wall');              
a2bDeviationInside = (a2fDiff>fLargeMotionThreshold) & ...
                     ~a2bFloorNearWall & ...
                     (a2fFrame<fIntensityThrIn);
  % Replace ~a2bFloorNearWall above with 
  %   (a2bFloor & ~a2bFloorNearWall) ? --ALT
%figure; imagesc(a2bDeviationInside,[0 1]); colormap(gray); title('deviation inside');              
a2bDeviationOutside = (a2fDiff>fLargeMotionThreshold) & ...
                      a2bFloorNearWall &  ...
                      (a2fFrame<fIntensityThrOut);
%figure; imagesc(a2bDeviationOutside,[0 1]); colormap(gray); title('deviation outside');              
a2bDeviation = a2bDeviationInside | a2bDeviationOutside | a2bDeviationWall;
%figure; imagesc(a2bDeviation,[0 1]); colormap(gray); title('motion');              

% Write to log.
fnLog('Binary image of all significant deviations', 3, a2bDeviation);

% Derive a boolean image of reliable foreground pixels by only keeping
% largish connected components.
a2iDeviationCC = bwlabel(a2bDeviation);
aiHist = fnLabelsHist(a2iDeviationCC);
aiNotJunk = find(aiHist(2:end)>30);
a2bReliable = fnSelectLabels(uint16(a2iDeviationCC),uint16(aiNotJunk))>0;

% Write to log.
fnLog('Binary image of all significant changes, excluding very small CCs (<=30 pixels)', ...
      3, a2bReliable);

% Close up holes in the reliable foreground image    
a2bReliableClosed = ...
  fnMyClose(a2bReliable, iLargestSeparationDueToLightAndMarkingPix);

% Write to log.
fnLog(['Closing holes up to ' ...
       num2str(iLargestSeparationDueToLightAndMarkingPix) ' wide'], ...
      3, a2bReliableClosed);

% Label connected components in a2bReliableClosed.
a2iReliableClosedCC = bwlabel(a2bReliableClosed);

% Calculate the area and minor axis length for each CC.
R=regionprops(a2iReliableClosedCC,'MinorAxisLength','Area');  %#ok

% Keep only foreground pels that are part of a big-enough CC
aiGoodCCs = find(cat(1,R.Area)>= iLargeComponent & ...
                 cat(1,R.MinorAxisLength) >=fMinimalMinorAxes );
a2bBigEnough=fnSelectLabels(uint16(a2iReliableClosedCC), ...
                            uint16(aiGoodCCs)) ...
             >0;

% Erode, keep only those components that are big enough by another 
% measure, and then dilate back up.
a2bBigEnoughEroded = fnMyErode(a2bBigEnough,iGoodCCopenSize);
a2iBigEnoughErodedCC = bwlabel(a2bBigEnoughEroded);
R=regionprops(a2iBigEnoughErodedCC,'Area');  %#ok
aiGoodCCs = find(cat(1,R.Area)>= fMinimalMinorAxes^2);
a2bBigEnoughEvenWhenEroded=fnSelectLabels(uint16(a2iBigEnoughErodedCC), ...
                                          uint16(aiGoodCCs)) ...
                   >0;
a2bForegroundFinal = fnMyDilate(a2bBigEnoughEvenWhenEroded,...
                      iGoodCCopenSize);

% Get rid of the timestamp (again? --ALT)
if ~isempty(a2fTimeStampBB)
  a2bForegroundFinal(a2fTimeStampBB(2,1):a2fTimeStampBB(2,2),...
                     a2fTimeStampBB(1,1):a2fTimeStampBB(1,2)) = 0;
end

% Do connected-components on the final foreground image                 
[a2iOnlyMouse,iNumBlobs] = bwlabel(a2bForegroundFinal);
a2iOnlyMouse =uint16(a2iOnlyMouse);

end




function a2iOutput=fnMyErode(a2iInput,fSize)
a2iOutput = bwdist(~a2iInput)>fSize;
end

function a2iOutput=fnMyDilate(a2iInput,fSize)
a2iOutput = bwdist(a2iInput)<fSize;
end

% function a2iOutput=fnMyOpen(a2iInput,fSize)
% a2iOutput = fnMyDilate(fnMyErode(a2iInput,fSize+0.0001),fSize+0.0001);
% end

function a2iOut=fnMyClose(a2iInput,fSize)
a2iOut = fnMyErode(fnMyDilate(a2iInput,fSize-0.0001),fSize-0.0001);
end



