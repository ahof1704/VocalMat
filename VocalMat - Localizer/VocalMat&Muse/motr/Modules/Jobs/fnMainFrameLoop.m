function [astrctTrackersJob,afProcessingTime,aiRandIndex,a2bLostMice] = ...
  fnMainFrameLoop(strctJob, iLocalMachineBufferSizeInFrames)

% The fundamental function that does multi-mouse tracking on a single
% 'job': one interval of a single clip, under a single hypothesis about the
% mouse->blob mapping.
%
% Inputs:
%   strctJob: A structure containing a bunch of information about the job.
%   It has fields:   
%     m_sFunction: A string, which should be 'fnMainFrameLoop' when
%       this function is called.
%     m_strMovieFileName: The absolute path to the clip file.
%     m_aiFrameInterval: 1 x iNumFrames, the frame numbers of the frames in
%       this job.  Should be consequtive, and either
%       strictly increasing or decreasing.
%     m_strctBootstrap: A scalar scruct containing the hypothesis,
%       essentially.  Has fields:
%       m_iNumMice: The number of mice in the clip.
%       m_astrctEllipse: A 1 x iNumMice structure array with the fields 
%         below, each containing a scalar.  Together, the five fields
%         define a single directed ellipse for each mouse.  Fields:
%         m_fX
%         m_fY
%         m_fA
%         m_fB
%         m_fTheta
%       m_a2iBackground: The background image, each pel a uint8.
%     m_strAdditionalInfoFile: The absolute path of a file, usually named
%       'Setup.mat', which contains 'additional info'.  This includes the
%       classifiers and the appearance feature vectors.
%     m_strOutputFile: The absolute path of a file, usually named
%       'JobOut<n>.mat', to which the output for this job will be written.
%     m_iUID: A scalar which is some sort of unique job identifier.
%     m_bLearnIdentity: A boolean scalar, not sure what it does.
%     m_strctMovieInfo: A scalar struct containing a "file pointer" to the
%       input clip, including an absolute path and an index of the frames.
%   iLocalMachineBufferSizeInFrames: A scalar giving the number of frames
%     to be read from disk at a time during processing.
%
% Outputs:
%   astrctTrackersJob: A 1 x iNumMice struct array with fields:
%     m_afX: 1 x iNumFrames, together with the next four defines a
%       directed ellipse for each frame.
%     m_afY: 1 x iNumFrames
%     m_afA: 1 x iNumFrames
%     m_afB: 1 x iNumFrames
%     m_afTheta: 1 x iNumFrames
%     m_a2fClassifer: iNumFrames x iNumMice, ID classifier output for each
%       frame, for each of the iNumMice identity classifiers.  (I
%       think---the numbers seem very small, and why do you need one of
%       these for each mouse (there are iNumFrames x iNumMice^2 scalars
%       total.))
%     m_afHeadTail: 1 x iNumFrames, head-tail classifier output for each
%                   frame.
%   afProcessingTime: 1 x iNumFrames, the number of seconds of CPU time
%     (not wall time) to process each frame.  (N.B.: The time to process
%     the key frame is always given as zero.)
%   aiRandIndex: 1 x iNumFrames, the index into Shay's random number buffer
%     for each frame.  I think this ensures that the run could be re-run 
%     exactly the same, for debugging purposes, etc.

% Initialize first frame using bootstrap
[strctAdditionalInfo, iStartFrame, iEndFrame, aiIntervalFrames, ...
 a3iFrames, aiBufferFrames, astrctTrackersJob] = ...
    fnMainLoopInit(strctJob, iLocalMachineBufferSizeInFrames);

% Initialize arrays that store things calculated on each iter.
iNumIntervalFrames=length(aiIntervalFrames);
afProcessingTime = zeros(1, iNumIntervalFrames);
aiRandIndex = zeros(1, iNumIntervalFrames);
  % Note that the first element of each of these (corresponding to the
  % key frame) is never set, and is essentially meaningless.  Consider
  % setting to NaN, but not yet.  --ALT, 2012-03-27
  
% Set the weight used for updating the background image at each iter.
fUpdateWeight = 1/30;

