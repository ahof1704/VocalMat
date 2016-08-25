% Display coarse scale statistics.
aiCages = [16:20,24];
% Analyze per minute.
strFolder='D:\Data\Janelia Farm\ResultsFromNewTrunk\';

fFPS = 30;
iNumFramesPerMinute = fFPS * 60;
iBlockSizeInFrames = iNumFramesPerMinute * 10;
ai12HourOnset = [0:12:12*2*6];
ai12HourOnsetInBlocks = ai12HourOnset*60*iNumFramesPerMinute / iBlockSizeInFrames;
figure(12);
clf;
for iCageIter=1:length(aiCages)
    strGroupTypeFile = [strFolder,'cage',num2str(aiCages(iCageIter)),'_groups_accurate.mat'];
    astrctGroups(iCageIter) = load(strGroupTypeFile);
    iNumFrames = length(astrctGroups(iCageIter).aiGroupType);
    
    aiBlockStartFrame = 1:iBlockSizeInFrames:iNumFrames;
    iNumBlocks = length(aiBlockStartFrame);
    a2fGroupStat = zeros(15,iNumBlocks);

    for iBlockIter=1:iNumBlocks
      aiRange = aiBlockStartFrame(iBlockIter):min(iNumFrames,aiBlockStartFrame(iBlockIter)+iBlockSizeInFrames-1);
      aiSubset = astrctGroups(iCageIter).aiGroupType(aiRange);
      a2fGroupStat(:,iBlockIter) = histc(aiSubset,1:15);
    end

    a2fGroupStatSmall = zeros(5,iNumBlocks);
    a2fGroupStatSmall(1,:) = a2fGroupStat(1,:); % 4
    a2fGroupStatSmall(2,:) = sum(a2fGroupStat(5:8,:),1); % 3-1
    a2fGroupStatSmall(3,:) = sum(a2fGroupStat(2:4,:),1); % 2-2
    a2fGroupStatSmall(4,:) = sum(a2fGroupStat(9:14,:),1); % 2-1-1
    a2fGroupStatSmall(5,:) = a2fGroupStat(15,:); % 1-1-1-1

    subplot(6,1,iCageIter);
    imagesc(a2fGroupStatSmall/iBlockSizeInFrames);
    colormap jet
    colorbar
    set(gca,'ytick',1:5)
    set(gca,'yticklabel',{'One Group [4]','Two Groups [3-1]','Two Groups [2-2]','Three Groups [2-1-1]','Four Groups [1-1-1-1]'});
    hold on;
    for j=1:length(ai12HourOnsetInBlocks)
        plot([ai12HourOnsetInBlocks(j) ai12HourOnsetInBlocks(j)],[0 5.5],'w','Linewidth',3);
    end;
    title(sprintf('Cage %d',aiCages(iCageIter)));
    
    if iCageIter==4
    set(gca,'xtick',ai12HourOnsetInBlocks,'xticklabel',ai12HourOnset)
    xlabel('Time (hours)');
    else
        set(gca,'xtick',[]);
    end
    
end



% Display fine scale
acGroupsNames = {'[1,2,3,4]',...
                 '[1,2],[3,4]',...
                 '[1,3],[2,4]',...
                 '[1,4],[2,3]',...
                 '[1,2,3],[4]',...
                 '[1,2,4],[3]',...
                 '[1,3,4],[2]',...
                 '[2,3,4],[1]',...
                 '[1,2],[3],[4]',...
                 '[1,3],[2],[4]',...
                 '[1,4],[2],[3]',...
                 '[2,3],[1],[4]',...
                 '[2,4],[1],[3]',...
                 '[3,4],[1],[2]',...
                 '[1],[2],[3],[4]'};
    
