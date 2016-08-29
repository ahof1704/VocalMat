function a2iFrame = fnReadFrameFromSeq(strctMovInfo, iFrame)

if strctMovInfo.m_iCompressionFormat == 0 && ...
   (strctMovInfo.m_iImageFormat==100 || strctMovInfo.m_iImageFormat==200)
  % Read uncompressed frame from video, either monochrome or BGR color
  hFileID = fopen(strctMovInfo.m_strFileName);
  offset=strctMovInfo.m_aiSeekPos(iFrame);
  fseek(hFileID, offset, 'bof');
  %dataRaw=fread(hFileID,strctMovInfo.m_iImageSizeBytes,'uint8=>uint8');
  dataRaw=fread(hFileID,strctMovInfo.m_iWidth*strctMovInfo.m_iHeight,'uint8=>uint8');
    % ALT -- had to change to support version 4 .seq files
  a2iFrame = reshape(dataRaw, ...
                     strctMovInfo.m_iWidth, ...
                     strctMovInfo.m_iHeight)';
  fclose(hFileID);
elseif strctMovInfo.m_iCompressionFormat == 1 && ...
       (strctMovInfo.m_iImageFormat==100 || strctMovInfo.m_iImageFormat==200)
  % read jpeg compressed frame from video, either monochrome or BGR color     
  offset=strctMovInfo.m_aiSeekPos(iFrame);
  a2iFrame = parsejpg8(strctMovInfo.m_strFileName, ...
                       offset);
  if size(a2iFrame,3) == 3
    a2iFrame = rgb2gray(a2iFrame);
  end  
else
  assert(false);
end

end
