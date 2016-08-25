function  [a2fHOGFeatures,a2fHOGFeaturesFlipped,a3iPatches, ...
           afX,afY,afA,afB,afTheta]= ...
  fnHOGFeaturesFromSMClip(strctInputFile,a2bMask,a2fBackground)

% Calculates HOG feature vectors for each frame in the single-mouse movie 
% pointed to by strctInputFile.  The mask contained in a2bMask is true for
% floor pels, false for wall and other pels.  a2fBackground contains the
% background image, with pels on [0,1].
% On return:
%   a2fHOGFeatures contains a HOG feature vector for each frame, with
%                  feature vectors in the _rows_.
%   a2fHOGFeaturesFlipped is similar to a2fHOGFeatures, but contains
%                         HOG vectors calculated from the a 180-degree
%                         rotated version of the registered mouse image.
%   a3iPatches contains the registered mouse images for each frame, one
%              per page.  If things are working right, these will be
%              head-to-the-right.
%   afX, afY, afA, afB, afTheta contain the mouse ellipse parameters, one
%                               per frame.  These are in image coordinates.
%                               If everything is working right, these 
%                               should be directed ellipses, with the theta
%                               hat vector pointing tail-to-head.

global g_bVERBOSE

% Unpack all the global vars we'll need
global g_strctGlobalParam
fDevianceThreshold = ...
  g_strctGlobalParam.m_strctSingleMouseIdentityTracker.m_fMotionThreshold/255;
% m_fMotionThreshold is not a motion threshold, it's a difference
% threshold, and it assumes the pixels being compared are uint8.
% In this function we compare double images with pels on [0,1].
iNumHOGBins = g_strctGlobalParam.m_strctClassifiers.m_fNumHOGBins;
fImagePatchHeight=g_strctGlobalParam.m_strctClassifiers.m_fImagePatchHeight;
fImagePatchWidth=g_strctGlobalParam.m_strctClassifiers.m_fImagePatchWidth;
afTimeStampY=g_strctGlobalParam.m_strctSetupParameters.m_afTimeStampY;
afTimeStampX=g_strctGlobalParam.m_strctSetupParameters.m_afTimeStampX;
fHeadTailHighVelocityPixels= ...
  g_strctGlobalParam.m_strctSingleMouseIdentityTracker.m_fHeadTailHighVelocityPixels;
  % pels per frame interval
clear g_strctGlobalParam

% Call fnHOGfeatures() on a dummy input, to figure out how long a feature
% vector is.
a2iDummy=zeros(fImagePatchHeight,fImagePatchWidth,'uint8');
afHOGDummy = fnHOGfeatures(a2iDummy, iNumHOGBins);
iNumHOGFeatures = numel(afHOGDummy);

% Dimension the return variables.
iNumFrames=strctInputFile.m_iNumFrames;
a2fHOGFeatures = zeros(iNumFrames, iNumHOGFeatures,'single');
a2fHOGFeaturesFlipped = zeros(iNumFrames, iNumHOGFeatures,'single');
a3iPatches = zeros(fImagePatchHeight,fImagePatchWidth,iNumFrames,'uint8');
afX = zeros(1,iNumFrames);
afY = zeros(1,iNumFrames);
afA = zeros(1,iNumFrames);
afB = zeros(1,iNumFrames);
afTheta = zeros(1,iNumFrames);

