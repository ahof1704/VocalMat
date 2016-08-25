strctGT = load('D:\Data\Janelia Farm\GroundTruth\Sager\GroundTruth_seg1_complete_UnRandomized.mat');
strctAlg = load('D:\Data\Janelia Farm\Results\10.04.19.390\SequenceViterbi_21-May-2010_Pen_-300.mat');
strctMovInfo = fnReadVideoInfo('M:\Data\Movies\Experiment1\10.04.19.390.seq');
% Display key frames


a2iPerms = cat(1,strctGT.astrctGT.m_aiPerm);
iNumKeyFrames = size(a2iPerms,1);
iNumMice = length(strctGT.astrctTrackers);
aiKeyFrames = cat(1,strctGT.astrctGT.m_iFrame);
aiKeyframesWithCorrectSegmentation = find(sum(a2iPerms >0,2) == iNumMice);
a2iAssignment = zeros(length(aiKeyframesWithCorrectSegmentation),iNumMice);

for iKeyFrameIter=1:length(aiKeyframesWithCorrectSegmentation)
    iKeyFrameIndex = aiKeyframesWithCorrectSegmentation(iKeyFrameIter);
    iSelectedFrame = aiKeyFrames(iKeyFrameIndex);
    
    
    astrctTrackersAlg =  fnGetTrackersAtFrame(strctAlg.astrctTrackers, iSelectedFrame);
    Tmp = fnGetTrackersAtFrame(strctGT.astrctTrackers, iSelectedFrame);
    astrctTrackersGT = Tmp(a2iPerms(iKeyFrameIndex,:));
    
    [aiAssignment, fMaxMatchDist] = fnMatchJobToPrevFrame(astrctTrackersGT, astrctTrackersAlg);
    
    a2iAssignment(iKeyFrameIter,aiAssignment(1,:)) = aiAssignment(2,:);
    
    % a2iFrame = fnReadFrameFromSeq(strctMovInfo,iSelectedFrame);
    % figure(2);
    % clf;
    % imshow(a2iFrame,[]);
    % hold on;
    % fnDrawTrackers2(astrctTrackersGT);
    % fnDrawTrackers6(astrctTrackersAlg);
    
end

iNumCorrect = sum(sum(a2iAssignment == repmat(1:iNumMice, size(a2iAssignment,1),1),2) == iNumMice);
iNumIncorrect = sum(sum(a2iAssignment == repmat(1:iNumMice, size(a2iAssignment,1),1),2) ~= iNumMice);

fprintf('Final Keyframe performance : %.2f \n',iNumCorrect/(iNumCorrect+iNumIncorrect)*100);
