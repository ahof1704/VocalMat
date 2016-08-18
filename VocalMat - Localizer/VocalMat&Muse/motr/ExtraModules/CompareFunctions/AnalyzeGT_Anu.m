n = 4;

acGTfiles = {'GroundTruth_b6_pop_cage_14_12.02_10_09.52.04.882_complete.seq.mat',...
   'GroundTruth_b6_pop_cage_14_12.02_10_09.52.04.882.new2448.mat',...
   'GroundTruth_b6_pop_cage_14_12.03.10_09.52.07.992._newcomplete.seq_UnRandomized.mat',...
   'GroundTruth_b6_popcage_16_110405_09.58.30.268.seq._5808_UnRandomized.mat'};

acRes = {'G/Results/Tracks/b6_pop_cage_14_12.02.10_09.52.04.882.mat',...
   'G/Results/Tracks/b6_pop_cage_14_12.02.10_09.52.04.882.mat',...
   'G/Results/Tracks/b6_pop_cage_14_12.03.10_09.52.07.992.mat',...
   'G16full/Results/Tracks/b6_popcage_16_110405_09.58.30.268.mat'};
%   '/groups/egnor/mousetrack/mousetrack_16/Results/Tracks/b6_popcage_16_110405_09.58.30.268.mat'};

acMovies = {'/groups/egnor/mousetrack/mousetrack_G/BCAM/b6_pop_cage_14_12.02.10_09.52.04.882.seq',...
   '/groups/egnor/mousetrack/mousetrack_G/BCAM/b6_pop_cage_14_12.02.10_09.52.04.882.seq',...
   '/groups/egnor/mousetrack/mousetrack_G/BCAM/b6_pop_cage_14_12.03.10_09.52.07.992.seq',...
   '/groups/egnor/mousetrack/mousetrack_16/b6_popcage_16_110405_09.58.30.268.seq'};

strctGT = load(['/groups/egnor/mousetrack/FinalGroundTruth/' acGTfiles{n}]);
strctRes = load(['/groups/egnor/home/avnio/MouseHouseExperiments/' acRes{n}]);
strctMovie = fnReadVideoInfo(acMovies{n});

%strctGT = load('/groups/egnor/mousetrack/ground truthed files for shay/GroundTruth_b6_popcage_16_110405_09.58.30.268.seq._5808_UnRandomized.mat');
%strctGT = load('/groups/egnor/home/avnio/GroundTruth/GroundTruth_b6_pop_cage_14_12.02_10_09.52.04.882.new2448.mat');
%strctGT = load('/groups/egnor/mousetrack/ground truthed files for shay/GroundTruth_b6_pop_cage_14_12.03.10_09.52.07.992._newcomplete.seq_UnRandomized.mat');
%strctGT = load('/groups/egnor/home/avnio/GroundTruth/GroundTruth_b6_pop_cage_14_12.03.10_09.52.07.992_complete.seq_UnRandomized.mat');
%strctGT = load('/groups/egnor/home/avnio/GroundTruth/GroundTruth_b6_pop_cage_14_12.03.10_09.52.07.992.seq._new3183_UnRandomized.mat');
%strctGT = load('/groups/egnor/home/avnio/GroundTruth/GroundTruth_b6_pop_cage_14_12.03.10_09.52.07.992_4842.seq_UnRandomized.mat');
%strctGT = load('D:\Data\Janelia Farm\GroundTruth\Anu\GroundTruth_b6_pop_cage_14_12.02_10_09.52.04.882_2683.seq.mat');
%strctGT = load('/groups/egnor/home/avnio/GroundTruth/GroundTruth_b6_pop_cage_14_12.02_10_09.52.04.882_complete.seq.mat');
%strctMovie = fnReadVideoInfo('E:\JaneliaMovies\b6_pop_cage_14_12.02.10_09.52.04.882.seq');
%strctMovie = fnReadVideoInfo('/groups/egnor/mousetrack/mousetrack_G/BCAM/b6_pop_cage_14_12.03.10_09.52.07.992.seq');
%strctMovie = fnReadVideoInfo('/groups/egnor/mousetrack/mousetrack_16/b6_popcage_16_110405_09.58.30.268.seq');
%strctRes = load('D:\Data\Janelia Farm\ResultsLDA_Logistic\b6_pop_cage_14_12.02.10_09.52.04.882\SequenceViterbi.mat');
%strctRes = load('/groups/egnor/home/avnio/MouseHouseExperiments/G/Results/Tracks/b6_pop_cage_14_12.03.10_09.52.07.992.mat');
%strctRes = load('/groups/egnor/home/avnio/Results_RobustClassifiers/b6_pop_cage_14_12.03.10_09.52.07.992/SequenceViterbi.mat');
%strctRes = load('/groups/egnor/home/avnio/Results_RobustClassifiers/b6_pop_cage_14_12.02.10_09.52.04.882/SequenceViterbi.mat');
%strctRes = load('/groups/egnor/home/avnio/MouseHouseExperiments/G16full/Results/Tracks/b6_popcage_16_110405_09.58.30.268.mat');

