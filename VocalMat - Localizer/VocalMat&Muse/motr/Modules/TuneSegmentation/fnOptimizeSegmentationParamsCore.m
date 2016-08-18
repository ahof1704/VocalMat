function strctSegParams = ...
  fnOptimizeSegmentationParamsCore(strctSegParams0, ...
                                   a2fBackground, ...
                                   a2bFloor, ...
                                   a3iSampleFrames, ...
                                   a2strctEllipseGT, ...
                                   a2fTimeStampBB)

% Optimizes the segmentation parameters, based on ground-truth
% segmentations of a number of sample frames.
%
% strctSegParams0 contains the starting-point parameters to be optimized.
% a2fBackground contains the background image, with pels on [0,1].
% a2bFloor contains the floor mask.
% a3iSampleFrames contains the sample frames, one per page.  It is uint8.
% a2strctEllipseGT is a iNumMice x iNumFrames structure array, with 
%   fields:
%     m_fX
%     m_fY
%     m_fA
%     m_fB
%     m_fTheta
% a2strctEllipseGT contains the ground-truth ellipses for each of the
% sample frames.  Note that they are treated as undirected ellipses.
%
% a2fTimeStampBB is a 2x2 array holding the bounding box of the time stamp
% that is present in some movies, so that it can be ignored.  If the 
% corners are at (x1,y1) and (x2,y2), then a2fTimeStampBB==[x1 x2;y1 y2].
% It can also be empty, or omitted, if there's no timestamp in the frames.
%
% On return, strctSegParams contains the optimized segmentation parameters.
%
% Note that the only side-effects of this function involve writing to the
% console and the log, and neither it nor any of the functions it calls
% read any global variables or external files.

% Deal with args
if nargin<6
  a2fTimeStampBB=[];
end

% Compute the GT bitmaps for each frame                                 
[iH,iW]=size(a2fBackground);
a3bForegroundGT = fnGroundTruthEllipseToBinary(a2strctEllipseGT,iH,iW);
                                 
% Calculate some scale parameters from the GT ellipses.
[iSmallestMouseRadiusPix, aiAxisBounds] = fnCalcGeoBounds(a2strctEllipseGT);

% Modify strctSegParams0, adjusting based on GT-based scale parameters
strctSegParams0Mod=strctSegParams0;
fAMaxOld=strctSegParams0.aiAxisBounds(4);
fAMaxNew=aiAxisBounds(4);
strctSegParams0Mod.iGoodCCopenSize= ...
  round(strctSegParams0.iGoodCCopenSize*fAMaxNew/fAMaxOld);
clear iGoodCCopenSizeOld fAMaxOld fAMaxNew;
strctSegParams0Mod.iSmallestMouseRadiusPix = iSmallestMouseRadiusPix;
strctSegParams0Mod.aiAxisBounds = aiAxisBounds;
clear strctSegParams0;

% Get rid of the real-valued params we don't want to optimize.
% (Integral ones are eliminated later.)
acParamNames = fieldnames(strctSegParams0Mod);
acParamNames = setdiff(acParamNames, {'fMinimalMinorAxes'});

% Delete integral parameters from acParamNames, since we're not going to
% optimize them.
abIntegers = false(size(acParamNames));
for i=1:length(acParamNames)
   abIntegers(i) = acParamNames{i}(1)=='i' || ...
                   (acParamNames{i}(1)=='a' && acParamNames{i}(2)=='i');
end
acParamNames = acParamNames(~abIntegers);
clear abIntegers;

% Update the user, log.
fprintf('Start segmentation optimization\n');
fnLog('Start segmentation optimization');

% Do the optimization.
[strctSegParams, fSegError] = ...
  fnOptimizeFloatingParams(strctSegParams0Mod,a2fBackground,a2bFloor, ...
                           a3bForegroundGT,a3iSampleFrames,acParamNames, ...
                           a2fTimeStampBB);

% Update the user, log before exiting.                         
fnLog(sprintf('Finished segmentation optimization; fSegError=%f\n', fSegError));
fprintf('Finished segmentation optimization; fSegError=%f\n', fSegError);

end





function [iSmallestMouseRadiusPix, aiAxisBounds] = ...
  fnCalcGeoBounds(a2strctEllipse)

% Function to calculate certain scale parameters based on the 
% GT ellipses.  
%
% iSmallestMouseRadiusPix seems to be some measure of
% the smallest "radius" ellipse in the GT data, although there seem to
% be some fudge factors in there.
%
% afAxisBounds is 1x4, the elements being:
%   1: smallest semi-minor axis (b) in GT data, modulo fudge factor 
%   2: largest semi-minor axis (b) in GT data, modulo fudge factor 
%   1: smallest semi-major axis (a) in GT data, modulo fudge factor 
%   2: largest semi-major axis (a) in GT data, modulo fudge factor 

[iNumMice,iNumSamples] = size(a2strctEllipse);
iSmallestMouseRadiusPix = 10000;  % inf, effectively
afAxisBounds = [10000 0 10000 0];  % 10000 is effectively inf
for iSample=1:iNumSamples
  for iMouse=1:iNumMice
    strctEllipse = a2strctEllipse(iMouse,iSample);
    iSmallestMouseRadiusPix = ...
      min(iSmallestMouseRadiusPix, ...
          sqrt((strctEllipse.m_fA^2+strctEllipse.m_fB^2)/2));
    afAxisBounds(1) = min(afAxisBounds(1), strctEllipse.m_fB);
    afAxisBounds(2) = max(afAxisBounds(2), strctEllipse.m_fB);
    afAxisBounds(3) = min(afAxisBounds(3), strctEllipse.m_fA);
    afAxisBounds(4) = max(afAxisBounds(4), strctEllipse.m_fA);
  end
