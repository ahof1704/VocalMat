function [a3iFrames,aiBufferFrames] = fnFillBufferFromFrame(strctMovieInfo,iStartFrame, iEndFrame, iBufferSize)
fStartTime = cputime;
if iStartFrame > iEndFrame
    aiBufferFrames = iStartFrame:-1:max(iEndFrame, iStartFrame-iBufferSize+1);
    fprintf('Reading buffer (frames %d - %d)...',aiBufferFrames(1),aiBufferFrames(end));
    a3iFrames = fnReadFramesFromVideo(strctMovieInfo, fliplr(aiBufferFrames));
    a3iFrames = a3iFrames(:,:,end:-1:1);
else
    aiBufferFrames = iStartFrame:min(iEndFrame, iStartFrame+iBufferSize-1);
    fprintf('Reading buffer (frames %d - %d)...',aiBufferFrames(1),aiBufferFrames(end));
    a3iFrames = fnReadFramesFromVideo(strctMovieInfo, aiBufferFrames);
end;
fEndTime = cputime;
fprintf('Done in %.2f sec (%.2f per frame) \n', fEndTime-fStartTime, (fEndTime-fStartTime) / length(aiBufferFrames));
return;