acstrDescr = {strctGT.astrctGT.m_strDescr};

bConfLevelLabelled = false;
bHeadTailLabelled = false;
bHuddlingLabelExists = isfield(strctGT.astrctGT, 'm_bHuddling');

acUniqueDescr = unique(acstrDescr);
aiOptionalHuddling = [];
bNoHuddlingPrint = true;
for i=1:length(acUniqueDescr)
   abIsDescr = ismember(acstrDescr,acUniqueDescr{i});
   if bHuddlingLabelExists
      acHuddling = {strctGT.astrctGT.m_bHuddling};
      aiOptionalHuddling = find(~cellfun('isempty',acHuddling));
      aiHuddling = cellfun(@(x) x==1, acHuddling(aiOptionalHuddling));
      aiHuddling = aiOptionalHuddling(aiHuddling);
   end
   if length(aiOptionalHuddling)>0
      fprintf('%d key frames have status %s of which %d include huddling\n',sum(abIsDescr),acUniqueDescr{i},sum(abIsDescr(aiHuddling)));
   else
      if bNoHuddlingPrint
         fprintf('No Huddling was labelled\n');
         bNoHuddlingPrint = false;
      end
      fprintf('%d key frames have status %s\n', sum(abIsDescr),acUniqueDescr{i});
   end
end
DISPLAY_INCORRECT = false;

% Go over each key frame that has status "Failed Seg"
if DISPLAY_INCORRECT
   % aiFailedSeg = setdiff(find(ismember(acstrDescr,'Failed Seg')), aiHuddling);
   aiFailedSeg = find(ismember(acstrDescr,'Failed Seg'));
   iNumFailedSeg = length(aiFailedSeg);
   for iIter=1:iNumFailedSeg
      iKeyFrameIndex = aiFailedSeg(iIter);
      if ~isfield(strctGT.astrctGT(iKeyFrameIndex), 'm_bHuddling') || ~isempty(strctGT.astrctGT(iKeyFrameIndex).m_bHuddling) % || strctGT.astrctGT(iKeyFrameIndex).m_bHuddling
         continue;
      end
      
      iFrame = strctGT.astrctGT(iKeyFrameIndex).m_iFrame;
      astrctTrackersPos_GT = fnGetTrackersAtFrame(strctGT.astrctTrackers,iFrame);
      
      astrctTrackersPos_Viterbi = fnGetTrackersAtFrame(strctRes.astrctTrackers,iFrame);
      a2iFrame = fnReadFrameFromVideo(strctMovie, iFrame);
      figure(11);
      clf;
      subplot(1,2,1);
      imshow(a2iFrame,[]);
      hold on;
      fnDrawTrackers(astrctTrackersPos_GT);
      title(sprintf('GROUND TRUTH Keyframe %d (frame %d)',iKeyFrameIndex,iFrame));
      subplot(1,2,2);
      imshow(a2iFrame,[]);
      hold on;
      fnDrawTrackers(astrctTrackersPos_Viterbi);
      title(sprintf('VITERBI Keyframe %d (frame %d)',iKeyFrameIndex,iFrame));
      if isfield(strctGT.astrctGT(iKeyFrameIndex), 'm_bHuddling') && ~isempty(strctGT.astrctGT(iKeyFrameIndex).m_bHuddling)
         if strctGT.astrctGT(iKeyFrameIndex).m_bHuddling
            display('Hudlling');
         else
            display('No Hudlling');
         end
      else
         display('Hudlling undefined');
      end
      pause;
   end
