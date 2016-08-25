function success=testReadVideo()

thisFileNameAbs=mfilename('fullpath');  % without .m, for some reason
thisDirNameAbs=fileparts(thisFileNameAbs)
thisFunctionName=fileNameRelFromAbs(thisFileNameAbs);
d=dir(fullfile(thisDirNameAbs,'*.seq'));
fileNamesLocal={d.name}';
d=dir(fullfile(thisDirNameAbs,'*.mj2'));
fileNamesLocal=[fileNamesLocal;{d.name}'];
d=dir(fullfile(thisDirNameAbs,'*.avi'));
fileNamesLocal=[fileNamesLocal;{d.name}']
fileNamesAbs=cellfun(@(fileNameLocal)(fullfile(thisDirNameAbs,fileNameLocal)), ...
                     fileNamesLocal, ...
                     'UniformOutput',false)              

nFiles=length(fileNamesAbs);
for i=1:nFiles ,
  fileName=fileNamesAbs{i};
  vidInfo=fnReadVideoInfo(fileName)
  nFrames=vidInfo.m_iNumFrames;
  nFramesToRead=min(nFrames,100);
  % Read all frames at once, to test fnReadFramesFromVideo()
  vid=fnReadFramesFromVideo(vidInfo,1:nFramesToRead);
  fig=showFrames(vid);
  delete(fig);
  % Read one frame at a time, to test fnReadFrameFromVideo()
  vid2=zeros(vidInfo.m_iHeight,vidInfo.m_iWidth,nFramesToRead,'uint8');
  for iFrame=1:nFramesToRead
    thisFrame=fnReadFrameFromVideo(vidInfo,iFrame);
    vid2(:,:,iFrame)=thisFrame;
  end
  fig=showFrames(vid2);
  delete(fig);
end

success=true;

end  % function