for iCageIter=1:length(aiCages)
    strGroupTypeFile = [strFolder,'cage',num2str(aiCages(iCageIter)),'_groups_accurate.mat'];
    astrctGroups(iCageIter) = load(strGroupTypeFile);
    iNumFrames = length(astrctGroups(iCageIter).aiGroupType);
    
    aiBlockStartFrame = 1:iBlockSizeInFrames:iNumFrames;
    iNumBlocks = length(aiBlockStartFrame);
    a2fGroupStat = zeros(15,iNumBlocks);

    for iBlockIter=1:iNumBlocks
      aiRange = aiBlockStartFrame(iBlockIter):min(iNumFrames,aiBlockStartFrame(iBlockIter)+iBlockSizeInFrames-1);
      aiSubset = astrctGroups(iCageIter).aiGroupType(aiRange);
      a2fGroupStat(:,iBlockIter) = histc(aiSubset,1:15);
    end
    switch iCageIter
        case 1
            figure(12);
            clf;
            subplot(2,1,1);
        case 2
            subplot(2,1,2);
        case 3
            figure(13);
            clf;
            subplot(2,1,1);
        case 4
            subplot(2,1,2);
        case 5
            figure(14);
            clf;
            subplot(2,1,1);
        case 6
        subplot(2,1,2);            
    end
    
    imagesc(a2fGroupStat/iBlockSizeInFrames);
    colormap jet
    colorbar
    set(gca,'ytick',1:15)
    set(gca,'yticklabel',acGroupsNames);
    hold on;
    for j=1:length(ai12HourOnsetInBlocks)
        plot([ai12HourOnsetInBlocks(j) ai12HourOnsetInBlocks(j)],[0 15.5],'w','Linewidth',3);
    end;
    title(sprintf('Cage %d',aiCages(iCageIter)));
    
    if iCageIter==2 || iCageIter==4
    set(gca,'xtick',ai12HourOnsetInBlocks,'xticklabel',ai12HourOnset)
    xlabel('Time (hours)');
    else
        set(gca,'xtick',[]);
    end
    
end
iNumCages = length(aiCages);
a2fPrior = zeros(iNumCages,15);
for iCageIter=1:iNumCages
    a2fPrior(iCageIter,:) = histc(astrctGroups(iCageIter).aiGroupType,1:15);
    a2fPrior(iCageIter,:) = a2fPrior(iCageIter,:) / sum(a2fPrior(iCageIter,:));
end;
figure(15);
clf
bar(a2fPrior');
legend({'Cage16','Cage17','Cage18','Cage19','Cag20'},'Location','NorthEastOutside');
set(gca,'xtick',1:15,'xticklabel',acGroupsNames);
xticklabel_rotate
%%
a3fStateTransition = zeros(15,15,iNumCages);
for iCageIter=1:iNumCages
    aiInd = sub2ind([15 15],astrctGroups(iCageIter).aiGroupType(2:end),astrctGroups(iCageIter).aiGroupType(1:end-1));
    aiHist = histc(aiInd,1:225);
    a3fStateTransition(:,:,iCageIter) = reshape(aiHist,15,15);
end


figure(16);
clf;
for iCageIter=1:iNumCages
    a2fStateTransitionNoDiag = a3fStateTransition(:,:,iCageIter);
    a2fStateTransitionNoDiag(eye(15)>0) = 0;
    a2fStateTransitionNoDiag = a2fStateTransitionNoDiag / sum(a2fStateTransitionNoDiag(:));
    subplot(2,3,iCageIter);
    imagesc(a2fStateTransitionNoDiag)
    set(gca,'xtick',1:15,'yticklabel',acGroupsNames);
    set(gca,'ytick',1:15);
    ylabel('From');
    xlabel('To');
    title(sprintf('Cage %d',aiCages(iCageIter)));
end
%%


%                    	male	female
% 16 (std)	sp(3) and vs (4)	dg(1) and hs (2)
% 17 (std)	sp(3) and dg (1)	hs(2) and vs (4)
% 18 (enr)	dg(1) and vs (4)	hs (2) and sp(3)
% 19 (enr)	dg(1) and sp(3)  	hs(2) and vs (4)
% 20 (std)	vs(4) and hs(2)	    dg (1) and sp(3)
