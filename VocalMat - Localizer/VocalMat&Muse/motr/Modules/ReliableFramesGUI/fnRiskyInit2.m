function [bFailed,acReliableEllipses] = fnRiskyInit2(a2iFrame, strctAdditionalInfo,iNumMice,iNumReinitializations,bMultiple)
%
% Get iNumMice ellipses from a single frame without an initial guess.
% Used for begining an interval of frames (job).
%
global g_bDebugMode 

global gCounts g_acFrame g_acOptions;

if ~exist('bMultiple', 'var'), bMultiple = false; end;
a2fFrame = double(a2iFrame)/255;
%fTotalError = 0;

a2iForeground = fnSegmentForeground2(a2fFrame, strctAdditionalInfo);
% a2bClosed=imclose(a2iForeground>0,ones(5,5));
% [a2iForeground,iNumBlobs] = bwlabel(a2bClosed);
strctRegionProps = regionprops(a2iForeground);
acClusters = fnSolveFragmentationProblem(strctRegionProps,iNumMice);
iNumBlobs = length(acClusters);
a2iForeground2 = zeros(size(a2iForeground));
for k=1:iNumBlobs
    a2iForeground2(fnSelectLabels(a2iForeground, uint16(acClusters{k})) > 0) = k;
end;
a2iForeground = a2iForeground2;

%a2iAllPerm = fnGenCombAux(iNumBlobs,iNumMice,zeros(1,iNumBlobs),1,[]);
a2iAllPerm = fnGenComb(iNumBlobs,iNumMice);  % ALT, 2011-01-03
a2fNumMicePerBlob = a2iAllPerm(sum(a2iAllPerm,2) == iNumMice,:);
clear a2iAllPerm;  % not needed
iNumOptions = size(a2fNumMicePerBlob,1);
    % a2fNumMicePerBlob is whatever x iNumBlobs, and each row is a single 
    % possibility for for many mice are in each blob.  All such possibilities
    % are enumerated.  Thus the number of rows (iNumOptions) is the number of 
    % different ways of putting iNumMice unlabelled balls into iNumBlobs 
    % labelled urns, s.t. there is at least one ball in each urn.

afMaxCorr = zeros(1,iNumOptions);
astrctOpt = cell(1,iNumOptions);
abEMFailure = zeros(1,iNumOptions);
afMinDist = zeros(1,iNumOptions);
afAreaMean = zeros(1,iNumOptions);
afAreaStd = zeros(1,iNumOptions);
for iIter=1:iNumOptions

    % Use k-means as initialization
    a2fMu = zeros(2,iNumMice);
    a3fCov = zeros(2,2,iNumMice);
    iGlobalMouseCounter = 0;
    
    for iBlobIter=1:iNumBlobs
        iNumMiceInThisCC = a2fNumMicePerBlob(iIter, iBlobIter);
        a2bTmp = a2iForeground == iBlobIter;
        [aiY,aiX]=find(a2bTmp);
        [idx, Clusters] = kmeans([aiX,aiY],iNumMiceInThisCC );
        for iMouseIter=1:iNumMiceInThisCC
        [a2fMu(:,iGlobalMouseCounter+iMouseIter), a3fCov(:,:,iGlobalMouseCounter+iMouseIter)] = ...
            fnFitGaussian([aiX(idx==iMouseIter),aiY(idx==iMouseIter)]);
        end;
        iGlobalMouseCounter=iGlobalMouseCounter+iNumMiceInThisCC;
    end;
        
    % Run EM
    astrctKMeansEllipses = fnCov2EllipseArrayStrct(a2fMu, a3fCov);
    
    [aiY,aiX]=find(a2iForeground>0);
    [astrctOpt{iIter},afMaxCorr(iIter),aiUseableTrackers] = fnSolveUsingConstrainedEM(astrctKMeansEllipses, ...
       [aiX,aiY], strctAdditionalInfo,a2iFrame,iNumReinitializations,true);
    afAreaMean(iIter) = mean([astrctOpt{iIter}.m_fA].^2 + [astrctOpt{iIter}.m_fB].^2);
    afAreaStd(iIter) = std([astrctOpt{iIter}.m_fA].^2 + [astrctOpt{iIter}.m_fB].^2);
    abEMFailure(iIter) = sum(aiUseableTrackers) ~= sum(1:iNumMice);
    afMinDist(iIter) = 10000;
    for i=1:iNumMice
       for j=i+1:iNumMice
          afMinDist(iIter) = min(afMinDist(iIter), sqrt((astrctOpt{iIter}(i).m_fX-astrctOpt{iIter}(j).m_fX).^2+...
                                                      (astrctOpt{iIter}(i).m_fY-astrctOpt{iIter}(j).m_fY).^2));
       end
    end

end;
[fMaxCorr, iSelectedOption] = max(afMaxCorr);
if bMultiple
   aiSelectedOption = find(afMaxCorr > fMaxCorr-0.15 & afMinDist > 0.6*afMinDist(iSelectedOption) & ...
                           afAreaStd < afAreaStd(iSelectedOption)+0.4*afAreaMean(iSelectedOption));
else
   aiSelectedOption = iSelectedOption;
end
acReliableEllipses = astrctOpt(aiSelectedOption);
if abEMFailure(iSelectedOption)
    bFailed= true;
    return;
end;

if g_bDebugMode
    h=gcf;
    figure(11);
    clf;
    imshow(a2iFrame,[]);hold on;
    fnDrawTrackers(acReliableEllipses{iSelectedOption});
    figure(h);
end;

if isempty(astrctOpt)
    bFailed = true;
    return;
end;

abReasonable = zeros(1,iNumMice);
for k=1:iNumMice
    abReasonable(k) = fnIsReasonableMouseBlob2(astrctOpt{iSelectedOption}(k));
end;
bFailed = sum(abReasonable) ~= iNumMice;

% Make sure there is no degenerate solution where two ellipses completely overlap
% for i=1:iNumMice
%     for j=i+1:iNumMice
%         [bIntersect, apt3fIntersectionPoints, fIntersectionArea] = fnEllipseEllipseIntersection(...
%             astrctReliableEllipses(i).m_fX,...
%             astrctReliableEllipses(i).m_fY,...
%             astrctReliableEllipses(i).m_fA,...
%             astrctReliableEllipses(i).m_fB,...
%             astrctReliableEllipses(i).m_fTheta,...
%             astrctReliableEllipses(j).m_fX,...
%             astrctReliableEllipses(j).m_fY,...
%             astrctReliableEllipses(j).m_fA,...
%             astrctReliableEllipses(j).m_fB,...
%             astrctReliableEllipses(j).m_fTheta);
%         if bIntersect
%             fIntersectionAreaRatio = max(fIntersectionArea / (pi * astrctReliableEllipses(i).m_fA *  astrctReliableEllipses(i).m_fB),...
%                 fIntersectionArea / (pi * astrctReliableEllipses(j).m_fA *  astrctReliableEllipses(j).m_fB));
%             if fIntersectionAreaRatio > 0.2
%                 bFailed = true;
%                 return;
%             end;
%         end;
%     end;
% end;



% a2fDist = zeros(iNumMice,iNumMice);
% for i=1:iNumMice
%     for j=i+1:iNumMice
%         a2fDist(i,j) = sqrt((astrctReliableEllipses(i).m_fX-astrctReliableEllipses(j).m_fX).^2+...
%             (astrctReliableEllipses(i).m_fY-astrctReliableEllipses(j).m_fY).^2);
%     end
% end
% if max(a2fDist(:)) < 90
%     % All mice are in one cluster...
%     bFailed = true;
%     return;
% end

return;