%
% Segment each frame and fit an ellipse to the foreground pels.
%
abValidFrame = false(1,iNumFrames);  
for iFrameIter=1:iNumFrames
  % Produce a progress report to the console
  bSampleFrame = mod(iFrameIter,100) == 0;
  if bSampleFrame
    fprintf('Passed frame %d out of %d (%.2f %%) \n', ...
            iFrameIter,iNumFrames, iFrameIter/iNumFrames*1e2);
  end
  
  % Calculate the foreground mask for the frame
  a2iFrame = fnReadFrameFromVideo(strctInputFile, iFrameIter);
  a2fFrame=double(a2iFrame)/255;
  a2fDiff=a2fFrame-a2fBackground;
  a2bLargeDiffComparedToBack = abs(a2fDiff) > fDevianceThreshold;
  a2bDeviant =(a2bLargeDiffComparedToBack & a2bMask);
  a2bDeviant(afTimeStampY(1):afTimeStampY(2),...
             afTimeStampX(1):afTimeStampX(2)) = false; % Remove timestamp
  a2bForeground = imclose(a2bDeviant, ones(10));
  
  % How many pels in largest FG connected component?
  a2iLabeled = bwlabel(a2bForeground);
  aiHist = fnLabelsHist(a2iLabeled);
  [fDummy, iMaxIndex] = max(aiHist(2:end));  %#ok
  
  % If no foreground pels, leave abValidFrame(iFrameIter) as false, and
  % go on to the next frame
  if isempty(iMaxIndex)
    continue;
  end
  % If we get here, mark the frame as valid
  abValidFrame(iFrameIter) = true;
  
  % Fit an ellipse to the FG pels
  [aiY,aiX] = find(a2iLabeled == iMaxIndex);
  [afMu, a2fCov]=fnFitGaussian([aiX,aiY]);
  strctEllipse = fnCov2EllipseStrct(afMu,a2fCov);
  
  % Make a figure if we're in verbose mode.
  if ~isempty(g_bVERBOSE) && g_bVERBOSE || (bSampleFrame && fnGetLogMode(1))
    hFigure = figure(10);
    if ~g_bVERBOSE, set(hFigure, 'visible', 'off'); end;
    clf;
    imshow(a2iFrame,[]);
    hold on;
    fnPlotEllipse(strctEllipse.m_afX,strctEllipse.m_afY,strctEllipse.m_afA,strctEllipse.m_afB,strctEllipse.m_afTheta,[0 1 1], 2);
    title(num2str(iFrameIter));
    strctFrame = getframe(hFigure);
    if ~g_bVERBOSE, set(hFigure, 'visible', 'off'); end;
    fnLog(sprintf('Passed frame %d out of %d (%.2f %%)',iFrameIter,iNumFrames, iFrameIter/iNumFrames*1e2), 2, strctFrame.cdata);
  end;
  
  % Unpack the ellipse params and store them.
  afX(iFrameIter) = strctEllipse.m_afX;
  afY(iFrameIter) = strctEllipse.m_afY;
  afA(iFrameIter) = strctEllipse.m_afA;
  afB(iFrameIter) = strctEllipse.m_afB;
  afTheta(iFrameIter) = strctEllipse.m_afTheta;
  
  % Save the registered image patch.  (Note that whether it's head-right or
  % head-left is basically random at this point.)
  a2iPatch = ...
    fnRectifyPatchUint8(a2iFrame, ...
                        strctEllipse.m_afX, ...
                        strctEllipse.m_afY, ...
                        strctEllipse.m_afTheta);  % uint8
  a3iPatches(:,:,iFrameIter) = a2iPatch;
                 
  % Calculate HOG features                 
  a2fHOGFeaturesTemp = fnHOGfeatures(a2iPatch, iNumHOGBins);
  a2fHOGFeatures(iFrameIter,:) = a2fHOGFeaturesTemp(:)';
  
  % Calculate HOG features on patch rotated by 180 degrees
  a2iPatchFlipped=rot90(a2iPatch,2);
  a3fHOGFeaturesFlipped = fnHOGfeatures(a2iPatchFlipped, iNumHOGBins);
  a2fHOGFeaturesFlipped(iFrameIter,:) = a3fHOGFeaturesFlipped(:)';
end

