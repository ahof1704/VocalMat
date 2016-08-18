function [a2fFeatures, ...
          aiStart, ...
          aiEnd, ...
          a2fFeaturesFlipped, ...
          a3fRepresentativePatch, ...
          a3iActualImages] = ...
    fnCollectExemplars(acMovies, ...
                       strResultsRootFolder, ...
                       iMaxNumSamplesPerPattern, ...
                       bCollectFlipped, ...
                       iHOG_Dim)
                   
% Takes as input a set of single-mouse clips, and extracts HOG features for
% each frame, up to a maximum number of frames given by
% iMaxNumSamplesPerPattern.
%
% Inputs: acMovies is a cell array and a vector, of length equal to the
% number of mice to be discriminated.  Each element is a 1x1 structure
% array that contains the name of the .seq file and a bunch of metadata for
% it, including the indexing info.  strResultsRootFolder is just what it
% says on the tin, and is where the function looks for the "Identities.mat"
% file for each movie.  iMaxNumSamplesPerPattern is as described above.
% bCollectFlipped tells the function whether or not it should also
% calculate features for head-to-tail flipped versions of the registered
% mouse images. iHOG_Dim gives the number of HOG features to be calculated.
%
% Outputs: Let iNumExemplars be the number of exemplars returned, equal to
% the larger of the number of frames in a movie and
% iMaxNumSamplesPerPattern.  Let iNumMice be the number of mice to be
% discriminated (equal to the number of movies provided).  a2fFeatures is
% then a (iNumMice*iNumExemplars) x iHOG_Dim array of HOG feature vectors.
% aiStart and aiEnd are 1 x iNumMice arrays, with mouse j's feature vectors
% found from row aiStart(j) to row aiEnd(j) in a2fFeatures.
% a2fFeaturesFlipped is empty if bCollectFlipped is false, and contains the
% feature vectors for the flipped mouse images if bCollectFlipped is true.
% a3fRepresentativePatch is iNumRow x iNumCol x iNumMice, with each page
% holding a representative registered image (a "patch") of that mouse.
% (iNumRow and iNumCol are specified elsewhere.)  a3iActualImages is an
% iNumRow x iNumCol x (iNumMice*iNumExemplars) array with page k holding
% the registered image from which row k of a2fFeatures was calculated.
%
% ALT, 2011/12/29

global g_strctGlobalParam 

iNumMice = length(acMovies);
aiNumSamples = zeros(1,iNumMice);
if bCollectFlipped
   fnLog('Collecting flipped exemplars');
else
   fnLog('Collecting straight (non-flipped) exemplars');
end
for iIter=1:iNumMice
    % Load result file
    [strPath, strFile] = fileparts(acMovies{iIter}.m_strFileName);
    strResultsFileName = fullfile(strResultsRootFolder, strFile, 'Identities.mat');
    fnLog(['Mouse ' num2str(iIter) ' data is taken from file ' strResultsFileName]);
    if ~exist(strResultsFileName,'file')
%         h=msgbox(sprintf('Error. Results for sequence %s were not found!', strFile));
%         waitfor(h);
        error(1);
        return;
    end;
    aiNumSamples(iIter) = acMovies{iIter}.m_iNumFrames;
end;
 
fprintf('Constraining maximal number of samples per pattern to %d\n',iMaxNumSamplesPerPattern);
fprintf('Number of samples available: %d\n', sum(aiNumSamples));
aiNumSamples = min(aiNumSamples,iMaxNumSamplesPerPattern);

a2fFeatures = zeros(sum(aiNumSamples), iHOG_Dim,'single');

if bCollectFlipped
    a2fFeaturesFlipped = zeros(sum(aiNumSamples), iHOG_Dim,'single');
else
    a2fFeaturesFlipped = [];
end;

a3fRepresentativePatch = zeros(g_strctGlobalParam.m_strctClassifiers.m_fImagePatchHeight,g_strctGlobalParam.m_strctClassifiers.m_fImagePatchWidth, iNumMice);

