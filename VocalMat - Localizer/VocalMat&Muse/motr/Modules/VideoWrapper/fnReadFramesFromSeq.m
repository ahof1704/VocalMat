function a3iFrames = fnReadFramesFromSeq(strctMovInfo, aiFrames)
iNumFramesToRead = length(aiFrames);
a3iFrames = zeros(strctMovInfo.m_iHeight,strctMovInfo.m_iWidth,iNumFramesToRead,'uint8');
for k=1:iNumFramesToRead
    a3iFrames(:,:,k) = fnReadFrameFromSeq(strctMovInfo, aiFrames(k));
end
return;
