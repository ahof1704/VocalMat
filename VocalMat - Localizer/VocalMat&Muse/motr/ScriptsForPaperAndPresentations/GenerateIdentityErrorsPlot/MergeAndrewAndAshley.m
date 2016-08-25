% Merge Andrew and Ashley's ground truth data.
% Take only annotations that were consistent

    acSeqNames = {'b6_popcage_18_09.15.11_10.56.24.135','b6_popcage_18_09.15.11_22.56.24.848','b6_popcage_18_09.17.11_10.56.27.049',...
        'b6_popcage_18_09.17.11_22.56.27.802','b6_popcage_18_09.19.11_10.56.29.998','b6_popcage_18_09.19.11_22.56.30.748'};
    clear strctGT
    strctGT1.astrctGT(1) = load('D:\Data\Janelia Farm\GroundTruth\popcage18gt_andrew\Unrandom\b6_popcage_18_09.15.11_10.56.24.135.mat');
    strctGT1.astrctGT(2) = load('D:\Data\Janelia Farm\GroundTruth\popcage18gt_andrew\Unrandom\b6_popcage_18_09.15.11_22.56.24.848.mat');
    strctGT1.astrctGT(3) = load('D:\Data\Janelia Farm\GroundTruth\popcage18gt_andrew\Unrandom\b6_popcage_18_09.17.11_10.56.27.049.mat');
    strctGT1.astrctGT(4) = load('D:\Data\Janelia Farm\GroundTruth\popcage18gt_andrew\Unrandom\b6_popcage_18_09.17.11_22.56.27.802.mat');
    strctGT1.astrctGT(5) = load('D:\Data\Janelia Farm\GroundTruth\popcage18gt_andrew\Unrandom\b6_popcage_18_09.19.11_10.56.29.998.mat');
    strctGT1.astrctGT(6) = load('D:\Data\Janelia Farm\GroundTruth\popcage18gt_andrew\Unrandom\b6_popcage_18_09.19.11_22.56.30.748.mat');
    
    strctGT2.astrctGT(1) = load('D:\Data\Janelia Farm\GroundTruth\popcage18gt_ashley\Unrandomized\b6_popcage_18_09.15.11_10.56.24.135.mat');
    strctGT2.astrctGT(2) = load('D:\Data\Janelia Farm\GroundTruth\popcage18gt_ashley\Unrandomized\b6_popcage_18_09.15.11_22.56.24.848.mat');
    strctGT2.astrctGT(3) = load('D:\Data\Janelia Farm\GroundTruth\popcage18gt_ashley\Unrandomized\b6_popcage_18_09.17.11_10.56.27.049.mat');
    strctGT2.astrctGT(4) = load('D:\Data\Janelia Farm\GroundTruth\popcage18gt_ashley\Unrandomized\b6_popcage_18_09.17.11_22.56.27.802.mat');
    strctGT2.astrctGT(5) = load('D:\Data\Janelia Farm\GroundTruth\popcage18gt_ashley\Unrandomized\b6_popcage_18_09.19.11_10.56.29.998.mat');
    strctGT2.astrctGT(6) = load('D:\Data\Janelia Farm\GroundTruth\popcage18gt_ashley\Unrandomized\b6_popcage_18_09.19.11_22.56.30.748.mat');
    
    
    for k=1:6
        a2iAndrew = cat(1,strctGT1.astrctGT(k).astrctGT.m_aiPerm);
        a2iAshley = cat(1,strctGT2.astrctGT(k).astrctGT.m_aiPerm);
        
        aiFramesInFile = cat(1,strctGT1.astrctGT(k).astrctGT.m_iFrame);
        
        abRelevantFrames1 = ~ismember({strctGT1.astrctGT(k).astrctGT.m_strDescr},'Not Checked');
        abRelevantFrames2 = ~ismember({strctGT2.astrctGT(k).astrctGT.m_strDescr},'Not Checked');
        abKeyFramesMarkedByTheTwoAnnotators = (abRelevantFrames1 & abRelevantFrames2);
        
        aiFramesMarkedByTheTwo = aiFramesInFile(abKeyFramesMarkedByTheTwoAnnotators);
        
        abMismatchNotFailed = sum(a2iAndrew(abKeyFramesMarkedByTheTwoAnnotators,:) > 0 & ...
        a2iAshley(abKeyFramesMarkedByTheTwoAnnotators,:) > 0 & ...
        a2iAndrew(abKeyFramesMarkedByTheTwoAnnotators,:) ~= a2iAshley(abKeyFramesMarkedByTheTwoAnnotators,:) ,2) > 0;
    
        aiNumMismatchNotFailed(k) = sum(abMismatchNotFailed);
        
        %aiFramesMarkedByTheTwo(abMismatchNotFailed)
    
        aiProbCount(k) = sum(sum(a2iAndrew(abKeyFramesMarkedByTheTwoAnnotators,:) == 0,2) > 0 & ...
            sum(a2iAndrew(abKeyFramesMarkedByTheTwoAnnotators,:) == 0,2) < 4 & ...
            sum(a2iAshley(abKeyFramesMarkedByTheTwoAnnotators,:) == 0,2) == 4);
        
        aiNonConsistentInd = find( sum(a2iAndrew(abKeyFramesMarkedByTheTwoAnnotators,:)==a2iAshley(abKeyFramesMarkedByTheTwoAnnotators,:),2)~=4);
        aiCounter(k) = length(aiNonConsistentInd);
        aiAll(k) = sum(abKeyFramesMarkedByTheTwoAnnotators);
    end
    sum(aiCounter)/sum(aiAll)
    sum(aiProbCount)
        % How many "failed segmentation" andrew had:
%         a2iAndrew(aiNonConsistentInd,:)
%         
%         a2iAshley(aiNonConsistentInd,:)
%         
%         [a2iAndrew(aiNonConsistentInd,:), a2iAshley(aiNonConsistentInd,:)]
        
        
        [a2iAndrew(aiNonConsistentInd,:), a2iAshley(aiNonConsistentInd,:)]
        
        strctGT.astrctGT(k).astrctTrackers = strctGT1.astrctGT(k).astrctTrackers;
        strctGT.astrctGT(k).astrctGT = strctGT1.astrctGT(k).astrctGT;
        fprintf('%d were not consistent\n',length(aiNonConsistentInd));
        for j=1:length(aiNonConsistentInd)
            strctGT.astrctGT(k).astrctGT(aiNonConsistentInd(j)).m_strDescr = 'Not Consistent';
            strctGT.astrctGT(k).astrctGT(aiNonConsistentInd(j)).m_aiPerm = [0 0 0 0];
        end
        
    end
    
        clear astrctGroundTruth
    strFileSeekRoot = 'D:\Data\Janelia Farm\ResultsFromNewTrunk\cage18\SEQ\';
    for iIter=1:6
        % By default, the tracking result is taken from the same version that
        % was used to generate the ground truth data....
        % However, if newer results are available, they can be loaded instead.
        astrctGroundTruth(iIter) = fnGenereateIdentityErrorPlotLoad(strctGT.astrctGT(iIter),acSeqNames{iIter},'cage18',[], strFileSeekRoot);%,['E:\JaneliaResults\cage11\Results\Tracks\',acSeqNames{iIter},'.mat']) ;
    end

    
    
    load('D:\Data\Janelia Farm\ResultsFromNewTrunk\cage18_dist.mat');
a2fDistance(a2fDistance>2000) = NaN;

a2iMinMouseDist = [1,2,3;
 1,4,5;
 2,4,6;
 3,5,6];

fHuddlingThreshold = 7;
for iIter=1:length(astrctGroundTruth)
    for iMouseIter=1:4
        astrctGroundTruth(iIter).m_a2bHuddlingData(iMouseIter,:) = ...
            min(a2fDistance(astrctGroundTruth(iIter).m_aiFramesRelativeToExpStart, a2iMinMouseDist(iMouseIter,:)),[],2) < fHuddlingThreshold;
    end
    astrctGroundTruth(iIter).m_a2bCorrectIdentification = fnGenerateIdentityErrorPlotAuxNew(...
        astrctGroundTruth(iIter).m_astrctCorrectPosition, astrctGroundTruth(iIter).m_astrctTrackers);
    
end


a2bHuddling = cat(2,astrctGroundTruth.m_a2bHuddlingData)';
a2bID= cat(1,astrctGroundTruth.m_a2bCorrectIdentification);

fprintf('%d mice images were annotated\n', length(a2bID(:)));
fprintf('Out of which, %d (%.2f%%) were not segmented properly\n',sum(isnan(a2bID(:))),...
    1e2*sum(isnan(a2bID(:)))/length(a2bID(:)));
iNumCorrectlySegmented = length(a2bID(:)) - sum(isnan(a2bID(:)));
fprintf('Out of the %d correctly segmented images, the identities of %d (%.2f%%) was correct.\n',...
    iNumCorrectlySegmented, sum(a2bID(:) == 1), sum(a2bID(:) == 1)/iNumCorrectlySegmented*1e2)
a2bCorrectlySegmented = ~isnan(a2bID);
fprintf('Out of the %d correctly segmented images, %d (%.2f%%) were of mice huddled togather.\n',...
    sum(a2bCorrectlySegmented(:)),sum(a2bHuddling(a2bCorrectlySegmented)), 1e2*sum(a2bHuddling(a2bCorrectlySegmented))/sum(a2bCorrectlySegmented(:))) ;

%%

    
