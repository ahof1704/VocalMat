function astrctReliableFrames = fnAddBigJumpsToReliableFrames(handles,strctAdditionalInfo,strctMovieInfo,astrctReliableFrames,iNumMice,iNumReinitializations,iStartFrame,iEndFrame,iNumFramesMissing)
iCounter = length(astrctReliableFrames) + 1;

aiReliableFound = cat(1,  astrctReliableFrames.m_iFrame);
aiBigJumps = 1+ (find(strctMovieInfo.m_afTimestamp(2:end)-strctMovieInfo.m_afTimestamp(1:end-1) > 1/strctMovieInfo.m_fFPS * iNumFramesMissing));
aiBigJumps = setdiff(aiBigJumps,aiReliableFound); % Remove existing ones...
aiBigJumps = aiBigJumps(aiBigJumps >= iStartFrame & aiBigJumps < iEndFrame);
if ~isfield(astrctReliableFrames,'m_bBigJump')
    for k=1:length(astrctReliableFrames)
        astrctReliableFrames(k).m_bBigJump = false;
    end;
end
fprintf('%d key frames will be inserted due to frame drops!\n',length(aiBigJumps));
for iJumpIter=1:length(aiBigJumps)
   iCurrFrame = aiBigJumps(iJumpIter);
   fprintf('Frame drop was detected (big jump) at frame %d\n',iCurrFrame);
   a2iFrame = fnReadFrameFromVideo(strctMovieInfo,iCurrFrame);
   a2fFrame = double(a2iFrame)/255;
   [bFailed, acEllipses] = fnRiskyInit2(a2iFrame, strctAdditionalInfo,iNumMice,iNumReinitializations,true); % ,iCurrFrame);
   for iOptions=1:length(acEllipses)
      astrctReliableEllipses = acEllipses{iOptions};
      astrctReliableFrames(iCounter).m_iFrame = iCurrFrame;
      astrctReliableFrames(iCounter).m_bValid = true;
      astrctReliableFrames(iCounter).m_astrctEllipse = astrctReliableEllipses;
      astrctReliableFrames(iCounter).m_bBigJump = true;
      
      if ~isempty(handles)
         cla;
         a3fTmp(:,:,1)=a2fFrame;a3fTmp(:,:,2)=a2fFrame;a3fTmp(:,:,3)=a2fFrame;
         image([], [], a3fTmp, 'BusyAction', 'cancel', 'Parent', handles.axes1, 'Interruptible', 'off');
         ahHandles = fnDrawTrackers(astrctReliableEllipses);
         set(handles.text1, 'String',sprintf('Frame %d',iCurrFrame));
         axis ij
         drawnow
      end;
      
      iCounter=iCounter+1;
   end;
end;
[afDummy, aiSortIndices] = sort( cat(1,  astrctReliableFrames.m_iFrame));
astrctReliableFrames = astrctReliableFrames(aiSortIndices);
% Append background from previous reliable frame ?
a2iMedian = uint8(strctAdditionalInfo.strctBackground.m_a2fMedian*255);

for iIter=1:length(astrctReliableFrames)
    if isempty(astrctReliableFrames(iIter).m_a2iBackground)
        astrctReliableFrames(iIter).m_a2iBackground = a2iMedian;
    else
        a2iMedian = astrctReliableFrames(iIter).m_a2iBackground ;
    end
 
        
        
end
return;
