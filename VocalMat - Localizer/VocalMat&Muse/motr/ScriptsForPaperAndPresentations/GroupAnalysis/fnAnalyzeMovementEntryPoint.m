clear all
strFolder = 'D:\Data\Janelia Farm\ResultsFromNewTrunk\';
aiCages = [16,17,18,19,20];

% Analyze per minute.
fFPS = 30;
iNumFramesPerMinute = fFPS * 60;
iBlockSizeInFrames = iNumFramesPerMinute * 10;
ai12HourOnset = [0:12:12*2*6];
ai12HourOnsetInBlocks = ai12HourOnset*60*iNumFramesPerMinute / iBlockSizeInFrames;
afVelocityBins = 0:0.1:30;
iNumVelocityBins = length(afVelocityBins);
figure(18);clf;
figure(19);clf;
for iCageIter=1:length(aiCages)
    fprintf('Loading Data...');
    strDatfile = [strFolder,'cage',num2str(aiCages(iCageIter)),'_matrix.mat'];
    strctData = load(strDatfile);
    iNumFrames = size(strctData.X,1);
    iNumMice = size(strctData.X,2);
    % Infer some statistics about size.
    aiBlockStartFrame = 1:iBlockSizeInFrames:iNumFrames;
    iNumBlocks = length(aiBlockStartFrame);
    
    a2fDx = [zeros(1,iNumMice);diff(strctData.X,1)];
    a2fDy = [zeros(1,iNumMice);diff(strctData.Y,1)];
    a2fVel = sqrt(a2fDx.^2+a2fDy.^2);
    clear a2fDx a2fDy
    a2fVel(isnan(a2fVel))=0;
    
    
    a2fVelocityCorr = zeros(iNumMice,iNumMice);
    for i=1:iNumMice
        for j=1:iNumMice
            if (i==j)
                continue;
            else
                a2fVelocityCorr(i,j)=corr(a2fVel(:,i),a2fVel(:,j));
            end;
        end
    end
    figure(18);
    subplot(2,3,iCageIter);
    imagesc(a2fVelocityCorr,[0 0.5]);
    colormap hot;
    set(gca,'xtick',1:iNumMice,'ytick',1:iNumMice);
    box on
    
    
    a3fVelocityHist = zeros(iNumVelocityBins,iNumBlocks,iNumMice);
    for iMouseIter=1:iNumMice
        for iBlockIter=1:iNumBlocks
            aiRange = aiBlockStartFrame(iBlockIter):min(iNumFrames,aiBlockStartFrame(iBlockIter)+iBlockSizeInFrames-1);
            afVelocityHist = histc(a2fVel(aiRange, iMouseIter),afVelocityBins);
            a3fVelocityHist(:,iBlockIter,iMouseIter) = afVelocityHist / sum(afVelocityHist);
        end
    end
    T=reshape((a3fVelocityHist), iNumVelocityBins*iNumMice,iNumBlocks);
    figure;clf;
    imagesc(log10(T));
    hold on;
    for j=1:length(ai12HourOnsetInBlocks)
        plot([ai12HourOnsetInBlocks(j) ai12HourOnsetInBlocks(j)],[0 iNumVelocityBins*iNumMice+0.5],'w','Linewidth',3);
    end;
    set(gca,'xtick',ai12HourOnsetInBlocks,'xticklabel',ai12HourOnset)
    set(gca,'ytick',[0.1 0.5 0.9]*iNumVelocityBins,'yticklabel',{'0 pix/frame','15 pix/frame','30 pix/frame'})
    xlabel('Time (hours)');
    colorbar
    title(sprintf('Cage %d',aiCages(iCageIter)))
end



