clear all
strFolder = 'D:\Data\Janelia Farm\ResultsFromNewTrunk\';
aiCages =24;% [16,17,18,19,20];
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
    
    %%
    a2fDistance = zeros(iNumFrames,6,'single');
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
                fDist = fnEllipseEllipseDist(strctData.X(iFrameIter,i),...
                                     strctData.Y(iFrameIter,i),...
                                     strctData.A(iFrameIter,i),...
                                     strctData.B(iFrameIter,i),...
                                     strctData.Theta(iFrameIter,i),...
                                     strctData.X(iFrameIter,j),...
                                     strctData.Y(iFrameIter,j),...
                                     strctData.A(iFrameIter,j),...
                                     strctData.B(iFrameIter,j),...
                                     strctData.Theta(iFrameIter,j));
                                     
                a2fDist(i,j) = fDist;
                a2fDist(j,i) = fDist;
            end
        end
        a2fDistance(iFrameIter,:) = [a2fDist(1,2),a2fDist(1,3),a2fDist(1,4),a2fDist(2,3),a2fDist(2,4),a2fDist(3,4)];
    end
    strDistFile = [strFolder,'cage',num2str(aiCages(iCageIter)),'_dist.mat'];
    save(strDistFile,'a2fDistance');
    toc
end
fprintf('All Done!\n');