% Main Loop, processing one frame per iteration.
iNumMice=length(astrctTrackersJob);
abLostMice=false(1,iNumMice);
a2bLostMice=false(iNumIntervalFrames,iNumMice);
a2bLostMice(1,:)=abLostMice;
for iOutputIndex=2:iNumIntervalFrames  % start at 2 to skip key frame
    % Set up the various indices for this iteration.
    iCurrFrame=aiIntervalFrames(iOutputIndex);
    aiHistoryIndices=1:(iOutputIndex-1);
    if iEndFrame >= iStartFrame
        % This clip is being processed in order
        iBuffIndex = iCurrFrame-aiBufferFrames(1)+1;
    else
        % This clip is being processed in reverse
        iBuffIndex = aiBufferFrames(1)-iCurrFrame+1;
    end;
 
    % At this point:
    %   iCurrFrame is the absolute frame index within the clip (one-based)
    %   iOutputIndex is the frame index within the job (one-based)
    %   iBuffIndex is the frame index within the frame buffer (one-based)
    %   aiHistoryIndices is a list of the frame indices within the job
    %     that we've already done.
        
    % Get the frame out of the frame buffer.
    a2iFrame=a3iFrames(:,:,iBuffIndex);
    
    % Record the current index into the random-number buffer, so that
    % we can reproduce behavior exactly, if needed.
    aiRandIndex(iOutputIndex) = fnMyRandNBufferIndex();
    
    % Extract just the direllipses from astrctTrackerJob, and only
    % for frames we've already processed.
    astrctTrackersHistory = fnPrepareHistory(aiHistoryIndices,astrctTrackersJob);
    
    % Start the timer for the frame processing.  (Why not use tic & toc?)
    fStartTime=cputime();
    
    % Process the current frame.  Direllipses for this frame are returned
    % in strctFrameOuput.
    [strctFrameOutput, astrctTrackersJob, abLostMice] =...
        fnJobProcessFrame(astrctTrackersHistory,...
                          a2iFrame, ...
                          strctAdditionalInfo, ...
                          astrctTrackersJob, ...
                          abLostMice, ...
                          iOutputIndex);
    a2bLostMice(iOutputIndex,:) = abLostMice;    
    
    % Update background
    strctAdditionalInfo.strctBackground.m_a2fMedian = ...
      fnUpdateBackground(a2iFrame, ...
                         strctAdditionalInfo.strctBackground.m_a2fMedian, ...
                         strctFrameOutput, ...
                         fUpdateWeight);
    
    % Add the direllipses for the current frame to astrctTrackersJob at
    % index iOutputIndex.
    astrctTrackersJob=fnUpdateOutput(iOutputIndex, strctFrameOutput, astrctTrackersJob);
    
    % Get the patch images for all the mice.
    %a3iRectified  = fnCollectRectifiedMice2(a2iFrame, astrctTrackersJob, iOutputIndex);
    a3iRectified  = fnCollectRectifiedMice3(a2iFrame, strctFrameOutput);
    
    % Add the classifier information to astrctTrackersJob.
    astrctTrackersJob=fnAddClassifiersInfo(a3iRectified, strctAdditionalInfo,iOutputIndex, astrctTrackersJob);
    
    % Record the time to process this frame
    afProcessingTime(iOutputIndex) = cputime()-fStartTime;

    % Estimate the time left, write to console.
    iNumFramesLeft = iNumIntervalFrames - iOutputIndex + 1;
    fApproxTimetoFinish = iNumFramesLeft*mean(afProcessingTime(2:iOutputIndex)) / 60;  % min
    fprintf('Processing time for frame %d: %.2f.  Approx time to finish job: %.2f (min) (%d frames)\n',...
        iCurrFrame, afProcessingTime(iOutputIndex),fApproxTimetoFinish,iNumFramesLeft );
      
    % Get new frames from disk, if needed.  
    [a3iFrames,aiBufferFrames] = ...
      fnUpdateFrameBuffer(iCurrFrame, ...
                          iStartFrame, ...
                          iEndFrame, ...
                          a3iFrames, ...
                          aiBufferFrames, ...
                          strctJob, ...
                          iLocalMachineBufferSizeInFrames);  
end;  % main loop

% Invoke the Viterbi algorithm to rotate by 180 degrees any registered
% patches that need it.
bFlipDir = strctJob.m_aiFrameInterval(end) < strctJob.m_aiFrameInterval(1);
astrctTrackersJob = ...
  fnJobCorrectOrientationWithViterbi(astrctTrackersJob, ...
                                     strctAdditionalInfo, ...
                                     bFlipDir);
                                   
return;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



function [strctAdditionalInfo, ...
          iStartFrame, ...
          iEndFrame, ...
          aiIntervalFrames, ...
          a3iFrames, ...
          aiBufferFrames, ...
          astrctTrackersJob] = ...
    fnMainLoopInit(strctJob, iLocalMachineBufferSizeInFrames)

