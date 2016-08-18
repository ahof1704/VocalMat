function [a2iOnlyMouse,iNumBlobs] = fnSegmentForeground2(a2fFrame, strctAdditionalInfo)
%
%Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

global g_strctGlobalParam
afTimeStampX=g_strctGlobalParam.m_strctSetupParameters.m_afTimeStampX;
afTimeStampY=g_strctGlobalParam.m_strctSetupParameters.m_afTimeStampY;
clear g_strctGlobalParam

switch strctAdditionalInfo.strctBackground.m_strMethod
  case 'FrameDiff_v7',
    % Auto-Tune
    strctSegParams = strctAdditionalInfo.strctBackground.m_strctSegParams;
    a2fBackground=strctAdditionalInfo.strctBackground.m_a2fMedian;
    a2bFloor=strctAdditionalInfo.strctBackground.m_a2bFloor;
    a2fTimeStampBB=[afTimeStampX ; ...
                    afTimeStampY ];
    [a2iOnlyMouse,iNumBlobs] = ...
      fnSegmentForeground3(a2fFrame, ...
                           strctSegParams, ...
                           a2fBackground, ...
                           a2bFloor,...
                           a2fTimeStampBB);
  otherwise,
    error('Method no longer implemented.');
end

end