%
% Interpolate missing frames
%
astrctMissingIntervals = fnGetIntervals(~abValidFrame);
for iIter=1:length(astrctMissingIntervals)
  % If this interval abuts the start or end, can't interpolate
  if astrctMissingIntervals(iIter).m_iStart == 1 || ...
     astrctMissingIntervals(iIter).m_iEnd == iNumFrames
    continue;
  end
  % Get the frame indices for this interval
  aiFrames = ...
    (astrctMissingIntervals(iIter).m_iStart-1: ...
     astrctMissingIntervals(iIter).m_iEnd+1);
  % Write to the log. 
  fnLog(sprintf('interpolating missing frames interval %d - %d', ...
                aiFrames(1), ...
                aiFrames(end)));
  % Linearly interpolate the ellipse parameters.            
  afX(aiFrames) = linspace(afX(aiFrames(1)), ...
                           afX(aiFrames(end)), ...
                           length(aiFrames));
  afY(aiFrames) = linspace(afY(aiFrames(1)), ...
                           afY(aiFrames(end)), ...
                           length(aiFrames));
  afA(aiFrames) = linspace(afA(aiFrames(1)), ...
                           afA(aiFrames(end)), ...
                           length(aiFrames));
  afB(aiFrames) = linspace(afB(aiFrames(1)), ...
                           afB(aiFrames(end)), ...
                           length(aiFrames));
  afTheta(aiFrames) = fnInterpolateAngle(afTheta(aiFrames(1)), ...
                                         afTheta(aiFrames(end)), ...
                                         length(aiFrames));
  % For each frame in this interval, use the interpolated direllipse to
  % extract a patch and calculate HOG features.
  % Note: Wouldn't it be simpler to get the direllipses for the valid
  % frames, then interpolate the ellipses, then get the HOG features for
  % _all_ frame, both "valid" and interpolated?  --ALT, 2012/03/19
  for iFrameIter=aiFrames(2:end-1)
    a2iFrame = fnReadFrameFromVideo(strctInputFile, iFrameIter);
    a2iPatch=fnRectifyPatchUint8(a2iFrame, ...
                                 afX(iFrameIter), afY(iFrameIter), ...
                                 afTheta(iFrameIter));
    a3iPatches(:,:,iFrameIter) = a2iPatch;
    a2fHOGFeaturesTemp = fnHOGfeatures(a2iPatch,iNumHOGBins);
    a2fHOGFeatures(iFrameIter,:) = a2fHOGFeaturesTemp(:)';
    a2iPatchFlipped=rot90(a2iPatch,2);
    a2fHOGFeaturesTemp = fnHOGfeatures(a2iPatchFlipped, iNumHOGBins);
    a2fHOGFeaturesFlipped(iFrameIter,:) = a2fHOGFeaturesTemp(:)';
  end
end

%
% Make all the registered images head-right.
%

% Update the user & log
fprintf('Solving head-tail problem...');
fnLog('Solve the head-tail problem\nFind reliable frames with high velocity');

% Find frames with high velocity.
afDx = [0 diff(afX)];
afDy = [0 diff(afY)];
afVelPix = hypot(afDx,afDy);  % pels/frame
abHighVelocity = (afVelPix > fHeadTailHighVelocityPixels);

% Identify frames with low rotational velocity (wrap-around theta)
fRotationalVelocityThreshold = 4 / 180*pi;
T = afTheta;
T(T>pi) = T(T>pi)-pi;
dT = diff(T);
dT(dT > pi/2) = dT(dT > pi/2) - pi;
dT(dT < -pi/2) = dT(dT < -pi/2) + pi;
abLowRotationalVelocity = [false (abs(dT) < fRotationalVelocityThreshold)];
% Erode a bit. 
abLowRotationalVelocity(2:end-1) = ...
  min(abLowRotationalVelocity(1:end-2),abLowRotationalVelocity(3:end));

% "Reliable" frames are ones where the velocity vector very likely points
% to the head.
abReliableFrames = abLowRotationalVelocity & abHighVelocity;

% Write to the log.
fnLog(sprintf('Found %d reliable frames',sum(abReliableFrames)));

% If there are no reliable frames, throw an exception.
iNumReliableFrames=sum(abReliableFrames);
if iNumReliableFrames==0 ,
%   excp=MException('fnHOGFeaturesFromSMClip:noReliableFrames', ...
%                   'No reliable frames at all in %s!', ...
%                   strctInputFile.m_strFileName);
%   throw(excp);              
  error('fnHOGFeaturesFromSMClip:noReliableFrames', ...
        'No reliable frames at all in %s!', ...
        strctInputFile.m_strFileName);
end

% Identify "problematic" frames, ones marked as reliable but where theta hat 
% and the center velocity vector are more than 90 degrees different (i.e. 
% they have a negative dot product.)
a2fThetaHat = [cos(afTheta); -sin(afTheta)];  % theta's hat vector
a2fDirectionMotion = [afDx; afDy] ./ repmat(afVelPix,[2 1]);  
  % hat vector of center velocity
% afAngleDiff = acos(a2fThetaHat(1,:) .* a2fDirectionMotion(1,:) +  ...
%                    a2fThetaHat(2,:) .* a2fDirectionMotion(2,:))/pi*180;
% aiNeedSwap = find(afAngleDiff > 90 & abReliableFrames);
afDotProduct=sum(a2fThetaHat.*a2fDirectionMotion,1);
aiNeedSwap = find(afDotProduct<0 & abReliableFrames);

