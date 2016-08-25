function a2fRectifiedPatch = fnRectifyPatch(a2fFrame, fX,fY,fTheta)
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology. 
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

% This function works even if a2fFrame is uint8.  --ALT, 2012/03/19
% And a2fRectifiedPatch is always single, regardless of the type of
% the input frame.

global g_strctGlobalParam

iHalfHeight = (g_strctGlobalParam.m_strctClassifiers.m_fImagePatchHeight-1)/2;
iHalfWidth = (g_strctGlobalParam.m_strctClassifiers.m_fImagePatchWidth-1)/2;

R = [ cos(fTheta), sin(fTheta);
    -sin(fTheta), cos(fTheta)];

[a2fX,a2fY] = meshgrid(-iHalfWidth:iHalfWidth,-iHalfHeight:iHalfHeight);
P = [a2fX(:),a2fY(:)];
Pt = R * P'; 
afValues = fnFastInterp2(a2fFrame,double(Pt(1,:)+fX),double(Pt(2,:)+fY)); % Note, it returns UINT8, not float (!!!)
  % fnFastInterp2() seems to always return a single-precision array,
  % regardless of the input type, and can cope sensibly if the input type
  % is uint8.  Presumably that comment is old.
  % ALT, 2012/03/27
a2fRectifiedPatch = reshape(afValues,size(a2fX));
return;
