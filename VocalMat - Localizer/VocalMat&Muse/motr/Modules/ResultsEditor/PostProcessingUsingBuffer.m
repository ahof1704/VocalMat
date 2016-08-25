function acResult = PostProcessingUsingBuffer(astrctTrackers,strctMovieInfo,iStartFrame,iEndFrame, Fnc, arg)
iBufferSizeInFrames = 300;

[a3iFrames,aiBufferFrames] = fnFillBufferFromFrame(strctMovieInfo,...
    iStartFrame, iEndFrame,iBufferSizeInFrames);

acResult = cell(1,iEndFrame-iStartFrame+1);

for iCurrFrame = iStartFrame:iEndFrame
    iBuffIndex = iCurrFrame-aiBufferFrames(1)+1;
    
    tic
    acResult{iCurrFrame} = feval(Fnc,a3iFrames(:,:,iBuffIndex),astrctTrackers,iCurrFrame);
    A=toc;
    fprintf('Processing time for frame %d: %.2f\n',iCurrFrame,A);   
    if iCurrFrame == aiBufferFrames(end)
        if iCurrFrame == iEndFrame
            fprintf('Reached last frame of job interval.\n');
            break;
        else
            % Reload buffer
            fprintf('Buffer Event\n');
            [a3iFrames,aiBufferFrames] = fnFillBufferFromFrame(strctMovieInfo,...
                iCurrFrame+1, iEndFrame, iBufferSizeInFrames);
        end;
    end;
end;
return;

function [a3iFrames,aiBufferFrames] = fnFillBufferFromFrame(strctMovieInfo,iStartFrame, iEndFrame, iBufferSize)
aiBufferFrames = iStartFrame:min(iEndFrame, iStartFrame+iBufferSize-1);
fprintf('Reading buffer (frames %d - %d)...',aiBufferFrames(1),aiBufferFrames(end));
a3iFrames = fnReadFramesFromVideo(strctMovieInfo, aiBufferFrames);
fprintf('Done\n');
return;

function astrctTracker = fnGetTrackersAtFrame(astrctTrackers, iFrame)
iNumMice = length(astrctTrackers);
for iMouseIter=1:iNumMice
    astrctTracker(iMouseIter).m_fX = astrctTrackers(iMouseIter).m_afX(iFrame);
    astrctTracker(iMouseIter).m_fY = astrctTrackers(iMouseIter).m_afY(iFrame);
    astrctTracker(iMouseIter).m_fA = astrctTrackers(iMouseIter).m_afA(iFrame);
    astrctTracker(iMouseIter).m_fB = astrctTrackers(iMouseIter).m_afB(iFrame);
    astrctTracker(iMouseIter).m_fTheta = astrctTrackers(iMouseIter).m_afTheta(iFrame);
end;
return;
