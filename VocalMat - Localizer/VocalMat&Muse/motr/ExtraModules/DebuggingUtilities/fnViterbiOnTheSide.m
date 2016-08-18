function [aiPath, a2fV, a3fD] = fnViterbiOnTheSide(fnTrack, fIdentitySwapJumpPix, fnLikelihood)
%
load(fnTrack);
if exist('astrctTrackersJob', 'var')
   astrctTrackers = astrctTrackersJob;
   clear astrctTrackersJob;
end

iNumMice = length(astrctTrackers);
iNumFrames = length(astrctTrackers(1).m_afX);

a2fX=cat(1,astrctTrackers.m_afX);
a2fY=cat(1,astrctTrackers.m_afY);
a2fA=cat(1,astrctTrackers.m_afA);
a2fB=cat(1,astrctTrackers.m_afB);
a2fTheta=cat(1,astrctTrackers.m_afTheta);

if nargin<3
   a2iAllStates = fliplr(perms(1:iNumMice));
   iNumStates = size(a2iAllStates,1);
   a2fLikelihood = fnAuxComputeLikelihood1AA_Robust(iNumStates,iNumMice,iNumFrames,astrctTrackers,a2iAllStates);
   save likelihood1001001 a2fLikelihood;
end
clear astrctTrackers;

% a2fX = repmat(1:iNumFrames, iNumMice, 1);
% a2fY = repmat(1:iNumFrames, iNumMice, 1);
% a2fA = zeros(iNumMice, iNumFrames);
% a2fB = zeros(iNumMice, iNumFrames);
% a2fTheta = zeros(iNumMice, iNumFrames);

if exist('fnLikelihood', 'var')   
   load(fnLikelihood);
end
if ~exist('abLargeTimeGap', 'var')
   abLargeTimeGap = false(1,iNumFrames);
end
fSwapPenalty = -200;
a2iAllStates = fliplr(perms(1:iNumMice));
aiPath = fndllViterbiOnTheFly(a2iAllStates', a2fLikelihood, ...
    a2fX, a2fY, a2fA, a2fB, a2fTheta, fSwapPenalty, abLargeTimeGap, fIdentitySwapJumpPix);
 
 a2fV = [zeros(iNumMice,1) sqrt((a2fX(:,2:end)-a2fX(:,1:end-1)).^2+(a2fY(:,2:end)-a2fY(:,1:end-1)).^2)];
 a2fV = min(a2fV, 20);
 for i=1:iNumMice
    for j=1:iNumMice
       a3fD(i,j,:) = sqrt((a2fX(i,:)-a2fX(j,:)).^2 + (a2fY(i,:)-a2fY(j,:)).^2);
    end
 end
 a3fD = min(a3fD, 70);
 
function a2fLikelihood = fnAuxComputeLikelihood1AA_Robust(iNumStates,iNumMice,iNumFrames,astrctTrackers,a2iAllStates)
% The likelihood of obvserving a measurement given the true state
fLogZero = -10;
a3fLogProb = zeros(iNumFrames,iNumMice,iNumMice,'single');
for iMouseIter=1:iNumMice
   a3fLogProb(:,:,iMouseIter) = log(astrctTrackers(iMouseIter).m_a2fClassifer);
end
% a2fClassifer = zeros(iNumFrames, iNumMice, 1);
% for iClassifier=1:iNumMice
%    a2fClassifer(:,:,1) = fnProj2Classifier(iClassifier);
%    a3fLogProb(:,iClassifier,:) = log(permute(a2fClassifer,[1 3 2]));
% end
a3fLogProb(isinf(a3fLogProb)) = fLogZero;
a2fLikelihood = fnViterbiLikelihood1AA(a2iAllStates', a3fLogProb);
a2fLikelihood = log(bsxfun(@rdivide, exp(a2fLikelihood), sum(exp(a2fLikelihood),1)));

return;

function afProb = fnProj2Classifier(iClassifier)
%
global g_Samples;
a2fClassifier = zeros(size(g_Samples));
for i=1:size(g_Samples,2)
   for j=1:size(g_Samples,1)
      a2fDataProj(j,i) = g_Samples(j,i).afDataProj(iClassifier);
   end
end

load C:\MouseTrack\Data\Mice_G\Identities\Robust_LDA_ExpG_Proper.mat;
strctClassifier = strctIdentityClassifier.m_astrctClassifiers(iClassifier);
   
afPriors = [0.22; 0.66; 0.12];
a3fClassCond = zeros(size(a2fDataProj,1),size(a2fDataProj,2),3);
a3fProb = zeros(size(a2fDataProj,1),size(a2fDataProj,2),3);
a3fClassCond(:,:,1) = afPriors(1)*normpdf(a2fDataProj,strctClassifier.m_fMeanPos,strctClassifier.m_fStdPos);
a3fClassCond(:,:,2) = afPriors(2)*normpdf(a2fDataProj,strctClassifier.m_fMeanNeg,strctClassifier.m_fStdNeg);
a3fClassCond(:,:,3) = afPriors(3)*normpdf(a2fDataProj,strctClassifier.m_fMeanJunk,strctClassifier.m_fStdJunk);
a2fDenominator = sum(a3fClassCond,3);
for i=1:3
   a3fProb(:,:,i) = a3fClassCond(:,:,i) ./ a2fDenominator;
end
afProb = squeeze(a3fProb(:,:,1) + afPriors(1)/afPriors(2)*a3fProb(:,:,3));
