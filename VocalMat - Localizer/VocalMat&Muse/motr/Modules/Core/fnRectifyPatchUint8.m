function a2iRectifiedPatch = fnRectifyPatchUint8(a2iFrame,fX,fY,fTheta)
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology. 
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

% a2iFrame should be uint8.
% On return, a2iRectifiedPatch is uint8.

global g_strctGlobalParam

iHalfHeight = (g_strctGlobalParam.m_strctClassifiers.m_fImagePatchHeight-1)/2;
iHalfWidth = (g_strctGlobalParam.m_strctClassifiers.m_fImagePatchWidth-1)/2;

R = [ cos(fTheta), sin(fTheta);
    -sin(fTheta), cos(fTheta)];

[a2fX,a2fY] = meshgrid(-iHalfWidth:iHalfWidth,-iHalfHeight:iHalfHeight);
P = [a2fX(:),a2fY(:)];
Pt = R * P'; 
afValues = fnFastInterp2(a2iFrame,double(Pt(1,:)+fX),double(Pt(2,:)+fY));
  % fnFastInterp2() seems to always return a single-precision array,
  % regardless of the input type.
  % ALT, 2012/03/19
a2fRectifiedPatch = reshape(afValues,size(a2fX));
a2iRectifiedPatch=uint8(a2fRectifiedPatch);

return;
