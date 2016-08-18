function strctVideoInfo = fnReadVideoInfo(strFileName)
% Wrapper to read frames from video files.
% 
%
%Copyright (c) 2008 Shay Ohayon, California Institute of Technology. 
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

%global g_strVideoWrapper

[dummy,baseName,strExt] = fileparts(strFileName);  %#ok
%fileNameLocal=[baseName strExt];
if strcmpi(strExt,'.seq')
  strctVideoInfo = fnReadSeqInfo(strFileName);
else
  vidObj=VideoReader(strFileName);
  strctVideoInfo.m_strFileName = strFileName;
  strctVideoInfo.m_fFPS = vidObj.FrameRate;
  strctVideoInfo.m_iNumFrames = vidObj.NumberOfFrames;
  strctVideoInfo.m_iHeight = vidObj.Height;
  strctVideoInfo.m_iWidth = vidObj.Width;
  strctVideoInfo.m_afTimestamp = ...
    (1/strctVideoInfo.m_fFPS)*(0:(strctVideoInfo.m_iNumFrames-1));  % s
end

end
