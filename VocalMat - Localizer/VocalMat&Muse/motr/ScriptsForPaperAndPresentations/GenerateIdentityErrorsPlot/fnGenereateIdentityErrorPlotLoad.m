function strctGroundTruth = fnGenereateIdentityErrorPlotLoad(strctGT, strSequenceName, strExperimentName, strUpdatedResultsFile, strFileSeekRoot)   
if exist('strUpdatedResultsFile','var') && ~isempty(strUpdatedResultsFile)
    strctUpdatedTrackingResult = load(strUpdatedResultsFile);
    bUseUpdated = true;
else
    bUseUpdated = false;
end;


% First time stamp?
astrctFileSeekFiles = dir([strFileSeekRoot,'\*.mat']);
fFirstTS = Inf;
fLastTS = 0;
for k=1:length(astrctFileSeekFiles)
    strctTmp = load([strFileSeekRoot, astrctFileSeekFiles(k).name]);
    a2fRange(k,:) = [min(strctTmp.afTimestamp(:)), max(strctTmp.afTimestamp(:))];
    aiNumFrames(k) = length(strctTmp.afTimestamp);
    fFirstTS= min(fFirstTS, min(strctTmp.afTimestamp(:)));
    fLastTS = max(fLastTS,max(strctTmp.afTimestamp(:)));
end
[afDummy, aiInd] = sort(a2fRange(:,1));
aiNumFramesSorted = aiNumFrames(aiInd);
afStartTimeStamp = a2fRange(aiInd,1);
aiFrameOffset = cumsum([0,aiNumFramesSorted]);

strctFileSeek = load([strFileSeekRoot,strSequenceName,'.mat']);
iSeqIndex = find(afStartTimeStamp == strctFileSeek.afTimestamp(1));
iFrameOffset = aiFrameOffset(iSeqIndex);

iNumMice = 4;
acStatus = {strctGT.astrctGT.m_strDescr};
abHuddling = zeros(1, length(strctGT.astrctGT)) > 0;
for k=1:length(strctGT.astrctGT)
    abHuddling(k) = ~isempty(strctGT.astrctGT(k).m_bHuddling) && strctGT.astrctGT(k).m_bHuddling;
end

aiValid = find(ismember(acStatus,'Checked') | ismember(acStatus,'Failed Seg'));
a2iPermutation = cat(1,strctGT.astrctGT(aiValid).m_aiPerm);  % Tracker to Ground truth
abBadAnnotation = zeros(1,size(a2iPermutation,1)) > 0;
for k=1:size(a2iPermutation,1)
   for j=1:4
       aiError(j) = sum(a2iPermutation(k,:) == j);
   end
   abBadAnnotation(k) = sum(aiError > 1) > 0;
end
aiValid=aiValid(~abBadAnnotation);