end
%display('Done');
%pause;
% Go over each key frame that has status "checked"
aiChecked = find(ismember(acstrDescr,'Checked'));
iNumChecked = length(aiChecked);
a2iCorrectPerm = zeros(iNumChecked,4);
a2iCorrectPermUD = [];
a2iCorrectPermLow = [];
a2iCorrectPermMid = [];
a2iCorrectPermHigh = [];
a2iCorrectPermHuddle = [];
iNumHeadTailSwap = 0;
iNumHeadTailSwapHuddling = 0;
iNumNeitherHeadTail = 0;
iNumNeitherHeadTailHuddling = 0;
for iIter=1:iNumChecked
   iKeyFrameIndex = aiChecked(iIter);
   iFrame = strctGT.astrctGT(iKeyFrameIndex).m_iFrame;
   aiPerm = strctGT.astrctGT(iKeyFrameIndex).m_aiPerm;
   
   aiPermInv = zeros(1,4);
   for k=1:4
      aiPermInv(k)=find(aiPerm==k);
   end
   
   astrctTrackersPos_GT_Tmp = fnGetTrackersAtFrame(strctGT.astrctTrackers,iFrame);
   astrctTrackersPos_GT = astrctTrackersPos_GT_Tmp(aiPermInv);
   
   astrctTrackersPos_Viterbi = fnGetTrackersAtFrame(strctRes.astrctTrackers,iFrame);
   
   a2iMatch = fnMatchJobToPrevFrame(astrctTrackersPos_Viterbi,astrctTrackersPos_GT);
   a2iCorrectPerm(iIter,:) = a2iMatch(2,:);
   if isfield(strctGT.astrctGT(iKeyFrameIndex), 'm_iIdConfLevel')
      iIdConfLevel = strctGT.astrctGT(iKeyFrameIndex).m_iIdConfLevel;
      bConfLevelLabelled = true;
   else
      iIdConfLevel = 0;
   end
   if isempty(iIdConfLevel)
      iIdConfLevel = 0;
   end
   
   switch iIdConfLevel
      case 0
         a2iCorrectPermUD = [a2iCorrectPermUD; a2iMatch(2,:)];
      case 1
         a2iCorrectPermLow = [a2iCorrectPermLow; a2iMatch(2,:)];
      case 2
         a2iCorrectPermMid = [a2iCorrectPermMid; a2iMatch(2,:)];
      case 3
         a2iCorrectPermHigh = [a2iCorrectPermHigh; a2iMatch(2,:)];
   end
   bHuddling = isfield(strctGT.astrctGT(iKeyFrameIndex), 'm_bHuddling') && ~isempty(strctGT.astrctGT(iKeyFrameIndex).m_bHuddling) && strctGT.astrctGT(iKeyFrameIndex).m_bHuddling==true;
   if bHuddling
      a2iCorrectPermHuddle = [a2iCorrectPermHuddle; a2iMatch(2,:)];
   end
   iHeadTailSwap = 0;
   if isfield(strctGT.astrctGT(iKeyFrameIndex), 'm_abHeadTailSwap') && ~isempty(strctGT.astrctGT(iKeyFrameIndex).m_abHeadTailSwap)
      bHeadTailLabelled = true;
      iHeadTailSwap = sum(strctGT.astrctGT(iKeyFrameIndex).m_abHeadTailSwap);
   end
   iNeitherHeadTail = 0;
   if isfield(strctGT.astrctGT(iKeyFrameIndex), 'm_abNeitherHeadTail') && ~isempty(strctGT.astrctGT(iKeyFrameIndex).m_abNeitherHeadTail)
      bHeadTailLabelled = true;
      iNeitherHeadTail = sum(strctGT.astrctGT(iKeyFrameIndex).m_abNeitherHeadTail);
   end
   iNumHeadTailSwap = iNumHeadTailSwap + iHeadTailSwap;
   iNumHeadTailSwapHuddling = iNumHeadTailSwapHuddling + (iHeadTailSwap * bHuddling);
   iNumNeitherHeadTail = iNumNeitherHeadTail + iNeitherHeadTail;
   iNumNeitherHeadTailHuddling = iNumNeitherHeadTailHuddling + (iNeitherHeadTail * bHuddling);
   
   if ~all(a2iCorrectPerm(iIter,:) == [1,2,3,4]) && DISPLAY_INCORRECT
      a2iFrame = fnReadFrameFromVideo(strctMovie, iFrame);
      figure(11);
      clf;
      subplot(1,2,1);
      imshow(a2iFrame,[]);
      hold on;
      fnDrawTrackers(astrctTrackersPos_GT);
      strInfo = [''];
      if bHuddling, strInfo = [strInfo ' Huddling ']; end;
      if iHeadTailSwap>0, strInfo = [strInfo ' HeadTailSwap ']; end;
      if iNeitherHeadTail>0, strInfo = [strInfo ' NeitherHeadTail ']; end;
      title(sprintf('GROUND TRUTH Keyframe %d (frame %d), %s',iKeyFrameIndex,iFrame, strInfo));
      subplot(1,2,2);
      imshow(a2iFrame,[]);
      hold on;
      fnDrawTrackers(astrctTrackersPos_Viterbi);
      title(sprintf('VITERBI Keyframe %d (frame %d)',iKeyFrameIndex,iFrame));
      pause
   end
