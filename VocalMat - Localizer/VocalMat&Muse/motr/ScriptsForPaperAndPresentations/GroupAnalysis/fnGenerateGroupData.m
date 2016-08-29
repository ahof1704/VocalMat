clear all
strFolder = 'D:\Data\Janelia Farm\ResultsFromNewTrunk\';
aiCages = [16,17,18,19,20];
iBlockSize = 10000;
for iCageIter=1:length(aiCages)
    
    strDatfile = [strFolder,'cage',num2str(aiCages(iCageIter)),'_matrix.mat'];
    fprintf('Loading %s...',strDatfile);
    strctData = load(strDatfile);
    fprintf('Done!\n');
    % Infer some statistics about size.
    
    afMajorAxis = nanmean(strctData.A,1);
    afMinorAxis = nanmean(strctData.B,1);
    
    iNumFrames = size(strctData.X,1);
    iNumMice = size(strctData.X,2);
    
    fProximityThreshold = 2*max(afMajorAxis);
    
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
        for i=1:iNumMice
            for j=i+1:iNumMice
                fDistX = strctData.X(iFrameIter,i)-strctData.X(iFrameIter,j);
                fDistY = strctData.Y(iFrameIter,i)-strctData.Y(iFrameIter,j);
                fDist = sqrt(fDistX*fDistX+fDistY*fDistY);
                a2fDist(i,j) = fDist;
                a2fDist(j,i) = fDist;
            end
        end
        aiGroupType(iFrameIter) = fnGetGroups(a2fDist, fProximityThreshold);
    end
    strGroupFile = [strFolder,'cage',num2str(aiCages(iCageIter)),'_groups.mat'];
    save(strGroupFile,'aiGroupType');
    toc
end
fprintf('All Done!\n');