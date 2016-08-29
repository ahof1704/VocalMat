function [a2fHOGFeaturesCulled,a2fHOGFeaturesFlippedCulled] = ...
  fnCullExemplarsFromSMTrack(a2fHOGFeatures, ...
                             afA,afB, ...
                             iMaxNumExemplars, ...
                             a2fHOGFeaturesFlipped)
                   
% Takes as input the HOG features and ellipse shapes from a single-mouse 
% track, filters out ones with too-small ellipses, shuffles them randomly,
% and then returns up to iMaxNumExemplars of them.
% 
% Inputs:
%   a2fHOGFeatures: the HOG feature vectors, iNumFrames x iNumHOGFeatures, 
%                   single-precision (HOG vectors in rows)
%   afA: 1 x iNumFrames, the semi-major axis of each mouse ellipse
%   afB: 1 x iNumFrames, the semi-minor axis of each mouse ellipse
%   iMaxNumExemplars: The maximum number of elemplar vectors to return
%   a2fHOGFeaturesFlipped: the HOG feature vectors for the flipped patches,
%                          iNumFrames x iNumHOGFeatures, 
%                          single-precision (HOG vectors in rows)
%                          (can be empty or omitted if only one output 
%                           argument is requested)
%
% Output:
%   a2fHOGFeaturesCulled: the culled and shuffled HOG vectors.
%                         iNumExemplars x iNumHOGFeatures
%   a2fHOGFeaturesFlippedCulled: the culled and shuffled HOG vectors, but
%                                for the flipped image patches,
%                                iNumExemplars x iNumHOGFeatures

% Deal with arguments
if nargout>=2
  % If there are two or more output args, we return culled HOG vectors
  % from the flipped images.
  bReturnFlippedToo=true;
else
  % If there is one or fewer output args, we don't return culled HOG 
  % vectors from the flipped images.
  bReturnFlippedToo=false;
end

% Get global vars we'll need
global g_strctGlobalParam 
fGoodTrainingExemplarMinA= ...
  g_strctGlobalParam.m_strctClassifiers.m_fGoodTrainingSampleMinA;
fGoodTrainingExemplarMinB= ...
  g_strctGlobalParam.m_strctClassifiers.m_fGoodTrainingSampleMinB;
clear g_strctGlobalParam

% Get how many frames we have for each single-mouse clip
fnLog('Collecting exemplars');
iNumFrames = size(a2fHOGFeatures,1);

% Want no more than iMaxNumSamplesPerSMClip samples per clip
fprintf('Number of samples available: %d\n', iNumFrames);
  
% Get indices of those that are big enough
aiBigEnoughExemplars = ...
  find(afA > fGoodTrainingExemplarMinA & ...
       afB > fGoodTrainingExemplarMinB);

% Throw an error if there are no good exemplars
if isempty(aiBigEnoughExemplars)
  error('Size thresholds are incorrect. No good exemplars found!');
end;

% Randomly shuffle the big-enough exemplars
aiRandPerm = randperm(length(aiBigEnoughExemplars));
aiBigEnoughExemplars = aiBigEnoughExemplars(aiRandPerm);

% Limit to at most iMaxNumExemplars exemplars per clip
fprintf('Constraining maximal number of exemplars per pattern to %d\n', ...
        iMaxNumExemplars);
iNumExemplars = min(length(aiBigEnoughExemplars), iMaxNumExemplars);
aiGoodExemplarsTaken=aiBigEnoughExemplars(1:iNumExemplars);

% Write to log
fnLog(['Found ' num2str(length(aiBigEnoughExemplars)) ...
       ' good exemplars, of which ' num2str(iNumExemplars) ...
       ' were taken']);

% Add the exemplars to the cell array of feature arrays
a2fHOGFeaturesCulled = a2fHOGFeatures(aiGoodExemplarsTaken,:);
if bReturnFlippedToo
  a2fHOGFeaturesFlippedCulled= ...
    a2fHOGFeaturesFlipped(aiGoodExemplarsTaken,:);
end

% Write to console
fprintf('Done!\n');

% Write to console
fprintf('Using only : %d samples \n', iNumExemplars);
 
end
