function [answer]=fnInsideImage(handles, window_handle)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology. 
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)
set(handles.figure1,'Units','pixels');
set(window_handle,'Units','pixels');
MousePos=get(handles.figure1,'CurrentPoint');
AxesRect=get(window_handle,'Position');
if (MousePos(1) > AxesRect(1) && MousePos(1) < AxesRect(1)+AxesRect(3) && ...
        MousePos(2) > AxesRect(2) && MousePos(2) < AxesRect(2)+AxesRect(4))
    answer = 1;
else
    answer = 0;
end;
return;
