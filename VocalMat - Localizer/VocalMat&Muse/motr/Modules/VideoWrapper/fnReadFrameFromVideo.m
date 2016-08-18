function output = fnReadFrameFromVideo(strctVideoInfo, iFrame)
% Wrapper to read frames from video files.
%
%
%Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

%global g_strVideoWrapper
strFileName = strctVideoInfo.m_strFileName;

[dummy,dummy, strExt] = fileparts(strFileName);  %#ok
if strcmpi(strExt,'.seq')
  output = fnReadFrameFromSeq(strctVideoInfo, iFrame);
  if size(output,3) > 1
    % Want to force to be monochrome
    output = output(:,:,1);  % w x h, uint8
  end
else    
  % vidObj = mmreader(strFileName);
  vidObj = VideoReader(strFileName);
  a3fFrameThis=vidObj.read(iFrame);  % uint8, w x h x 3
  output=uint8(mean(double(a3fFrameThis),3));  % w x h, uint8
end

end
