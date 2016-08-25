function fnDestroyVideoObject(hVideoObject)
% Wrapper to read frames from video files.
%
%
%Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

%global g_strVideoWrapper

return;
% if isempty(g_strVideoWrapper) || strcmpi(g_strVideoWrapper,'matlab')
%     return;
% else
%     if strcmpi(g_strVideoWrapper,'directx')
%         DirectXInterface('Stop',hVideoObject);
%         DirectXInterface('Close',hVideoObject);
%     else
%         close(hVideoObject);
%     end;
% end;
