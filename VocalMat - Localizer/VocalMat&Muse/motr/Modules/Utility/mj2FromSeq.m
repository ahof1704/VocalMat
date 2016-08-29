function mj2FromSeq(outputFileName,inputFileName)

if isempty(outputFileName)
  [a,b]=fileparts(inputFileName);
  outputFileName=fullfile(a,[b '.mj2']);
end

% Read the input file metadata
seqMetadata=fnReadSeqInfo(inputFileName);
nFrames=seqMetadata.m_iNumFrames;

% create the VideoWriter object, prepare for writing frames
vw=VideoWriter(outputFileName,'Motion JPEG 2000');
vw.FrameRate=seqMetadata.m_fFPS;
vw.CompressionRatio=10;  % conservative compression ratio
%vw.CompressionRatio=20;  % less conservative compression ratio
vw.open();

% read a frame, write a frame
fprintf('Trans-coding %d frames...\n',nFrames);
tic

iFrameLast=0;
timeElapsedLast=0;
for iFrame=1:nFrames
  frameThis=fnReadFrameFromSeq(seqMetadata,iFrame);
  vw.writeVideo(frameThis);
  if mod(iFrame,100)==0
    timeElapsed=toc;
    frameRate=(iFrame-iFrameLast)/(timeElapsed-timeElapsedLast);
    estimatedTotalTime=nFrames/iFrame*timeElapsed;
    estimatedTimeLeft=estimatedTotalTime-timeElapsed;
    fprintf('%d of %d frames written at %0.1f frames/sec.  Estimated time left: %0.0f seconds.\n', ...
            iFrame,nFrames,frameRate,estimatedTimeLeft);
    % save things for next iter      
    iFrameLast=iFrame;
    timeElapsedLast=timeElapsed;
  end
end

% nFramesPerChunk=100;
% if nFrames>0
%   frame=fnReadFrameFromSeq(seqMetadata,1);
%   [nRows,nCols]=size(frame);
%   inputBuffer=zeros(nRows,nCols,1,nFramesPerChunk);  % double
% end
% nChunk=ceil(nFrames/nFramesPerChunk);
% for iChunk=1:nChunk
%   if iChunk==nChunk
%     nFramesLastChunk=nFrames-nFramesPerChunk*(nChunk-1);
%     inputBuffer=zeros(nRows,nCols,1,nFramesLastChunk);  % double
%     nFramesThisChunk=nFramesLastChunk;
%   else
%     nFramesThisChunk=nFramesPerChunk;
%   end
%   for iFrameInBuffer=1:nFramesThisChunk
%     iFrame=(iChunk-1)*nFramesPerChunk+iFrameInBuffer;
%     frame=fnReadFrameFromSeq(seqMetadata,iFrame);
%     inputBuffer(:,:,1,iFrameInBuffer)=frame;
%   end
%   outputBuffer=uint8(round(min(255/cutoff*inputBuffer,255)));
%   vw.writeVideo(outputBuffer);
%   if mod(iChunk,10)==0
%     elapsedTime=toc;
%     estimatedTotalTime=nChunk/iChunk*elapsedTime;
%     estimateTimeLeft=estimatedTotalTime-elapsedTime;
%     fprintf('%d of %d chunks written.  Estimated time left: %.0f seconds.\n', ...
%             iChunk,nChunk,estimateTimeLeft);
%   end
% end

fprintf('Done trans-coding %d frames.\n',nFrames);

% close the output file
vw.close();

end
