function afThetaCorrected = fnCorrectOrientation(afTheta, afAlpha, afVel, afProbPos)
% Viterbi for orientation!
global g_strctGlobalParam

iNumFrames = length(afTheta);%astrctTrackers(1).m_afTheta);
iNumStates = 360; % 0..360
afVelocityAngle = afAlpha;
afVelocityAngle(afVelocityAngle < 0) = afVelocityAngle(afVelocityAngle<0)+2*pi;
afVelocityAngle(afVelocityAngle > 2*pi) = afVelocityAngle(afVelocityAngle > 2*pi)-2*pi;
afTheta(afTheta > 2*pi) = afTheta(afTheta > 2*pi)-2*pi;
afTheta(afTheta < 0) = afTheta(afTheta<0)+2*pi;
afAngleQuantization = linspace(0,2*pi - (1/iNumStates)*2*pi,iNumStates);

iNumFrames = length(afTheta);
afStateAngles = ([1:iNumStates] -1)/(iNumStates-1)*2*pi;
fLogZero = -5000;

[a2LogfLikelihood] = ...
   fnViterbiLikelihoodForHeadTail(afStateAngles, double(afProbPos), ...
   afTheta, afVel, afVelocityAngle);


%% Transition matrix (fixed)
a2fTransitionMatrix = zeros(iNumStates, iNumStates,'single');
fTransitionKappa = 50;
for iStateIter=1:iNumStates
    a2fTransitionMatrix(:,iStateIter) = ...
        fnVonMises(afAngleQuantization(iStateIter), fTransitionKappa, afAngleQuantization);
end;
a2fTransitionMatrix = a2fTransitionMatrix ./ repmat(sum(a2fTransitionMatrix,1),iNumStates,1);
a2LogfTransitionMatrix = log(a2fTransitionMatrix);
a2LogfTransitionMatrix(isinf(a2LogfTransitionMatrix)) = fLogZero;

[aiPath] = fndllViterbi(a2LogfTransitionMatrix,a2LogfLikelihood);
% 
% if fnGetLogMode(1)
%    hFigure = figure(10); set(hFigure,'visible','off');clf; imagesc(a2LogfLikelihood); hold on; plot(aiPath,'c'); strctFrame = getframe(hFigure);
fnLog('Calculated aiPath'); %, 1, strctFrame.cdata)
% end
% [aiPath, a2fLogProb] = fnViterbiForwardBackward(iNumStates, iNumFrames, ...
%     a2fTransitionMatrix,a2fLikelihood);
%fprintf('Done\n');
afThetaCorrected = afAngleQuantization(aiPath);
return;