% Loads the background image, classifiers, appearance vectors, and a few
% other things from disk, returns then in strctAdditionalInfo.  Also
% returns the indices of frames to be processed in this job, the initial
% frame buffer, and a pre-allocated astrctTrackersJob, the variable that 
% will hold the tracker direllipses for the interval, with the direllipses
% for the key frame filled in, and everything else zeroed-out.
%
% Inputs: Same as for fnMainFrameLoop(), see above.
%
% Outputs:
%   strctAdditionalInfo: A scalar scruct containing the background image,
%     the classifiers, the appearance feature vectors, and a few other
%     things.  Fields:
%     strctBackground: A scalar struct containing information about the 
%       background image.  Fields:
%         m_strctSegParams: A scalar struct containing parameters to be used
%           for doing foreground segmentation.  Fields:
%           iLargestSeparationDueToLightAndMarkingPix
%           fLargeMotionThreshold
%           iSmallestMouseRadiusPix
%           fMinimalMinorAxes
%           fIntensityThrOut
%           fIntensityThrIn
%           iGoodCCopenSize
%           aiAxisBounds
%         m_a2fMedian: A double image with pels on [0,1], containing the
%           background image.
%         m_a2bFloor: A boolean image, true for floor pels.
%         m_astrctTuningEllipses: A row struct containing the ground-truth
%           data for training the foreground segmenter.  Each element 
%           corresponds to an example frame used for training.  Fields:
%             m_iFrame: The frame index.
%             m_bValid: Whether the frame is valid.
%             m_astrctEllipse: A 1 x iNumMice array, with each element a 
%               direllipse structure (m_fX,m_fY,m_fA,m_fB,m_fTheta).
%         m_strMethod: The method to use for doing foreground segmentation.  
%           Usually 'FrameDiff_v7' these days (2012-03-28).
%     strctAppearance: A scalar struct holding appearance feauture vectors.
%       Fields:
%         m_iNumBins: The number of bins used when computing HOG vectors.
%         m_a2fFeatures: single-precision array, with HOG appearance features
%           in the cols.
%     m_a3fRepresentativeClassImages: Stack of images, each a representative
%       image patch of one of the mice.  iHPatch x iHPatch x iNumMice, with
%       pels on [0,1].
%     m_strctHeadTailClassifier: Scalar struct containing the head-tail
%       classifier.  Contains the usual classifier fields (m_afMean, 
%       m_afLDA, m_fMu, m_fSigma, m_fNu), plus the fields iNumBins, the 
%       number of bins used for the HOG features.
%     m_strctMiceIdentityClassifier: Scalar struct.  Fields:
%       m_astrctClassifiers: 1 x iNumMice struct array, with the usual
%         classifier fields.
%       m_astrctClassifiersNegClass: 1 x iNumMice struct array, with the 
%         usual classifier fields.
%       m_a3fRepImages: Stack of representative patch images, one per
%         mouse.  iHPatch x iWPatch x iNumMice double, with pels on [0,1].
%       iNumBins: Number of bins used when calculating HOG vectors.
%   iStartFrame: Index of the first frame to be processed.  (First in the
%     processing order.)
%   iEndFrame: Index of the last frame to be processed.  (Last in the
%     processing order.)  Note that sometimes iEndFrame<iStartFrame, as when
%     a clip interval is to be processes in reverse order.
%   aiIntervalFrames: Indices of all frames to be processed, in the order
%     they will be processed.  iStartFrame==aiIntervalFrames(1), and 
%     iEndFrame==aiIntervalFrames(end).  Also, all(diff(aiIntervalFrames)==1)
%     or all(diff(aiIntervalFrames)==-1).
%   a3iFrames: The initial frame buffer, with frames in the pages.  
%     iHFrame x iWFrame x iNumBufferFrames, uint8.
%   aiBufferFrames: The index in the clip of each frame in the buffer, 
%      1 x iNumBufferFrames.
%   astrctTrackersJobs: 1 x iNumMice struct array.  Each element contains
%     pre-allocated arrays intended to store the tracker
%     directed ellipses for each frame, with associated classifier
%     outputs.  Fields:
%       m_afX: 1 x iNumIntervalFrames
%       m_afY: 1 x iNumIntervalFrames
%       m_afA: 1 x iNumIntervalFrames
%       m_afB: 1 x iNumIntervalFrames
%       m_afTheta: 1 x iNumIntervalFrames
%       m_a2fClassifer: iNumIntervalFrames x iNumMice
%       m_afHeadTail: 1 x iNumIntervalFrames
%       m_a2fClassiferFlip: iNumIntervalFrames x iNumMice
%       m_afHeadTailFlip: 1 x iNumIntervalFrames
%       These fields are same as for the astrctTrackersJob returned from
%       fnMainFrameLoop(), except for the two "flipped" ones.  These ones
%       hold the output of the named classifier(s), evaluated on the
%       flipped patch image for that mouse, for that frame.
  
% Get the number of mice to be tracked out of strctJob.
iNumMice = strctJob.m_strctBootstrap.m_iNumMice;

% Load the file that contains the backround image, the floor mask,
% the classifiers, etc.
if ~exist(strctJob.m_strAdditionalInfoFile,'file')
    error('Critical Error. Can not find additional information file at %s\n',strctJob.m_strAdditionalInfoFile);