aiFrames = cat(1,strctGT.astrctGT(aiValid).m_iFrame);
% Sanity check....
% strctMov = fnReadSeqInfo(['T:\Data\Movies\Experiment1\',acSeqNames{iIter},'.seq']);
%
a2iPermutation = cat(1,strctGT.astrctGT(aiValid).m_aiPerm);  % Tracker to Ground truth
% i.e. [2,1,3,4] means that tracker 1 is actualy idenity 2
strctGroundTruth.m_strExperiment = strExperimentName;
strctGroundTruth.m_strSequenceName = strSequenceName;
strctGroundTruth.m_aiFrames= aiFrames;
strctGroundTruth.m_aiFramesRelativeToExpStart= aiFrames+iFrameOffset;

strctGroundTruth.m_afTimestamps = strctFileSeek.afTimestamp(aiFrames)-fFirstTS;
strctGroundTruth.m_afTS_Range = [fFirstTS, fLastTS];
iNumValidAnnotatedFrames = length(aiValid);
strctGroundTruth.m_astrctCorrectPosition.m_a2fX = zeros(iNumValidAnnotatedFrames, iNumMice);
strctGroundTruth.m_astrctCorrectPosition.m_a2fY = zeros(iNumValidAnnotatedFrames, iNumMice);
strctGroundTruth.m_astrctCorrectPosition.m_a2fA = zeros(iNumValidAnnotatedFrames, iNumMice);
strctGroundTruth.m_astrctCorrectPosition.m_a2fB = zeros(iNumValidAnnotatedFrames, iNumMice);
strctGroundTruth.m_astrctCorrectPosition.m_a2fTheta = zeros(iNumValidAnnotatedFrames, iNumMice);
abFailedSeg = ismember(acStatus,'Failed Seg');
strctGroundTruth.m_iNumFailedSegFrames = sum(abFailedSeg);
strctGroundTruth.m_abHuddling = abHuddling(aiValid);
strctGroundTruth.m_abFailedSeg = abFailedSeg(aiValid);

for k=1:iNumValidAnnotatedFrames
    
    aiPerm = zeros(1,iNumMice);
    for j=1:iNumMice
        Idx =  find(a2iPermutation(k,:) == j);
        if ~isempty(Idx)
            aiPerm(j) = Idx;
        end;
    end
    
    for iMouseIter=1:iNumMice
        if aiPerm(iMouseIter) == 0
        strctGroundTruth.m_astrctCorrectPosition.m_a2fX(k,iMouseIter) = NaN;
        strctGroundTruth.m_astrctCorrectPosition.m_a2fY(k,iMouseIter) = NaN;
        strctGroundTruth.m_astrctCorrectPosition.m_a2fA(k,iMouseIter) = NaN;
        strctGroundTruth.m_astrctCorrectPosition.m_a2fB(k,iMouseIter) = NaN;
        strctGroundTruth.m_astrctCorrectPosition.m_a2fTheta(k,iMouseIter) = NaN;
        else            
        strctGroundTruth.m_astrctCorrectPosition.m_a2fX(k,iMouseIter) =  strctGT.astrctTrackers(aiPerm(iMouseIter)).m_afX( aiFrames(k));
        strctGroundTruth.m_astrctCorrectPosition.m_a2fY(k,iMouseIter) =  strctGT.astrctTrackers(aiPerm(iMouseIter)).m_afY(aiFrames(k));
        strctGroundTruth.m_astrctCorrectPosition.m_a2fA(k,iMouseIter) =  strctGT.astrctTrackers(aiPerm(iMouseIter)).m_afA(aiFrames(k));
        strctGroundTruth.m_astrctCorrectPosition.m_a2fB(k,iMouseIter) =  strctGT.astrctTrackers(aiPerm(iMouseIter)).m_afB(aiFrames(k));
        strctGroundTruth.m_astrctCorrectPosition.m_a2fTheta(k,iMouseIter) =  strctGT.astrctTrackers(aiPerm(iMouseIter)).m_afTheta(aiFrames(k));
        end
        
        % Load tracking results for cage 11 ground truth
        % cage 11 is a special case....
        % take tracking information directly from the big ground truth file....
        %
        % Augment the astrctGroundTruth data strcture with the actual tracking
        % result...
        if bUseUpdated
            strctGroundTruth.m_astrctTrackers.m_a2fX(k,iMouseIter) =  strctUpdatedTrackingResult.astrctTrackers(iMouseIter).m_afX(aiFrames(k));
            strctGroundTruth.m_astrctTrackers.m_a2fY(k,iMouseIter) =  strctUpdatedTrackingResult.astrctTrackers(iMouseIter).m_afY(aiFrames(k));
            strctGroundTruth.m_astrctTrackers.m_a2fA(k,iMouseIter) =  strctUpdatedTrackingResult.astrctTrackers(iMouseIter).m_afA(aiFrames(k));
            strctGroundTruth.m_astrctTrackers.m_a2fB(k,iMouseIter) =  strctUpdatedTrackingResult.astrctTrackers(iMouseIter).m_afB(aiFrames(k));
            strctGroundTruth.m_astrctTrackers.m_a2fTheta(k,iMouseIter) =  strctUpdatedTrackingResult.astrctTrackers(iMouseIter).m_afTheta(aiFrames(k));
        else
            strctGroundTruth.m_astrctTrackers.m_a2fX(k,iMouseIter) =  strctGT.astrctTrackers(iMouseIter).m_afX(aiFrames(k));
            strctGroundTruth.m_astrctTrackers.m_a2fY(k,iMouseIter) =  strctGT.astrctTrackers(iMouseIter).m_afY(aiFrames(k));
            strctGroundTruth.m_astrctTrackers.m_a2fA(k,iMouseIter) =  strctGT.astrctTrackers(iMouseIter).m_afA(aiFrames(k));
            strctGroundTruth.m_astrctTrackers.m_a2fB(k,iMouseIter) =  strctGT.astrctTrackers(iMouseIter).m_afB(aiFrames(k));
            strctGroundTruth.m_astrctTrackers.m_a2fTheta(k,iMouseIter) =  strctGT.astrctTrackers(iMouseIter).m_afTheta(aiFrames(k));
        end
        
    end
end
