function a2fBackgroundNew = fnUpdateBackground(a2iFrame, ...
                                               a2fBackground, ...
                                               strctFrameOutput, ...
                                               fUpdateWeight)
                                             
% Uses the current frame, and the direllipses for it, to update the 
% background image.  Basically, pels that are far from any of the mouse
% direllipses are taken to be good estimates of the background at that pel.
% For these pels, the new background image is a weighted sum of the current
% frame and the original background image, with the current frame given
% weight fUpdateWeight.  For pixels in or near a mouse direllipse, the
% background image is unchanged.
%
% On entry:
% a2iFrame is the current frame, as uint8.
% a2fBackground contains the current background image, pels on [0,1]
% strctFrameOuput is a 1xiNumMice direllipse struct containing the
%   direllipses for the current frame.  
% fUpdateWeight tells how much the
%   current-frame information should change the background image.  It 
%   should be on (0,1).
%
% On exit:
% a2fBackgroundNew contains the updated background image, with pels 
%   on [0,1].

% Get any globals we'll need
global g_strctGlobalParam;
fUnreliableBlobMajorAxis = ...
  g_strctGlobalParam.m_strctTracking.m_afAxisBounds(3) + 1; % OA was 21;
clear g_strctGlobalParam;

% This is the fall-back return value: no update.
a2fBackgroundNew = a2fBackground;

% If any mice are missing, return without updating the background
iNumMice=length(strctFrameOutput);
for k=1:iNumMice
    if isnan(strctFrameOutput(k).m_fX)
        return;
    end
end

% Make a grid of possible theta values.
N = 60; 
afTheta = linspace(0,2*pi,N);%2*pi*[0:N]/N;

% a2bNoChange is true for the pels that will not be changed.
a2bNoChange = false(size(a2fBackground));
for iMouseIter=1:iNumMice
    % Unpack the direllipse params for the current frame, mouse.
    fX=strctFrameOutput(iMouseIter).m_fX;
    fY=strctFrameOutput(iMouseIter).m_fY;    
    fA=strctFrameOutput(iMouseIter).m_fA;
    fB=strctFrameOutput(iMouseIter).m_fB;
    fTheta=strctFrameOutput(iMouseIter).m_fTheta;
    % This try to capture events when the ellipse is not very reliable.
    % In those cases, we should not update the background near the blob
    % because it might capture a part of the mouse that was not segmented
    % properly (i.e., leading to a small major axis).
    if fA <= fUnreliableBlobMajorAxis 
        fDilationFactor = 5;
    else
        fDilationFactor = 2;
    end
    % Generate an ellipse perimeter for the current direllipse.
    apt2f = fDilationFactor*[fA * cos(afTheta); fB * sin(afTheta)];
    R = [ cos(fTheta) sin(fTheta) ;
         -sin(fTheta) cos(fTheta) ];
    apt2fFinal = R*apt2f + repmat([fX;fY],1,N);
    BW = roipoly(a2fBackground, apt2fFinal(1,:), apt2fFinal(2,:)) ;
      % BW is true for points inside the direllipse.
    a2bNoChange = a2bNoChange | BW;
end
% a2bNoChange is true for points far from any mouse direllipse---these
% will not be updated

% Construct the weighted average of the old BG image and the current frame,
% for those frames far from any mouse direllipse.
a2fFrame=double(a2iFrame)/255;
a2fBackgroundNew(~a2bNoChange) = ...
  (1-fUpdateWeight) * a2fBackground(~a2bNoChange) + ...
  fUpdateWeight     * a2fFrame(~a2bNoChange);

end
