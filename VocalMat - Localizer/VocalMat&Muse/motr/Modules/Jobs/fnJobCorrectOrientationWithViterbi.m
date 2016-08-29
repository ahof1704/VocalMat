function astrctTrackersJob = fnJobCorrectOrientationWithViterbi(astrctTrackersJob,...
    strctAdditionalInfo, bFlipDir)
% First, compute HOG features for orientation.
% Then, solve orientation using Viterbi
% Then, apply identity classifiers.
global g_strctGlobalParam

%%
iNumMice = length(astrctTrackersJob);
if bFlipDir % Job was run in reversed mode (since 1st frame of video was not a key frame)
    for k=1:iNumMice
        astrctTrackersJob(k).m_afX = fliplr(astrctTrackersJob(k).m_afX);
        astrctTrackersJob(k).m_afY = fliplr(astrctTrackersJob(k).m_afY);
        astrctTrackersJob(k).m_afA = fliplr(astrctTrackersJob(k).m_afA);
        astrctTrackersJob(k).m_afB = fliplr(astrctTrackersJob(k).m_afB);
        astrctTrackersJob(k).m_afTheta = fliplr(astrctTrackersJob(k).m_afTheta);
        astrctTrackersJob(k).m_a2fClassifer = flipud(astrctTrackersJob(k).m_a2fClassifer);
        astrctTrackersJob(k).m_afHeadTail = fliplr(astrctTrackersJob(k).m_afHeadTail);
        % These will be removed at the end of the job
        astrctTrackersJob(k).m_a2fClassiferFlip = flipud(astrctTrackersJob(k).m_a2fClassifer);
        astrctTrackersJob(k).m_afHeadTailFlip = fliplr(astrctTrackersJob(k).m_afHeadTail);
    end;
end;
%% Interpolate missing values?
iNumFrames = length(astrctTrackersJob(1).m_afX);
for iMouseIter=1:iNumMice
    astrctMissingValues = fnGetIntervals(isnan(astrctTrackersJob(iMouseIter).m_afX));
    for iIter=1:length(astrctMissingValues)
        if astrctMissingValues(iIter).m_iStart > 1 && astrctMissingValues(iIter).m_iEnd < iNumFrames
            
            astrctTrackersJob = fnInterpolateBetweenFrames(astrctTrackersJob, iMouseIter, ...
                astrctMissingValues(iIter).m_iStart-1, astrctMissingValues(iIter).m_iEnd+1, false);

        end
    end
end

%%

fSwapThreshold = 90; 
for iMouseIter=1:iNumMice
    afDiffX = [0,astrctTrackersJob(iMouseIter).m_afX(2:end)-astrctTrackersJob(iMouseIter).m_afX(1:end-1)];
    afDiffY = [0,astrctTrackersJob(iMouseIter).m_afY(2:end)-astrctTrackersJob(iMouseIter).m_afY(1:end-1)];
    afAlpha = atan2(-afDiffY,afDiffX);
    afAlpha(afAlpha < 0) = afAlpha(afAlpha<0)+2*pi;
    afVel = sqrt(afDiffX.^2+afDiffY.^2);
    afTheta = astrctTrackersJob(iMouseIter).m_afTheta;
    afTheta(afTheta < 0) = afTheta(afTheta<0)+2*pi;
    afProbHead = astrctTrackersJob(iMouseIter).m_afHeadTail;
    
    

    fRotationalVelocityThreshold = 4 / 180*pi;
    T = afTheta;
    T(T>pi) = T(T>pi)-pi;
    dT = diff(T);
    dT(dT > pi/2) = dT(dT > pi/2) - pi;
    dT(dT < -pi/2) = dT(dT < -pi/2) + pi;
    abLowRotationalVelocity = [0,(abs(dT) < fRotationalVelocityThreshold)];
    % Erode a bit.
    abLowRotationalVelocity(2:end-1) = min(abLowRotationalVelocity(1:end-2),abLowRotationalVelocity(3:end));
    
    % Classifier weight should never be 0 or 1 because it can bias the
    % viterbi algorithm completely. We are never quite sure that the result
    % from the classifier is entirely correct. We model this by mapping the
    % actual probability values of [0,1] to a narrower range. In this case,
    % [0.1,0.9]. 
    afProbHead = 0.8*afProbHead + 0.1;
    % Classifier performance on high rotational velocity frames is not very
    % good. So, give 0.5 weight. This will not bias the optimization this
    % way or the other
    afProbHead(~abLowRotationalVelocity) = 0.5;
    
     
    afNewTheta = fnCorrectOrientation(afTheta, afAlpha, afVel, afProbHead);%, strctAdditionalInfo.m_strctHeadTailClassifier);
    

    % Do the necessary changes.
    afDiff = acos(  cos(afNewTheta) .* cos(afTheta) + sin(afNewTheta) .* sin(afTheta) )/pi*180;
    aiSwap = find( afDiff > fSwapThreshold);
    astrctTrackersJob(iMouseIter).m_afTheta(aiSwap) = astrctTrackersJob(iMouseIter).m_afTheta(aiSwap) + pi;
    astrctTrackersJob(iMouseIter).m_afTheta(astrctTrackersJob(iMouseIter).m_afTheta > 2*pi) = ...
        astrctTrackersJob(iMouseIter).m_afTheta(astrctTrackersJob(iMouseIter).m_afTheta > 2*pi) - 2*pi;
    
    % Take the hog features of the swapped version

    astrctTrackersJob(iMouseIter).m_afHeadTail(aiSwap) = ...
        astrctTrackersJob(iMouseIter).m_afHeadTailFlip(aiSwap);
    astrctTrackersJob(iMouseIter).m_a2fClassifer(aiSwap,:) = ...
        astrctTrackersJob(iMouseIter).m_a2fClassiferFlip(aiSwap,:);
 end;

  astrctTrackersJob = rmfield(...
      astrctTrackersJob,{'m_afHeadTailFlip','m_a2fClassiferFlip'});
return;

         
