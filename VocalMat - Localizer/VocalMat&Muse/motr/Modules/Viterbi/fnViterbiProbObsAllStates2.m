function a2fLogProb = fnViterbiProbObsAllStates2(a2iAllStates, a3fClassifiersResult, a2fX, a2fConfPos, a2fConfNeg)
% Computes the log likelihood of seeing a observation given the system
% state.
%
% Inputes:
%  aiStatePerm - System state, given as a permutation.
%  a2fObs - Observation matrix (NumMice x NumClassifiers)
%  a2fX, a2fConfPos, a2fConfNeg - Adjusted Cumulative density functions of classifiers response.
%
% Outputs:
%  fLogProb - log likelihood
%
%Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

%
%
% strMovie = 'D:\Data\Janelia Farm\Movies\SeqFiles\10.04.19.390_cropped_120-175.seq';
% iNumMice=4;
% strctMovInfo= fnReadSeqInfo(strMovie);
%
% for iFrame = 1:200;
%
% a2iFrame = fnReadFrameFromSeq(strctMovInfo,iFrame);
% figure(12);
% clf;
% imshow(a2iFrame,[]);
% hold on;
% afCol='rgbcym';
% for iMouseIter=1:iNumMice
%     strctTracker=fnGetTrackerAtFrame(astrctTrackers,iMouseIter,iFrame);
%     fnDrawTracker(gca,strctTracker, afCol(iMouseIter), 2, false);
% end;
% a2fObs = a3fClassifiersResult(:,:,iFrame);
%

iNumMice = size(a2iAllStates,2);
a2iPairs = nchoosek(1:iNumMice,2);
iNumFrames = size(a3fClassifiersResult,3);
iNumStates = size(a2iAllStates,1);
fEps = 1e-100;

a2fLogProb = zeros(iNumStates, iNumFrames);

for iFrameIter=1:iNumFrames
    a2fMatchProb = zeros(iNumMice,iNumMice);
    for iTrackerIter=1:iNumMice
        for iTrueID=1:iNumMice

            % Estimate that the patch of tracker (iTrackerIter) belongs to true
            % mice identity iTrueID

            afClassifierValues = a3fClassifiersResult(iTrackerIter,:,iFrameIter);

            aiRelevantPairsPos = find(a2iPairs( a2iPairs(:,1)==iTrueID));
            if ~isempty(aiRelevantPairsPos)
                afPosConf = zeros(1,length(aiRelevantPairsPos));
                for i=1:length(aiRelevantPairsPos)
                    iClassifier = aiRelevantPairsPos(i);
                    afPosConf(i)=interp1(a2fX(:,iClassifier), a2fConfPos(:,iClassifier), afClassifierValues(iClassifier));
                end;
                fProbPos = sum(log(afPosConf+fEps));
            else
                fProbPos = 0;
            end;

            aiRelevantPairsNeg = find(a2iPairs( a2iPairs(:,2)==iTrueID));
            if ~isempty(aiRelevantPairsNeg)
                afNegConf = zeros(1,length(aiRelevantPairsNeg));
                for i=1:length(aiRelevantPairsNeg)
                    iClassifier = aiRelevantPairsNeg(i);
                    afNegConf(i)=interp1(a2fX(:,iClassifier), a2fConfNeg(:,iClassifier), afClassifierValues(iClassifier));
                end;
                fProbNeg = sum(log(afNegConf+fEps));

            else
                fProbNeg = 0;
            end;


            a2fMatchProb(iTrackerIter,iTrueID) = fProbNeg+fProbPos;
        end;
    end;


    % Estimate hypothesis by summing evidence...
    iNumStates = size(a2iAllStates,1);
    for iStateIter=1:iNumStates
        a2fLogProb(iStateIter,iFrameIter) = sum(a2fMatchProb(sub2ind([iNumMice,iNumMice],1:iNumMice, a2iAllStates(iStateIter,:))));
    end;
end;

return;