% Tmp = cumsum([1,aiNumSamples]);
% aiStart = Tmp(1:end-1);
% aiEnd = Tmp(2:end)-1;
%a3fRepresentativePatch = zeros(52,111,iNumMice);
aiStart = zeros(1, iNumMice);
aiEnd = zeros(1, iNumMice);
aiStart(1) = 1;

[strPath, strFile] = fileparts(acMovies{1}.m_strFileName);
strResultsFileName = fullfile(strResultsRootFolder, strFile, 'Identities.mat');
strctTmp = load(strResultsFileName);
iHeight = size(strctTmp.strctIdentity.m_a3iPatches,1);
iWidth = size(strctTmp.strctIdentity.m_a3iPatches,2);
a3iActualImages = zeros(iHeight,iWidth,sum(aiNumSamples), 'uint8');

for iIter=1:iNumMice
    % Load result file
    [strPath, strFile] = fileparts(acMovies{iIter}.m_strFileName);
    strResultsFileName = fullfile(strResultsRootFolder, strFile, 'Identities.mat');
    if ~exist(strResultsFileName,'file')
        msgbox(sprintf('Error. Results for sequence %s were not found!', strFile));
        return;
    end;
    fprintf('Loading data entries in %s...',strFile);
    drawnow
    strctTmp = load(strResultsFileName);
    
    aiGoodExemplars = find(strctTmp.strctIdentity.m_afA > g_strctGlobalParam.m_strctClassifiers.m_fGoodTrainingSampleMinA & ...
        strctTmp.strctIdentity.m_afB > g_strctGlobalParam.m_strctClassifiers.m_fGoodTrainingSampleMinB);
    % Pick Random examplars....
    aiRandPerm = randperm(length(aiGoodExemplars));
    aiGoodExemplars = aiGoodExemplars(aiRandPerm);
    
    [fDummy,iIndex]=min(...
    abs(strctTmp.strctIdentity.m_afA-median(strctTmp.strctIdentity.m_afA))+...
    abs(strctTmp.strctIdentity.m_afB-median(strctTmp.strctIdentity.m_afB))    );
    
    a3fRepresentativePatch(:,:,iIter) = strctTmp.strctIdentity.m_a3iPatches(:,:,iIndex);
    fnLog(['A good representative of mouse ' num2str(iIter) ' (size closest to median), is exemplar ' num2str(iIndex)], 1, squeeze(a3fRepresentativePatch(:,:,iIter))/255);
    if isempty(aiGoodExemplars)
        error('Size thresholds are incorrect. No good exemplars found!');
    end;
    
    iNumSamplesTaken = min(length(aiGoodExemplars), aiNumSamples(iIter));
    fnLog(['Found ' num2str(length(aiGoodExemplars)) ' good exemplars, of which ' num2str(iNumSamplesTaken) ' are taken']);
    aiNumSamples(iIter) = iNumSamplesTaken;
    aiEnd(iIter) = aiStart(iIter) + iNumSamplesTaken-1 ;
    if iIter ~= iNumMice
        aiStart(iIter+1) = aiEnd(iIter) + 1;
    end;
    
    a2fFeatures(aiStart(iIter):aiEnd(iIter),:) = strctTmp.strctIdentity.m_a3fHOGFeatures(aiGoodExemplars(1:iNumSamplesTaken),:);
    a3iActualImages(:,:,aiStart(iIter):aiEnd(iIter)) = strctTmp.strctIdentity.m_a3iPatches(:,:,aiGoodExemplars(1:iNumSamplesTaken));
    if bCollectFlipped
        a2fFeaturesFlipped(aiStart(iIter):aiEnd(iIter),:) = strctTmp.strctIdentity.m_a3fHOGFeaturesFlipped(aiGoodExemplars(1:iNumSamplesTaken),:);
    end;
    
    %a3fRepresentativePatch(:,:,iIter) = strctTmp.strctIdentity.m_a3iPatches(:,:,500);
    clear strctTmp
    fprintf('Done!\n');
end
fprintf('Using only : %d samples \n', sum(aiNumSamples));
 
return;