function Output = fnCreateVideoObject(strFileName)
% Wrapper to read frames from video files.
%
%
%Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

%global g_strVideoWrapper g_iFrame
global g_iFrame

g_iFrame = 1;
Output = strFileName;

% if isempty(g_strVideoWrapper) || strcmpi(g_strVideoWrapper,'matlab')
%     g_iFrame = 1;
%     Output = strFileName;
% elseif strcmpi(g_strVideoWrapper,'directx')
%         Handle = DirectXInterface('Open',strFileName);
%         DirectXInterface('Start',Handle);
%         Output = Handle;
% elseif strcmpi(g_strVideoWrapper,'videoio')
%         vr = videoReader(strFileName);
%         seek(vr,1);
%         Output = vr;
% end;
