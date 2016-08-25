function clipListString=colorizeClips(clipFNAbs,trackStatus,iCurrClip)
% Takes a cell array of strings containing the clip file names, and their
% respective statuses, and the index of the current clip and returns
% a cell array of HTML strings used to populate the clip listbox, in which
% clips are colored according to their status code.

% get color info
C = fnGetColorCode();
Chtml = fnGetHtmlColorStrings(C);

% colorize each clip name appropriately
nClips=length(clipFNAbs);
clipListString=cell(1,nClips);
for i=1:nClips
    iStatus = trackStatus(i);
    if i == iCurrClip
        clipListString{i} = ['<html><bgcolor="' Chtml{iStatus,1,2} ...
                             '"><font color="' Chtml{iStatus,2,2} '">' ...
                             clipFNAbs{i} '</font></html>'];
    else
        clipListString{i} = ['<html><bgcolor="' Chtml{iStatus,1,1} ...
                             '"><font color="' Chtml{iStatus,2,1} '">' ...
                             clipFNAbs{i} '</font></html>'];
    end
end
