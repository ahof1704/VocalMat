%strResultsFolder = 'D:\Data\Janelia Farm\NewResults\10.04.19.390\';
strResultsFolder = 'D:\Data\Janelia Farm\Results\10.04.19.390_cropped_120-175\';
strAdditionalInfoFile = 'D:\Data\Janelia Farm\Setups\Setup.Experiment1.New.mat';

load(strAdditionalInfoFile)

astrctJobs = dir([strResultsFolder,'JobOut*.mat']);
iNumJobs = length(astrctJobs);

% Load the last one, just to get some data...
strctTmp = load([strResultsFolder,'JobOut',num2str(iNumJobs),'.mat']);
aiJobs = 1:iNumJobs;
if strctTmp.strctJobInfo.m_aiFrameInterval(1) == 1
    strctTmp = load([strResultsFolder,'JobOut',num2str(iNumJobs-1),'.mat']);
    aiJobs = [iNumJobs,1:iNumJobs-1];
end;

iNumMice = length(strctTmp.astrctTrackersJob);
iNumFrames = strctTmp.strctJobInfo.m_aiFrameInterval(end);
iMaxIntervalForAutomaticInterpolation = 8;
iNumClassifiers = size(strctAdditionalInfo.m_strctMiceIdentityClassifier.a2fW,2);
astrctTrackers = fnCreateEmptyTrackStruct(iNumMice, iNumFrames, false,iNumClassifiers);

a3fClassifiersResult = zeros(iNumMice, iNumClassifiers, iNumFrames,'single');

abBadMerges = zeros(1,iNumJobs)>0;
aiStartFrame = zeros(1,iNumJobs);
afMaxDist = zeros(1,iNumJobs);
for iJobIter=aiJobs
    fprintf('Merging job %d out of %d\n',iJobIter,iNumJobs);
    strctJob = load([strResultsFolder,'JobOut',num2str(iJobIter),'.mat']);
    aiFrames = strctJob.strctJobInfo.m_aiFrameInterval;
    aiStartFrame(iJobIter) = aiFrames(1);

    astrctTrackersAtFrame = fnGetTrackersAtFrame(astrctTrackers, aiFrames(1));
    astrctTrackersJobAtFrame = fnGetTrackersAtFrame(strctJob.astrctTrackersJob, 1);

    bNaNAtMerge = false;
    for k=1:length(astrctTrackersAtFrame)
        bNaNAtMerge = bNaNAtMerge | isnan(astrctTrackersAtFrame(k).m_fX);
    end;
    % Match mouse position...
    [aiAssignment,afMaxDist(iJobIter)] = fnMatchJobToPrevFrame(astrctTrackersAtFrame, astrctTrackersJobAtFrame);

    if bNaNAtMerge && aiFrames(1) ~= 1
        fprintf('CRITICAL WARNING: please check what happened at frame %d\n',aiFrames(1));
        abBadMerges(iJobIter) = 1;
    end;


    for iMouseIter=1:iNumMice
        iTracker = aiAssignment(1,iMouseIter);
        iMatchedTracker = aiAssignment(2,iMouseIter);
        astrctTrackers(iTracker).m_afX(aiFrames) = ...
            strctJob.astrctTrackersJob(iMatchedTracker).m_afX(1:length(aiFrames));
        astrctTrackers(iTracker).m_afY(aiFrames) = ...
            strctJob.astrctTrackersJob(iMatchedTracker).m_afY(1:length(aiFrames));
        astrctTrackers(iTracker).m_afA(aiFrames) = ...
            strctJob.astrctTrackersJob(iMatchedTracker).m_afA(1:length(aiFrames));
        astrctTrackers(iTracker).m_afB(aiFrames) = ...
            strctJob.astrctTrackersJob(iMatchedTracker).m_afB(1:length(aiFrames));
        astrctTrackers(iTracker).m_afTheta(aiFrames) = ...
            strctJob.astrctTrackersJob(iMatchedTracker).m_afTheta(1:length(aiFrames));

        %astrctTrackers(iTracker).m_astrctClass(aiFrames) = ...
        %    strctJob.astrctTrackersJob(iMatchedTracker).m_astrctClass(1:length(aiFrames));
        a2fClass = cat(1,strctJob.astrctTrackersJob(iMatchedTracker).m_astrctClass.m_afValue)';
        a3fClassifiersResult(iTracker,:, aiFrames) = a2fClass;% * 1e4;

    end;
    
    
    %    abHasValues = ~isnan(strctJob.astrctTrackersJob(iMatchedTracker).m_afX);

    % Interpolate short intervals of missing frames
    for iMouseIter=1:iNumMice
        astrctIntervals = fnGetIntervals( isnan(astrctTrackers(iMouseIter).m_afX(aiFrames)));
        for iIntervalIter=1:length(astrctIntervals)
            if astrctIntervals(iIntervalIter).m_iLength < iMaxIntervalForAutomaticInterpolation
                iLeftFrame = max(1,aiFrames(astrctIntervals(iIntervalIter).m_iStart)-1);
                iRightFrame = min(iNumFrames,aiFrames(astrctIntervals(iIntervalIter).m_iEnd)+1);
                astrctTrackers = fnInterpolateBetweenFrames(...
                    astrctTrackers, iMouseIter, iLeftFrame, iRightFrame, false);
            end;
        end;
    end;
