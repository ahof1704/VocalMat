function [astrctTrackers,bFailed] = fnInterpolateBetweenFrames(astrctTrackers, iMouseIter, iLeftFrame, iRightFrame, bCheck)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

%iLeftFrame = getappdata(handles.figure1,'iLeftFrame');
%iRightFrame = getappdata(handles.figure1,'iRightFrame');
%astrctTrackers = getappdata(handles.figure1,'astrctTrackers');
aiFrames = iLeftFrame:iRightFrame;
bFailed = false;
if  isnan(astrctTrackers(iMouseIter).m_afX(iLeftFrame)) || ...
        isnan(astrctTrackers(iMouseIter).m_afX(iRightFrame))
    if bCheck
        msgbox('Can not interpolate because one of the extreme values is missing');
    end;
    bFailed = true;
    return;
end;
if iRightFrame-iLeftFrame < 2
    return;
end;
% Do smooth interpolation of angles...
%aiInd = find(astrctTrackers(iMouseIter).m_afTheta(aiFrames) < 0);
%astrctTrackers(iMouseIter).m_afTheta(aiFrames(aiInd)) = ...
%    astrctTrackers(iMouseIter).m_afTheta(aiFrames(aiInd)) + pi;

astrctTrackers(iMouseIter).m_afX(aiFrames) = ...
    linspace(astrctTrackers(iMouseIter).m_afX(iLeftFrame),...
    astrctTrackers(iMouseIter).m_afX(iRightFrame), length(aiFrames));

astrctTrackers(iMouseIter).m_afY(aiFrames) = ...
    linspace(astrctTrackers(iMouseIter).m_afY(iLeftFrame),...
    astrctTrackers(iMouseIter).m_afY(iRightFrame), length(aiFrames));


    
astrctTrackers(iMouseIter).m_afA(aiFrames) = ...
    linspace(astrctTrackers(iMouseIter).m_afA(iLeftFrame),...
    astrctTrackers(iMouseIter).m_afA(iRightFrame), length(aiFrames));

astrctTrackers(iMouseIter).m_afB(aiFrames) = ...
    linspace(astrctTrackers(iMouseIter).m_afB(iLeftFrame),...
    astrctTrackers(iMouseIter).m_afB(iRightFrame), length(aiFrames));

if astrctTrackers(iMouseIter).m_afTheta(iRightFrame) < 0
    astrctTrackers(iMouseIter).m_afTheta(iRightFrame) = ...
        astrctTrackers(iMouseIter).m_afTheta(iRightFrame)  + 2*pi;
end

if astrctTrackers(iMouseIter).m_afTheta(iLeftFrame) < 0
    astrctTrackers(iMouseIter).m_afTheta(iLeftFrame) = ...
        astrctTrackers(iMouseIter).m_afTheta(iLeftFrame)  + 2*pi;
end


if abs(astrctTrackers(iMouseIter).m_afTheta(iLeftFrame)-astrctTrackers(iMouseIter).m_afTheta(iRightFrame)) > pi
    % Dirty hack. we always interpolate along the shortest angle between
    % the left and right frames. So, if we have Left = 10 and right = 350,
    % we obviously don't want to go 10..350, but 10.. -10
    % so, we check which one is larger than pi, and make it negative.
    % but after the interpolation, we make all values positive again.
    % (which is the convension).
    if astrctTrackers(iMouseIter).m_afTheta(iLeftFrame) > pi
    astrctTrackers(iMouseIter).m_afTheta(aiFrames) = ...
        linspace(astrctTrackers(iMouseIter).m_afTheta(iLeftFrame)-2*pi,...
        astrctTrackers(iMouseIter).m_afTheta(iRightFrame), length(aiFrames));
    else
    astrctTrackers(iMouseIter).m_afTheta(aiFrames) = ...
        linspace(astrctTrackers(iMouseIter).m_afTheta(iLeftFrame),...
        astrctTrackers(iMouseIter).m_afTheta(iRightFrame)-2*pi, length(aiFrames));
    end;
    
    X = astrctTrackers(iMouseIter).m_afTheta(aiFrames);
    X(X<0) = X(X<0) + 2*pi;
    astrctTrackers(iMouseIter).m_afTheta(aiFrames) = X;
else
    astrctTrackers(iMouseIter).m_afTheta(aiFrames) = ...
        linspace(astrctTrackers(iMouseIter).m_afTheta(iLeftFrame),...
        astrctTrackers(iMouseIter).m_afTheta(iRightFrame), length(aiFrames));
end;

% Interpolate classifier values (probably a bad idea...)
% if isfield(astrctTrackers(iMouseIter),'m_astrctClass') && isfield(astrctTrackers(iMouseIter).m_astrctClass(aiFrames(1)),'m_fHeadTailValue')
%     afInterpolationHeadTail = linspace(astrctTrackers(iMouseIter).m_astrctClass(aiFrames(1)).m_fHeadTailValue,...
%         astrctTrackers(iMouseIter).m_astrctClass(aiFrames(end)).m_fHeadTailValue, length(aiFrames));
% 
%     for iFrameIter=aiFrames
%         astrctTrackers(iMouseIter).m_astrctClass(iFrameIter).m_fHeadTailValue = ...
%             afInterpolationHeadTail(iFrameIter-aiFrames(1)+1);
%     end;
% end;


if ~isfield(astrctTrackers(iMouseIter),'m_a2fClassifer') 
    iNumClassifiers = 0;
else
     iNumClassifiers = size(astrctTrackers(iMouseIter).m_a2fClassifer,2);
end;

% Do not interpolate classifier values!

for iIter=1:iNumClassifiers
%     afInterpolation = linspace(astrctTrackers(iMouseIter).m_a2fClassifer(aiFrames(1), iIter),...
%         astrctTrackers(iMouseIter).m_a2fClassifer(aiFrames(end), iIter),length(aiFrames));

    astrctTrackers(iMouseIter).m_a2fClassifer(aiFrames, iIter) = 1/iNumClassifiers;%afInterpolation;

    if isfield(astrctTrackers,'m_a2fClassiferFlip')
             astrctTrackers(iMouseIter).m_a2fClassiferFlip(aiFrames, iIter) = 1/iNumClassifiers;%linspace(astrctTrackers(iMouseIter).m_a2fClassiferFlip(aiFrames(1), iIter),...
            %astrctTrackers(iMouseIter).m_a2fClassiferFlip(aiFrames(end), iIter),length(aiFrames));
    end

end;
if isfield(astrctTrackers(iMouseIter),'m_afHeadTail')
      astrctTrackers(iMouseIter).m_afHeadTail(aiFrames) = 0.5;
      %linspace(astrctTrackers(iMouseIter).m_afHeadTail(aiFrames(1)),astrctTrackers(iMouseIter).m_afHeadTail(aiFrames(end)),length(aiFrames));
end
if isfield(astrctTrackers(iMouseIter),'m_afHeadTailFlip')
      astrctTrackers(iMouseIter).m_afHeadTailFlip(aiFrames) = 0.5;%
      %linspace(astrctTrackers(iMouseIter).m_afHeadTailFlip(aiFrames(1)),...        astrctTrackers(iMouseIter).m_afHeadTailFlip(aiFrames(end)),length(aiFrames));
end

 

return;