clear all
strFolder = 'D:\Data\Janelia Farm\ResultsFromNewTrunk\';
aiCages = 24;%[16,17,18,19,20];
iBlockSize = 10000;
for iCageIter=1:length(aiCages)
    
    strDatfile = [strFolder,'cage',num2str(aiCages(iCageIter)),'_matrix.mat'];
    strDistFile = [strFolder,'cage',num2str(aiCages(iCageIter)),'_dist.mat'];
    fprintf('Loading %s...',strDatfile);
    strctData = load(strDatfile);
    strctDist = load(strDistFile);
    fprintf('Done!\n');
    % Infer some statistics about size.
    
    afMajorAxis = nanmean(strctData.A,1);
    afMinorAxis = nanmean(strctData.B,1);
    
    iNumFrames = size(strctData.X,1);
    iNumMice = size(strctData.X,2);
    
    fProximityThreshold = max(afMinorAxis);
    
    %%
    aiGroupType = zeros(1,iNumFrames,'single');
    acGroups = cell(1,iNumFrames);
    tic
    fBlockTime = 0;
    for iFrameIter=1:iNumFrames
        if mod(iFrameIter,iBlockSize) == 0
            fBlockTime = toc;
            iNumBlocksRemaining = ceil( (iNumFrames- iFrameIter)/iBlockSize);
            fTimeRemain = iNumBlocksRemaining * fBlockTime;
            fprintf('Cage %d: %d out of %d. Block Time: %.2f Sec, Remain Blocks : %d, Time Remain: %.2f Sec (%.2f Min)\n',aiCages(iCageIter),iFrameIter,iNumFrames,fBlockTime,iNumBlocksRemaining,fTimeRemain,fTimeRemain/60);
            tic
        end;
        % build the 4-4 distance matrix
        a2fDist = zeros(iNumMice,iNumMice);
        a2fDist(1,2) = strctDist.a2fDistance(iFrameIter,1);
        a2fDist(2,1) = strctDist.a2fDistance(iFrameIter,1);

        a2fDist(1,3) = strctDist.a2fDistance(iFrameIter,2);
        a2fDist(3,1) = strctDist.a2fDistance(iFrameIter,2);

        a2fDist(1,4) = strctDist.a2fDistance(iFrameIter,3);
        a2fDist(4,1) = strctDist.a2fDistance(iFrameIter,3);
        
        a2fDist(2,3) = strctDist.a2fDistance(iFrameIter,4);
        a2fDist(3,2) = strctDist.a2fDistance(iFrameIter,4);
        
        a2fDist(2,4) = strctDist.a2fDistance(iFrameIter,5);
        a2fDist(4,2) = strctDist.a2fDistance(iFrameIter,5);

        a2fDist(3,4) = strctDist.a2fDistance(iFrameIter,6);
        a2fDist(4,3) = strctDist.a2fDistance(iFrameIter,6);
        
        aiGroupType(iFrameIter) = fnGetGroups(a2fDist, fProximityThreshold);
    end
    strGroupFile = [strFolder,'cage',num2str(aiCages(iCageIter)),'_groups_accurate.mat'];
    save(strGroupFile,'aiGroupType');
    toc
end
fprintf('All Done!\n');