end
iSmallestMouseRadiusPix = floor(0.7*iSmallestMouseRadiusPix);
aiAxisBounds([1 3]) = floor(0.7*afAxisBounds([1 3]));
aiAxisBounds([2 4]) = ceil(1.25*afAxisBounds([2 4]));

end





function [strctSegParams, fSegError] = ...
  fnOptimizeFloatingParams(strctSegParams0,a2fMedian,a2bFloor, ...
                           a3bEllipses,a3iSampleFrames,acParamNames, ...
                           a2fTimeStampBB)

% Populate the initial parameters, x0, from strctSegParams0
iNumParams=length(acParamNames);
x0=zeros(1,iNumParams);
for i=1:length(acParamNames)
  x0(i) = getfield(strctSegParams0, acParamNames{i});  %#ok
end

% Optimize.  
optionSet = optimset('Display','iter', 'MaxFunEvals',9, 'TolX',5e-3);
%optionSet = optimset('Display','iter', 'MaxFunEvals',20, 'TolX',5e-3);
[x, fSegError] = fminsearch(@fnCalcSegError, x0, optionSet, ...
                            strctSegParams0, ...
                            a2fMedian, ...
                            a2bFloor, ...
                            a3iSampleFrames,...
                            acParamNames, ...
                            a3bEllipses, ...
                            a2fTimeStampBB);
   
% set strctSegParams based on strctSegParams0 with x "overlain"
strctSegParams=strctSegParams0;                          
for i=1:iNumParams
  strctSegParams = setfield(strctSegParams, acParamNames{i}, x(i));  %#ok
end

end




function fSegError = fnCalcSegError(x, ...
                                    strctSegParams0, ...
                                    a2fMedian, ...
                                    a2bFloor, ...
                                    a3iSampleFrames, ...
                                    acParamNames, ...
                                    a3bEllipses, ...
                                    a2fTimeStampBB)

% Get the baseline segmentation params, but replace some of them with the
% test values provided by the optimizer.
strctSegParams = strctSegParams0;
for i=1:length(acParamNames)
  strctSegParams = setfield(strctSegParams, acParamNames{i}, x(i));  %#ok
end

% For each sample frame, calculate the error w.r.t. the GT
iNumValidSamples = size(a3iSampleFrames,3);
afSegError = zeros(1,iNumValidSamples);
for iSample=1:iNumValidSamples
  %a2fFrame = fnReadFrameFromVideo(strctAdditionalInfo.strctMovieInfo, astrctGT(iSample).m_iFrame))/255;
  a2fFrame=double(a3iSampleFrames(:,:,iSample))/255;    
  %a2bOnlyMouse = fnSegmentForeground2(a2fFrame, strctAdditionalInfo)>0;
  a2iOnlyMouse = fnSegmentForeground3(a2fFrame, ...
                                      strctSegParams, ...
                                      a2fMedian, ...
                                      a2bFloor, ...
                                      a2fTimeStampBB);
  a2bOnlyMouse=(a2iOnlyMouse>0);
  %imagesc(a2bOnlyMouse,[0 1]); colormap(gray); drawnow;                                  
  a2bDiff = xor(a2bOnlyMouse, a3bEllipses(:,:,iSample));
  afSegError(iSample) = sum(a2bDiff(:));
end

% Summarize the error as RMSE.
fSegError = sqrt(mean(afSegError.^2));

end




function a3bEllipses = fnGroundTruthEllipseToBinary(a2strctEllipseGT,iH,iW)
% Returns a stack of boolean images that mark the foreground pixels for
% each of the ellipse sets in a2strctEllipseGT.  (Pels within any of the 
% ellipses are true, all other pels are false.)
%
% a2strctEllipseGT is a iNumEllipses x iNumFrames structure array, with 
% fields:
%   m_fX
%   m_fY
%   m_fA
%   m_fB
%   m_fTheta
%
% iH and iW give the dimensions of the returned frames.
%
% a3bEllipses, on return, is iH x iW x iNumFrames.

[iNumEllipses,iNumFrames] = size(a2strctEllipseGT);
N = 400;  % number of points used to represent ellipse border
afTheta = linspace(0,2*pi,N);

a3bEllipses = false(iH,iW,iNumFrames);
for j=1:iNumFrames
  for i=1:iNumEllipses
    e=a2strctEllipseGT(i,j);
    apt2f = [e.m_fA * cos(afTheta) ; ...
             e.m_fB * sin(afTheta)];
    R = [  cos(e.m_fTheta), sin(e.m_fTheta) ;
          -sin(e.m_fTheta), cos(e.m_fTheta) ];
    apt2iFinal = ...
      round(R*apt2f + repmat([e.m_fX;e.m_fY],1,N));
    a3bEllipses(:,:,j) = a3bEllipses(:,:,j) | ...
                         poly2mask(apt2iFinal(1,:),apt2iFinal(2,:),iH,iW);
  end
end

end


