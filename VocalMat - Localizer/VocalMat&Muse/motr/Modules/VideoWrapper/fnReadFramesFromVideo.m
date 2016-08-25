function output = fnReadFramesFromVideo(strctVideoInfo, aiFrames)
% Wrapper to read frames from video files.
%
%
%Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

%global g_strVideoWrapper
strFileName = strctVideoInfo.m_strFileName;

[dummy,dummy,strExt] = fileparts(strFileName);  %#ok

if strcmpi(strExt,'.seq')
  output = fnReadFramesFromSeq(strctVideoInfo, aiFrames);
else
  vidObj = VideoReader(strFileName);
  output = zeros(vidObj.Height,vidObj.Width,length(aiFrames),'uint8');
  for i=1:length(aiFrames)
    a3fFrameThis=vidObj.read(aiFrames(i));  % w x h x 3
    output(:,:,i) = uint8(mean(double(a3fFrameThis),3));
  end
end

end
