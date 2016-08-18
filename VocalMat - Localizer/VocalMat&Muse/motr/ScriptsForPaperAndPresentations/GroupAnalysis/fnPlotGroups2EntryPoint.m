strFolder = 'D:\Data\Janelia Farm\ResultsFromNewTrunk\';
% Display coarse scale statistics.
aiCages = [16:20];
% Analyze per minute.
fFPS = 30;
iNumFramesPerMinute = fFPS * 60;
iBlockSizeInFrames = iNumFramesPerMinute * 10;
ai12HourOnset = [0:12:12*2*6];
ai12HourOnsetInBlocks = ai12HourOnset*60*iNumFramesPerMinute / iBlockSizeInFrames;



% Display fine scale
acGroupsNames = {'[F1,F2,M1,M2]',...
                 '[F1,F2],[M1,M2]',...
                 '[F1,M1],[F2,M2]',...
                 '[F1,M2],[F2,M1]',...
                 '[F1,F2,M1],[M2]',...
                 '[F1,F2,M2],[M1]',...
                 '[F1,M1,M2],[F2]',...
                 '[F2,M1,M2],[F1]',...
                 '[F1,F2],[M1],[M2]',...
                 '[F1,M1],[F2],[M2]',...
                 '[F1,M2],[F2],[M1]',...
                 '[F2,M1],[F1],[M2]',...
                 '[F2,M2],[F1],[M1]',...
                 '[M1,M2],[F1],[F2]',...
                 '[F1],[F2],[M1],[M2]'};
    
a2cCageRemap = [fnGetGroupRemapping(3,4,1,2);
                fnGetGroupRemapping(3,1,2,4);
                fnGetGroupRemapping(1,4,2,3);
                fnGetGroupRemapping(1,3,2,4);
                fnGetGroupRemapping(2,4,1,3);];

%                    	male	female
% 16 (std)	sp(3) and vs (4)	dg(1) and hs (2)
% 17 (std)	sp(3) and dg (1)	hs(2) and vs (4)
% 18 (enr)	dg(1) and vs (4)	hs (2) and sp(3)
% 19 (enr)	dg(1) and sp(3)  	hs(2) and vs (4)
% 20 (std)	vs(4) and hs(2)	    dg (1) and sp(3)
  a3fGroupStat = zeros(15,721,           length(aiCages));
for iCageIter=1:length(aiCages)
    strGroupTypeFile = [strFolder,'cage',num2str(aiCages(iCageIter)),'_groups.mat'];
    astrctGroups(iCageIter) = load(strGroupTypeFile);
    iNumFrames = length(astrctGroups(iCageIter).aiGroupType);
    
    aiBlockStartFrame = 1:iBlockSizeInFrames:iNumFrames;
    iNumBlocks = length(aiBlockStartFrame);
    a2fGroupStat = zeros(15,iNumBlocks);

    for iBlockIter=1:iNumBlocks
      aiRange = aiBlockStartFrame(iBlockIter):min(iNumFrames,aiBlockStartFrame(iBlockIter)+iBlockSizeInFrames-1);
      aiSubset = astrctGroups(iCageIter).aiGroupType(aiRange);
      a3fGroupStat(:,iBlockIter,iCageIter) = histc(aiSubset,1:15);
    end
    
    a3fGroupStat(:,:,iCageIter) = a3fGroupStat(a2cCageRemap(iCageIter,:),:,iCageIter);
end
%%
figure(12);
clf;
imagesc(a3fGroupStat(:,:,1)/iBlockSizeInFrames);
colormap jet
set(gca,'ytick',1:15)
set(gca,'yticklabel',[]);
hold on;
for j=1:length(ai12HourOnsetInBlocks)
    plot([ai12HourOnsetInBlocks(j) ai12HourOnsetInBlocks(j)],[0 15.5],'w','Linewidth',3);
end;
set(gca,'xtick',ai12HourOnsetInBlocks,'xticklabel',ai12HourOnset)
%%
iNumCages=length(aiCages)
for iExpIter=1:iNumCages
ai12HourOnsetInBlocks
end

figure;hold on;
plot(squeeze(a3fGroupStat(1,:,1)))
plot(squeeze(a3fGroupStat(1,:,3)),'r')
