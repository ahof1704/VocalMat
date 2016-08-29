function a3iRectified = fnCollectRectifiedMice3(a2iFrame, astrctTrackers)
% Get the registered image patches for each of the mice.
%
% Inputs:
% a2iFrame is a uint8 image.
% astrctTrackers is a 1 x iNumMice structure with (at least) these fields:
%     m_fX: scalar, x-coordinate, in pels
%     m_fY: scalar, y-coordinate, in pels (low indices at the top of the
%           image)
%     m_fTheta: scalar, orientation (radians, zero points right ward,
%               increasing CCW)
%   (Usually astrctTrackers will also have fields m_fA and m_fB for the
%   ellipse shape, but these are not used by this function.)
%
% Outputs:
% a3iRectified is iH x iW x iNumMice, where iH and iW are specified in the 
%   globals, and define the size of a registered patch image.  Pels are
%   uint8.

% Get globals we need.
global g_strctGlobalParam
iW=g_strctGlobalParam.m_strctClassifiers.m_fImagePatchWidth;
iH=g_strctGlobalParam.m_strctClassifiers.m_fImagePatchHeight;
clear g_strctGlobalparam

iNumMice = length(astrctTrackers);
a3iRectified = ones(iH,iW,iNumMice,'uint8');
for iMouseIter=1:iNumMice
    if ~isnan(astrctTrackers(iMouseIter).m_fX)
        a3iRectified(:,:,iMouseIter) = ...
            fnRectifyPatch(a2iFrame, ...
                           astrctTrackers(iMouseIter).m_fX,...
                           astrctTrackers(iMouseIter).m_fY,...
                           astrctTrackers(iMouseIter).m_fTheta);
        % fnRectifyPatch() returns a single-precision image with pels on
        % [0,255], and that gets converted to uint8 by the assignment,
        % since a3iRectified is uint8.
    end;
end;

return;