end;

%
figure(11);
clf;
hold on;
strCol='rgbcym';
for k=1:iNumMice
    plot(sqrt(diff(astrctTrackers(k).m_afX).^2+diff(astrctTrackers(k).m_afY).^2),strCol(k));
end;
%

fMaxDistThres = 50;

strOutput = [strResultsFolder,'SequenceRAW.mat'];
strMovieFileName = strctTmp.strctJobInfo.m_strMovieFileName;
if isfield(strctTmp.strctJobInfo,'m_strAdditionalInfoFile')
    strctAdditionalInfo = strctTmp.strctJobInfo.m_strAdditionalInfoFile;
else
    strctAdditionalInfo = [];
end;

fprintf('Writing to disk...');
save(strOutput,'astrctTrackers','strMovieFileName','strctAdditionalInfo','a3fClassifiersResult','-V6');
fprintf('Done!\n');

fprintf('Final Summary\n');
fprintf('Incorrect merges due to lost mice:');
aiBadMerges = find(abBadMerges);
if isempty(aiBadMerges)
    fprintf('None!\n');
else
    fprintf('\n');
end;
for k=1:length(aiBadMerges)
    fprintf('Bad job at %d, starting frame %d\n',aiBadMerges(k), aiStartFrame(aiBadMerges(k)));
end;

fprintf('Incorrect merges due to tracking errors:');
aiBadTracks = find(afMaxDist > fMaxDistThres);
if isempty(aiBadTracks)
    fprintf('None!\n');
else
    fprintf('\n');
end;

for k=1:length(aiBadTracks)
    fprintf('Bad job at %d, starting frame %d\n',aiBadTracks(k), aiStartFrame(aiBadTracks(k)));
end;

%% Run Viterbi
a2iAllStates = fliplr(perms(1:iNumMice));
load(strAdditionalInfoFile)
%a2fMu = strctAdditionalInfo.m_strctMiceIdentityClassifier.a2fMu;
%a2fSig = strctAdditionalInfo.m_strctMiceIdentityClassifier.a2fSig;
%[a2fLikelihood] = fnViterbiLikelihood(a2iAllStates',a3fClassifiersResult, a2fMu, a2fSig);

a2fX = strctAdditionalInfo.m_strctMiceIdentityClassifier.a2fX;
a2fConfPos = strctAdditionalInfo.m_strctMiceIdentityClassifier.a2fConfPos;
a2fConfNeg = strctAdditionalInfo.m_strctMiceIdentityClassifier.a2fConfNeg;

tic
a2fLogProb = fnViterbiProbObsAllStates2(a2iAllStates, a3fClassifiersResult, a2fX, a2fConfPos, a2fConfNeg);
toc


%[a2fLikelihood] = fnViterbiLikelihood(a2iAllStates',a3fClassifiersResult, a2fX, a2fConfPos,a2fConfNeg);
a2fLikelihood = bsxfun(@rdivide, exp(a2fLogProb), sum(exp(a2fLogProb),1));


X = cat(1,astrctTrackers.m_afX);
Y = cat(1,astrctTrackers.m_afY);
A = cat(1,astrctTrackers.m_afA);
B = cat(1,astrctTrackers.m_afB);
Theta = cat(1,astrctTrackers.m_afTheta);

a3bIntersections =fnEllipseEllipseIntersectionMex((X),(Y),(A),(B),(Theta));
[a2iPairToCol,a2iSwapLookup]=fnGenerateLookupsForTransition(iNumMice);
fSwapPenalty = -500;
a3fTransitions = fnViterbiTransition(a3bIntersections, a2iPairToCol, a2iSwapLookup, fSwapPenalty);

aiPath = fndllViterbi(a3fTransitions,a2fLogProb);

figure;plot(aiPath)