end;
strctTmp = load(strctJob.m_strAdditionalInfoFile);
strctAdditionalInfo = strctTmp.strctAdditionalInfo;
clear strctTemp

% Unpack the first and last frames to be tracked in this job.
iStartFrame = strctJob.m_aiFrameInterval(1);
iEndFrame = strctJob.m_aiFrameInterval(end);

% Make sure the clip file actually exists.
if ~exist(strctJob.m_strctMovieInfo.m_strFileName,'file')
    error('Critical Error. Can not find movie file at %s\n',strctJob.m_strctMovieInfo);
end;

% Enumerate all the frames to be processed in this job, including the 
% key frame.
% If frame 1 is unreliable, iStartFrame will be greater than iEndFrame.
if iEndFrame >= iStartFrame
    % The usual case---the first frame is the bootstrap frame.
    aiIntervalFrames =  iStartFrame:iEndFrame;
else
    % If frame 1 is unreliable, this additional flipped job will be sent. 
    aiIntervalFrames = iStartFrame:-1:iEndFrame;
end;

% Fill buffer with initial iLocalMachineBufferSizeInFrames frames. 
[a3iFrames,aiBufferFrames] = ...
  fnFillBufferFromFrame(strctJob.m_strctMovieInfo,...
                        iStartFrame, ...
                        iEndFrame, ...
                        iLocalMachineBufferSizeInFrames);

% Pre-allocate astrctTrackersJob.
iNumFrames = length(aiIntervalFrames);  
iNumClassifiers = iNumMice; %size(strctAdditionalInfo.m_strctMiceIdentityClassifier.a2fW,2);
afNaN = zeros(1,iNumFrames);
a2fNaN = zeros(iNumFrames, iNumClassifiers);
astrctTrackersJob=struct('m_afX',cell(1,iNumMice),...
                         'm_afY',cell(1,iNumMice),...
                         'm_afA',cell(1,iNumMice),...
                         'm_afB',cell(1,iNumMice),...
                         'm_afTheta',cell(1,iNumMice),...
                         'm_a2fClassifer',cell(1,iNumMice),...
                         'm_afHeadTail',cell(1,iNumMice),...
                         'm_a2fClassiferFlip',cell(1,iNumMice),...  % sic
                         'm_afHeadTailFlip',cell(1,iNumMice));
for k=1:iNumMice
    astrctTrackersJob(k).m_afX = afNaN;
    astrctTrackersJob(k).m_afY = afNaN;
    astrctTrackersJob(k).m_afA = afNaN;
    astrctTrackersJob(k).m_afB = afNaN;
    astrctTrackersJob(k).m_afTheta = afNaN;
    astrctTrackersJob(k).m_a2fClassifer = a2fNaN;
    astrctTrackersJob(k).m_afHeadTail = afNaN;
    % These will be removed at the end of the job
    astrctTrackersJob(k).m_a2fClassiferFlip = a2fNaN;
    astrctTrackersJob(k).m_afHeadTailFlip = afNaN;
end;

% Add the key frame trackers to astrctTrackersJob
for iMouseIter=1:iNumMice
    astrctTrackersJob(iMouseIter).m_afX(1) = strctJob.m_strctBootstrap.m_astrctEllipse(iMouseIter).m_fX;
    astrctTrackersJob(iMouseIter).m_afY(1) = strctJob.m_strctBootstrap.m_astrctEllipse(iMouseIter).m_fY;
    astrctTrackersJob(iMouseIter).m_afA(1) = strctJob.m_strctBootstrap.m_astrctEllipse(iMouseIter).m_fA;
    astrctTrackersJob(iMouseIter).m_afB(1) = strctJob.m_strctBootstrap.m_astrctEllipse(iMouseIter).m_fB;
    astrctTrackersJob(iMouseIter).m_afTheta(1) = strctJob.m_strctBootstrap.m_astrctEllipse(iMouseIter).m_fTheta;
end;
a3iRectified = fnCollectRectifiedMice2(a3iFrames(:,:,1), astrctTrackersJob, 1);

% Add the classifier output to the key frame elements of astrstTrackersJob.
astrctTrackersJob=fnAddClassifierInfoTdist(a3iRectified, strctAdditionalInfo,1, astrctTrackersJob);

% If the job structure contains a background image, use that instead of
% whatever might have been in the additional info file.
if isfield(strctJob.m_strctBootstrap,'m_a2iBackground') && ~isempty(strctJob.m_strctBootstrap.m_a2iBackground)
    strctAdditionalInfo.strctBackground.m_a2fMedian = double(strctJob.m_strctBootstrap.m_a2iBackground)/255;
end

return;



