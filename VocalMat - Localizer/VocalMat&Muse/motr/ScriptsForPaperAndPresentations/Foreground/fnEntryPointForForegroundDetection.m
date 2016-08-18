function fnEntryPointForForegroundDetection
load('D:\Code\Janelia Farm\DataForFigures\DataForForegroundDetection.mat');
% First frame of
% E:\JaneliaMovies\cage14\b6_pop_cage_14_12.02.10_09.52.04.882_cropped_2350-52350.seq
%
     g_strctGlobalParam.m_strctSetupParameters.m_fArenaWidthCM= 60;
     g_strctGlobalParam.m_strctSetupParameters.m_fArenaHeightCM= 60;
      g_strctGlobalParam.m_strctSetupParameters.m_afTimeStampX= [1 290];
      g_strctGlobalParam.m_strctSetupParameters.m_afTimeStampY= [1 24];

      

 strctSegParams = strctAdditionalInfo.strctBackground.m_strctSegParams;
    iLargestSeparationDueToLightAndMarkingPix = strctSegParams.iLargestSeparationDueToLightAndMarkingPix;
    fLargeMotionThreshold = strctSegParams.fLargeMotionThreshold;
    fLargeMotionRatioThresholdWall = 0.4;
    iSmallestMouseRadiusPix = strctSegParams.iSmallestMouseRadiusPix;
    fMinimalMinorAxes = strctSegParams.fMinimalMinorAxes;
    iLargeComponent = ceil(pi*iSmallestMouseRadiusPix^2);
    fIntensityThrOut = strctSegParams.fIntensityThrOut;
    fIntensityThrIn = strctSegParams.fIntensityThrIn;
    iGoodCCopenSize = strctSegParams.iGoodCCopenSize;
      
    a2fDiff = abs(a2fFrame-strctAdditionalInfo.strctBackground.m_a2iMedian);
    % Remove time stamp
    a2fDiff(g_strctGlobalParam.m_strctSetupParameters.m_afTimeStampY(1):g_strctGlobalParam.m_strctSetupParameters.m_afTimeStampY(2),...
        g_strctGlobalParam.m_strctSetupParameters.m_afTimeStampX(1):g_strctGlobalParam.m_strctSetupParameters.m_afTimeStampX(2)) = 0;
    a2fDiff(~strctAdditionalInfo.strctBackground.m_a2bFloor) = 0;
    fnLog('a2fDiff with time stamp removed', 3, a2fDiff);
    DistToFloor = bwdist(~strctAdditionalInfo.strctBackground.m_a2bFloor);
    a2bCloseToFloor = DistToFloor < 20 & strctAdditionalInfo.strctBackground.m_a2bFloor;
    fnLog('Constract 20 pixels wide strech of floor at the edge of the cage', 3, a2bCloseToFloor);
    global g_a2fDistToWall;
    if isempty(g_a2fDistToWall)
       g_a2fDistToWall = bwdist(strctAdditionalInfo.strctBackground.m_a2bFloor);
    end
    a2bCloseForWall = g_a2fDistToWall < 100 & ~strctAdditionalInfo.strctBackground.m_a2bFloor;
    a2bCloseForWall(1:30,:) = false;
    fnLog('Constract 100 pixels wide strech of wall at the edge of the cage', 3, a2bCloseForWall);
    a2bMotionWall = a2fFrame < fLargeMotionRatioThresholdWall*strctAdditionalInfo.strctBackground.m_a2iMedian & a2bCloseForWall;

    a2bMotionInside = a2fDiff > fLargeMotionThreshold & ~a2bCloseToFloor & a2fFrame < fIntensityThrIn;
    a2bMotionOutside = a2fDiff > fLargeMotionThreshold & a2bCloseToFloor &  a2fFrame < fIntensityThrOut;
    a2bMotion = a2bMotionInside | a2bMotionOutside | a2bMotionWall;
    fnLog('Binary image of all significant changes', 3, a2bMotion);
    a2iMotionCC = bwlabel(a2bMotion);
    aiHist = fnLabelsHist(a2iMotionCC);
    aiNotJunk = find(aiHist(2:end)>30);
    a2bReliable = fnSelectLabels(uint16(a2iMotionCC),uint16(aiNotJunk))>0;
    fnLog('Binary image of all significant changes, excluding very small CCs (<=30 pixels)', 3, a2bReliable);
    a2iReliable = fnMyClose(a2bReliable, iLargestSeparationDueToLightAndMarkingPix);
    fnLog(['Closing holes up to ' num2str(iLargestSeparationDueToLightAndMarkingPix) ' wide'], 3, a2iReliable);
    a2iL = bwlabel(a2iReliable);
    R=regionprops(a2iL,'MinorAxisLength','Area');
    
    aiGoodCCs = find(cat(1,R.Area)>= iLargeComponent & cat(1,R.MinorAxisLength) >=fMinimalMinorAxes );
    a2bI2 = fnMyErode(fnSelectLabels(uint16(a2iL), uint16(aiGoodCCs)) > 0, iGoodCCopenSize);
    a2iL2 = bwlabel(a2bI2);
    R2=regionprops(a2iL2,'Area');
    aiGoodCCs2 = find(cat(1,R2.Area)>= fMinimalMinorAxes^2);
    a2bI3 = fnMyDilate(fnSelectLabels(uint16(a2iL2), uint16(aiGoodCCs2)) > 0, iGoodCCopenSize);

    a2bI3(g_strctGlobalParam.m_strctSetupParameters.m_afTimeStampY(1):g_strctGlobalParam.m_strctSetupParameters.m_afTimeStampY(2),...
        g_strctGlobalParam.m_strctSetupParameters.m_afTimeStampX(1):g_strctGlobalParam.m_strctSetupParameters.m_afTimeStampX(2)) = 0;
    
    [a2iOnlyMouse,iNumBlobs] = bwlabel(a2bI3);
    a2iOnlyMouse =uint16(a2iOnlyMouse);
    
    
figure(1);clf;
imshow(a2fFrame,[]);
%axis([281 584 309 582]);      

figure(2);
clf;
imshow(a2fDiff,[]);
axis([281 584 309 582]);      
colormap hot
colorbar
set(gcf,'color',[1 1 1])

figure(3);
clf;
imshow(a2bMotion,[]);
axis([281 584 309 582]);      
set(gcf,'color',[1 1 1])

figure(4);
clf;
D=bwdist(a2bReliable);

imshow(D,[0 20]);
axis([281 584 309 582]);      
colormap hot
set(gcf,'color',[1 1 1])
colorbar

figure(5);
clf;
imshow(a2iReliable,[]);
axis([281 584 309 582]);      
set(gcf,'color',[1 1 1])


function a2iOutput=fnMyErode(a2iInput,fSize)
a2iOutput = bwdist(~a2iInput)>fSize;
function a2iOutput=fnMyDilate(a2iInput,fSize)
a2iOutput = bwdist(a2iInput)<fSize;
function a2iOutput=fnMyOpen(a2iInput,fSize)
a2iOutput = fnMyDilate(fnMyErode(a2iInput,fSize+0.0001),fSize+0.0001);
function a2iOut=fnMyClose(a2iInput,fSize)
a2iOut = fnMyErode(fnMyDilate(a2iInput,fSize-0.0001),fSize-0.0001);    