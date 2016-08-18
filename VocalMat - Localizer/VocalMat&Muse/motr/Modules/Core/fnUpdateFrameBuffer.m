function [a3iFrames,aiBufferFrames] = ...
  fnUpdateFrameBuffer(iCurrFrame, ...
                      iStartFrame, ...
                      iEndFrame, ...
                      a3iFrames, ...
                      aiBufferFrames, ...
                      strctJob, ...
                      iLocalMachineBufferSizeInFrames)

if iEndFrame >= iStartFrame
    if iCurrFrame == aiBufferFrames(end)
        if iCurrFrame == iEndFrame
            fprintf('Reached last frame of job interval.\n');
        else
            % Reload buffer
            fprintf('Buffer Event\n');
            [a3iFrames,aiBufferFrames] = fnFillBufferFromFrame(strctJob.m_strctMovieInfo,...
                iCurrFrame+1, iEndFrame, iLocalMachineBufferSizeInFrames);
        end;
    end;
else
    % Reversed sequence

    if iCurrFrame == aiBufferFrames(end)
        if iCurrFrame == iEndFrame
            fprintf('Reached last frame of job interval.\n');
            return;
        else
            % Reload buffer
            fprintf('Buffer Event\n');
            [a3iFrames,aiBufferFrames] = fnFillBufferFromFrame(strctJob.m_strctMovieInfo,...
                iCurrFrame-1, iEndFrame, iLocalMachineBufferSizeInFrames);
        end;
    end;


end;
return;