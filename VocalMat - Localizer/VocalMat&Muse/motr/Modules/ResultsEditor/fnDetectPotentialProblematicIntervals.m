function astrctProblem = fnDetectPotentialProblematicIntervals(astrctTrackers)

iNumMice = length(astrctTrackers);
iNumFrames = length(astrctTrackers(1).m_afX);
astrctProblem = [];
%%
% First, search for really big jumps in position.
fVelocityThresholdPix = 100;
acColors = {'Red','Green','Blue','Cyan'};
for iMouseIter=1:iNumMice
    afVel = sqrt(diff(astrctTrackers(iMouseIter).m_afX).^2+diff(astrctTrackers(iMouseIter).m_afY).^2);
    astrctBigJumps = fnGetIntervals(afVel > fVelocityThresholdPix);

    for k=1:length(astrctBigJumps)
        strctProblem.m_aiFrames = [astrctBigJumps(k).m_iStart,astrctBigJumps(k).m_iEnd];
        strctProblem.m_aiMiceInvolved =  iMouseIter;
        strctProblem.m_strInfo = sprintf('%s Big Jump', acColors{iMouseIter});
        if isempty(astrctProblem)
            astrctProblem = strctProblem;
        else
            astrctProblem(end+1) = strctProblem;
        end;
    end;
end;

if 0
% now, search for low identity likelihood when mouse is far away from all
% other mice.
if isfield(astrctTrackers,'m_afLogProb')
    fDistanceFromOtherMiceThresholdPix = 100;
    fLogLikelihoodThreshold = -3;
    iNumSecsWithLowLikelihood = 10;
    iMedianFilterIntervalFrames = 30;
    FPS = 30;
    for iMouseIter=1:iNumMice
        afMinDist = ones(1, iNumFrames) * inf;
        for iOtherMouseIter = setdiff(1:iNumMice, iMouseIter)
            afCurrDist = sqrt((astrctTrackers(iMouseIter).m_afX - astrctTrackers(iOtherMouseIter).m_afX).^2 + ...
                (astrctTrackers(iMouseIter).m_afY - astrctTrackers(iOtherMouseIter).m_afY).^2);
            afMinDist = min(afMinDist, afCurrDist);
        end;
        abPotentialProblem = (afMinDist > fDistanceFromOtherMiceThresholdPix & ...
            astrctTrackers(iMouseIter).m_afLogProb < fLogLikelihoodThreshold );

        abFiltered = medfilt1(abPotentialProblem, iMedianFilterIntervalFrames) > 0.8;

        astrctLowIdentityProb = fnGetIntervals(abFiltered);
        if ~isempty(astrctLowIdentityProb)
            aiPotentialIdentityProblemIntervals = find(cat(1,astrctLowIdentityProb.m_iLength) > iNumSecsWithLowLikelihood * FPS);
            for k=1:length(aiPotentialIdentityProblemIntervals)


                strctProblem.m_aiFrames = [astrctLowIdentityProb(aiPotentialIdentityProblemIntervals(k)).m_iStart,...
                    astrctLowIdentityProb(aiPotentialIdentityProblemIntervals(k)).m_iEnd];
                strctProblem.m_aiMiceInvolved = iMouseIter;
                strctProblem.m_strInfo = sprintf('%s Low Prob', acColors{iMouseIter});
                if isempty(astrctProblem)
                    astrctProblem = strctProblem;
                else
                    astrctProblem(end+1) = strctProblem;
                end;

            end;

        end;
    end;
end;
end

return;