%% Analyze approaches
iNumCages = length(aiCages);
a3iNumApproaches= zeros(iNumMice,iNumMice,iNumCages);
for iCageIter=1:iNumCages
    fprintf('Loading Data...');
    strDatfile = [strFolder,'cage',num2str(aiCages(iCageIter)),'_matrix.mat'];
    strctData = load(strDatfile);
    % Infer some statistics about size.
    strGroupTypeFile = [strFolder,'cage',num2str(aiCages(iCageIter)),'_groups_accurate.mat'];
    astrctGroups(iCageIter) = load(strGroupTypeFile);
    fprintf('Done!\n');
    
    
    afMajorAxis = nanmean(strctData.A,1);
    afMinorAxis = nanmean(strctData.B,1);
    
    iNumFrames = size(strctData.X,1);
    iNumMice = size(strctData.X,2);
    
    fMinX = floor(min(strctData.X(:)));
    fMaxX = ceil(max(strctData.X(:)));
    fMinY = floor(min(strctData.Y(:)));
    fMaxY = ceil(max(strctData.Y(:)));
    iNumMice = size(strctData.X,2);
    iNumFrames = size(strctData.X,1);
    fXRange = fMaxX-fMinX;
    fYRange = fMaxY-fMinY;
    afXBins = -fXRange:5:fXRange;
    afYBins = -fYRange:5:fYRange;
    iNumXBins = length(afXBins);
    iNumYBins = length(afYBins);
    
    % Define static
    a2bStatic = zeros(iNumMice,iNumFrames,'uint8')>0;
    fStaticThreshold = 5;
    for iMouseIter=1:iNumMice
        Xd = [0;strctData.X(2:end,iMouseIter) - strctData.X(1:end-1,iMouseIter)];
        Yd = [0;strctData.Y(2:end,iMouseIter) - strctData.Y(1:end-1,iMouseIter)];
        a2bStatic(iMouseIter,:) = sqrt(Xd.^2+Yd.^2) <= fStaticThreshold;
    end
    
    
    % A Approach B table
    a2iTable = [0,9,10,11;
        9,0,12,13;
        10,12,0,14;
        11,13,14,0];
    %     [1,1]->[]
    %     [1,2]->9
    %     [1,3]->10
    %     [1,4]->11
    %     [2,1]->9
    %     [2,2]-[]
    %     [2,3]->12
    %     [2,4]->13
    %     [3,1]->10
    %     [3,2]->12
    %     [3,3]->[]
    %     [3,4]->14
    %     [4,1]->11
    %     [4,2]->13
    %     [4,3]->14
    %     [4,4]->[]
    
    a2cApproachInd=cell(iNumMice,iNumMice);
    a2iNumApproaches = zeros(iNumMice,iNumMice);
    for iMouseIter1=1:iNumMice
        for iMouseIter2=1:iNumMice
            if iMouseIter1==iMouseIter2
                continue;
            end
            iNextState = a2iTable(iMouseIter1,iMouseIter2);
            a2cApproachInd{iMouseIter1,iMouseIter2} = find(astrctGroups(iCageIter).aiGroupType(1:end-1) == 15 & ...
                astrctGroups(iCageIter).aiGroupType(2:end) == iNextState & ...
                ~a2bStatic(iMouseIter1,1:end-1) & a2bStatic(iMouseIter2,1:end-1));
            a2iNumApproaches(iMouseIter1,iMouseIter2) = length( a2cApproachInd{iMouseIter1,iMouseIter2});
            
        end
    end
    
    % Spatial arrangement of approach
    % Static mouse is in the center.
    
    afXRange = -200:200;
    afYRange = -200:200;
    a4fI = zeros(length(afYRange),length(afXRange),iNumMice,iNumMice);
    for iMouseIter1=1:iNumMice
        for iMouseIter2=1:iNumMice
            if iMouseIter1==iMouseIter2
                continue;
            end
            iNumApproaches = length(a2cApproachInd{iMouseIter1,iMouseIter2});
            for iIter=1:iNumApproaches
                iFrame = a2cApproachInd{iMouseIter1,iMouseIter2}(iIter);
                Yc = strctData.Y(iFrame,iMouseIter2);
                Tc = strctData.Theta(iFrame,iMouseIter2);
                
                Xc = strctData.X(iFrame,iMouseIter2);
                if isnan(Xc) || isnan(strctData.X(iFrame,iMouseIter1))
                    continue;
                end;
                
                a2bI=fnDrawTrackers9(strctData.X(iFrame,iMouseIter1)-Xc,...
                    strctData.Y(iFrame,iMouseIter1)-Yc,...
                    strctData.A(iFrame,iMouseIter1),...
                    strctData.B(iFrame,iMouseIter1),...
                    strctData.Theta(iFrame,iMouseIter1)-Tc,afXRange,afYRange);
                a4fI(:,:,iMouseIter1,iMouseIter2)=a4fI(:,:,iMouseIter1,iMouseIter2)+double(a2bI);
            end
        end
    end
    
    
    figure(20+iCageIter);
    clf;
    for i=1:4
        for j=1:4
            if i==j
                continue;
            else
                tightsubplot(4,4,(i-1)*4+j);
                imagesc(afYRange,afXRange,rot90(a4fI(:,:,i,j)));
                axis off
                axis equal
            end;
        end;
    end;
    
    
    a3iNumApproaches(:,:,iCageIter) = a2iNumApproaches;
end


figure(20);
for iCageIter=1:iNumCages
    subplot(2,3,iCageIter);
    imagesc(a3iNumApproaches(:,:,iCageIter));
    ylabel('Initiator (moving)');
    xlabel('Approaches to (static)');
    title(sprintf('Cage %d',aiCages(iCageIter)));
    colorbar
end