end

aiIncorrectPermFromChecked = find(sum( abs(a2iCorrectPerm - repmat([1,2,3,4],iNumChecked,1)),2));
fprintf('%d incorrect frames were found! (%.2f %%) \n',length(aiIncorrectPermFromChecked), length(aiIncorrectPermFromChecked) / iNumChecked*100)
iNumHuddling = size(a2iCorrectPermHuddle,1);
if iNumHuddling>0
   aiIncorrectPermFromHuddling = find(sum( abs(a2iCorrectPermHuddle - repmat([1,2,3,4],iNumHuddling,1)),2));
   fprintf('out of which %d include huddling (%.2f %% of all huddling frames) \n', length(aiIncorrectPermFromHuddling), length(aiIncorrectPermFromHuddling)/iNumHuddling*100)
end
if bConfLevelLabelled
   iNumUD = size(a2iCorrectPermUD,1);
   if iNumUD>0
      aiIncorrectPermFromUD = find(sum( abs(a2iCorrectPermUD - repmat([1,2,3,4],iNumUD,1)),2));
      fprintf('%d incorrect undefined-confidence frames were found! (%.2f %%) \n',length(aiIncorrectPermFromUD), length(aiIncorrectPermFromUD) / iNumUD*100)
   end
   iNumLow = size(a2iCorrectPermLow,1);
   if iNumLow>0
      aiIncorrectPermFromLow = find(sum( abs(a2iCorrectPermLow - repmat([1,2,3,4],iNumLow,1)),2));
      fprintf('%d incorrect low confidence frames were found! (%.2f %%) \n',length(aiIncorrectPermFromLow), length(aiIncorrectPermFromLow) / iNumLow*100)
   end
   iNumMid = size(a2iCorrectPermMid,1);
   if iNumMid>0
      aiIncorrectPermFromMid = find(sum( abs(a2iCorrectPermMid - repmat([1,2,3,4],iNumMid,1)),2));
      fprintf('%d incorrect mid confidence frames were found! (%.2f %%) \n',length(aiIncorrectPermFromMid), length(aiIncorrectPermFromMid) / iNumMid*100)
   end
   iNumHigh = size(a2iCorrectPermHigh,1);
   if iNumHigh>0
      aiIncorrectPermFromHigh = find(sum( abs(a2iCorrectPermHigh - repmat([1,2,3,4],iNumHigh,1)),2));
      fprintf('%d incorrect high confidence frames were found! (%.2f %%) \n',length(aiIncorrectPermFromHigh), length(aiIncorrectPermFromHigh) / iNumHigh*100)
   end
else
   fprintf('No confidence level was labelled\n');
end
if bHeadTailLabelled && iNumHeadTailSwap+iNumNeitherHeadTail>0
   fprintf('%d incorrect orientations were found! (%.2f %%) \n',iNumHeadTailSwap+iNumNeitherHeadTail, (iNumHeadTailSwap+iNumNeitherHeadTail) / (4*iNumChecked) *100)
   fprintf('out of which %d (%.2f %%) are Head-Tail swaps \n',iNumHeadTailSwap, iNumHeadTailSwap/(iNumHeadTailSwap+iNumNeitherHeadTail) *100)
   fprintf('%d incorrect orientations were found while huddling! (%.2f %% of Huddling frames) \n',iNumHeadTailSwapHuddling+iNumNeitherHeadTailHuddling, (iNumHeadTailSwapHuddling+iNumNeitherHeadTailHuddling) / (4*iNumHuddling) *100)
   fprintf('out of which %d (%.2f %%) are Head-Tail swaps \n',iNumHeadTailSwapHuddling, iNumHeadTailSwapHuddling/(iNumHeadTailSwapHuddling+iNumNeitherHeadTailHuddling) *100)
else
   fprintf('No Head-Tail labelled\n');
end