% Flip problematic frames, so that theta hat will now have a positive dot
% product with the velocity vector.
afTheta(aiNeedSwap) = afTheta(aiNeedSwap) + pi;
%a3iPatches(:,:,aiNeedSwap) = a3iPatches(end:-1:1,end:-1:1,aiNeedSwap);
for i=aiNeedSwap
  a3iPatches(:,:,i) = rot90(a3iPatches(:,:,i),2);
end
a2fHOGFeaturesTemp = a2fHOGFeatures(aiNeedSwap,:);
a2fHOGFeatures(aiNeedSwap,:) = a2fHOGFeaturesFlipped(aiNeedSwap,:);
a2fHOGFeaturesFlipped(aiNeedSwap,:) = a2fHOGFeaturesTemp;

% Extract the HOG vectors for the reliable frames
a2fDataPos = a2fHOGFeatures(abReliableFrames,:);
a2fDataNeg = a2fHOGFeaturesFlipped(abReliableFrames,:);

% Train a probablistic classifier on the exemplars.
strctClassifier = fnLDALogistic(a2fDataPos,a2fDataNeg);

% Using the classifier, calculate the probability that each frame
% is head-right.
afProbHead = fnApplyLDALogistic(strctClassifier,a2fHOGFeatures);

% Modify the probabilities to make things less 'certain'.
afProbHead = 0.8*afProbHead + 0.1;

% Not sure why this helps. --ALT, 2012/03/19
afProbHead(~abLowRotationalVelocity) = 0.5;

% Prepare stuff for viterbi
% calculate alpha, the angle of the center velocity vector per frame 
afAlpha = atan2(-afDy,afDx);  % will be on [-pi,+pi]

% Get rid of negative angles, b/c fnCorrectOrientation() assumes all
% angles are positive.
afAlpha(afAlpha < 0) = afAlpha(afAlpha<0)+2*pi;
afTheta(afTheta < 0) = afTheta(afTheta<0)+2*pi;

% Use the Viterbi algorithm to infer the true theta values, given the
% likely-messed-up ones.
afNewTheta = fnCorrectOrientation(afTheta,afAlpha,afVelPix,afProbHead);

% Find frames where the new theta and old one differ by more than 90
% degrees
%afDiffAngle = acos(  cos(afNewTheta) .* cos(afTheta) + ...
%                     sin(afNewTheta) .* sin(afTheta) )/pi*180;
%aiNeedSwap = find(afDiffAngle > 90);
a2fThetaHat = [cos(afTheta); -sin(afTheta)];  % theta's hat vector
a2fNewThetaHat=[cos(afNewTheta); -sin(afNewTheta)];
afDotProduct=sum(a2fThetaHat.*a2fNewThetaHat,1);
aiNeedSwap=find(afDotProduct<0);

% Flip frames that need flipping.
afTheta(aiNeedSwap) = afTheta(aiNeedSwap) + pi;
%a3iPatches(:,:,aiNeedSwap) = a3iPatches(end:-1:1,end:-1:1,aiNeedSwap);
for i=aiNeedSwap
  a3iPatches(:,:,i) = rot90(a3iPatches(:,:,i),2);
end
a2fHOGFeaturesTemp = a2fHOGFeatures(aiNeedSwap,:);
a2fHOGFeatures(aiNeedSwap,:) = a2fHOGFeaturesFlipped(aiNeedSwap,:);
a2fHOGFeaturesFlipped(aiNeedSwap,:) = a2fHOGFeaturesTemp;

% Update console.
fprintf('\nDone!\n');

% % Plot some frames and their direllipses, for debugging
% for iFrame = 1:10:iNumFrames
%   a2fI = fnReadFrameFromVideo(strctInputFile, iFrame);  
%   %afDirectionEllipseFit = [cos(afTheta(iFrame)), -sin(afTheta(iFrame))];
%   figure(5);
%   clf;
%   imshow(a2fI,[]);
%   title(num2str(iFrame));
%   hold on;
%   fnPlotEllipseWithTail(afX(iFrame),...
%                         afY(iFrame),...
%                         afA(iFrame),...
%                         afB(iFrame),...
%                         afTheta(iFrame),...
%                         [0 1 1], 2);
%   axis([afX(iFrame)-100, afX(iFrame)+100, ...
%         afY(iFrame)-100, afY(iFrame)+100])
%   drawnow
% end

end
