function [astrctEllipsesUpdated, astrctTrackersJob, abLostMice] = ...
  fnJobProcessFrame(astrctTrackersHistory,...
                    a2iFrame, ...
                    strctAdditionalInfo, ...
                    astrctTrackersJob, ...
                    abLostMice, ...
                    iOutputIndex)
% Take the current frame, segment the foreground, and produce (first-draft?)
% direllipses.  Also, update astrctTrackersJob as needed.
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

%global g_bDebugMode g_iLogLevel
global g_bDebugMode

% Deal with args
if nargin<4
  astrctTrackersJob=[];
end

% Convert the uint frame to a double frame on [0,1]
a2fFrame = double(a2iFrame)/255;

% Segment out the foreground, label the blobs.
[a2iOnlyMouse,iNumBlobs] = fnSegmentForeground2(a2fFrame, strctAdditionalInfo);

% Extract direllipses from the blobs, taking into account the history.
[astrctEllipsesUpdated,astrctTrackersJob,abLostMice] = ...
  fnSolveAssignmentProblem(astrctTrackersHistory, ...
                           a2iOnlyMouse, ...
                           iNumBlobs,...
                           strctAdditionalInfo, ...
                           a2iFrame, ...
                           astrctTrackersJob, ...
                           abLostMice, ...
                           iOutputIndex);

% Update the log                         
iLogLevel = 1 + (iNumBlobs == length(astrctTrackersHistory));
fnLog(['Segmentation extracted ' num2str(iNumBlobs) ' blobs'], ...
      iLogLevel, a2iOnlyMouse);

% Produce debuggming output, if in debug mode.    
if g_bDebugMode
    hFig = figure(3);
    %delete(get(hFig,'children'));
     clf;
%    H=axis;
    imshow(a2fFrame,[]);
    hold on;
    fnDrawTrackers(astrctEllipsesUpdated);
%    title('Final Assignment');
%     hold off;
%     if ~all(abs(H - [0 1 0 1]) == 0)
%         axis(H);
%     end;
    drawnow
end;

return;
