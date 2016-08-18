strFolder = 'D:\Data\Janelia Farm\ResultsFromNewTrunk\';
% Display coarse scale statistics.
aiCages = [16:20,23];
% 16,17,18,19,20,23
% Analyze per minute.
fFPS = 30;
iNumFramesPerMinute = fFPS * 60;
iBlockSizeInFrames = iNumFramesPerMinute * 10;
ai12HourOnset = [0:12:12*2*6];
ai12HourOnsetInBlocks = ai12HourOnset*60*iNumFramesPerMinute / iBlockSizeInFrames;

% 10 min
acGroups = {
                    { {'F1','F2','M1','M2'}},...
                    { {'F1','F2'}, {'M1','M2'} },...
                    { {'F1','M1'},{'F2','M2'} },...
                    { {'F1','M2'},{'F2','M1'} },...
                    { {'F1','F2','M1'},{'M2'} },...
                    { {'F1','F2','M2'},{'M1'} },...
                    { {'F1','M1','M2'},{'F2'} },...
                    { {'F2','M1','M2'},{'F1'} },...
                    { {'F1','F2'},{'M1'},{'M2'} },...
                    { {'F1','M1'},{'F2'},{'M2'} },...
                    { {'F1','M2'},{'F2'},{'M1'} },...
                    { {'F2','M1'},{'F1'},{'M2'} },...
                    { {'F2','M2'},{'F1'},{'M1'} },...
                    { {'M1','M2'},{'F1'},{'F2'} },...
                    { {'M1'},{'M2'},{'F1'},{'F2'} }};
                    



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

             % Male 1 is the "dominant"
a2cCageRemap = [fnGetGroupRemapping(4,3,1,2);
                fnGetGroupRemapping(3,1,2,4);
                fnGetGroupRemapping(1,4,2,3);
                fnGetGroupRemapping(1,3,2,4);
                fnGetGroupRemapping(4,2,1,3);
                 fnGetGroupRemapping(1,4,3,2);];

%  
%                 male                                 female                                           dominant male
% 16           sp(3) and vs (4)           dg(1) and hs (2)            vs (m2), took a while
% 17           sp(3) and dg (1)           hs(2) and vs (4)           sp (m2,  voc during female follows)
% 18           dg(1) and vs (4)           hs (2) and sp(3)            dg (m1)
% 19           dg(1) and sp(3)             hs(2) and vs (4)          dg( m1) (sp wounded, had to stop cage)
% 20           vs (4) and hs(2)            dg (1) and sp(3)           vs (m2)
% 23           dg(1) and vs (4)           sp (3) and hs (2)          ? dg (m1)

a3fGroupStat = zeros(15,721,           length(aiCages));
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
      a3fGroupStat(:,iBlockIter,iCageIter) = histc(aiSubset,1:15);
    end
    
    a3fGroupStat(:,:,iCageIter) = a3fGroupStat(a2cCageRemap(iCageIter,:),:,iCageIter);
end
%%
figure(12);
clf;
imagesc(a3fGroupStat(:,:,1)/iBlockSizeInFrames,[0 1]);
colormap jet
set(gca,'ytick',1:15)
set(gca,'yticklabel',[]);
hold on;
% for k=1:15
%     plot([0 721],[k k]-0.5,'w--');
% end
for j=1:length(ai12HourOnsetInBlocks)
    plot([ai12HourOnsetInBlocks(j) ai12HourOnsetInBlocks(j)],[0 17],'w','Linewidth',1);
end;
set(gca,'xtick',ai12HourOnsetInBlocks,'xticklabel',ai12HourOnset)
colorbar
set(gca,'xlim',[0.5 718]);
set(gcf,'position',[750   668   600   420]);

%%

%%
iNumCages=length(aiCages);
aiStart = ai12HourOnsetInBlocks(1:end-3)+1;
aiEnd = ai12HourOnsetInBlocks(2:end-2);
a2iFinalStat1Group = zeros(iNumCages, length(aiStart));
a2iFinalStat4Group = zeros(iNumCages, length(aiStart));


a2iFinalStatMale1Group= zeros(iNumCages, length(aiStart));
a2iFinalStatMale2Group = zeros(iNumCages, length(aiStart));


abRelevantGroupsMale1 = zeros(1,15)>0;
abRelevantGroupsMale2 = zeros(1,15)>0;
for iGroupIter=1:15
    iNumSubGroups = length(acGroups{iGroupIter});
    for iSubGroupIter=1:iNumSubGroups
        if ismember('M1', acGroups{iGroupIter}{iSubGroupIter}) &&  (ismember('F1', acGroups{iGroupIter}{iSubGroupIter}) || ismember('F2',acGroups{iGroupIter}{iSubGroupIter})) && ~ismember('M2',acGroups{iGroupIter}{iSubGroupIter})
             abRelevantGroupsMale1(iGroupIter) = true;
        end    
        if ismember('M2', acGroups{iGroupIter}{iSubGroupIter}) &&  (ismember('F1', acGroups{iGroupIter}{iSubGroupIter}) || ismember('F2',acGroups{iGroupIter}{iSubGroupIter})) && ~ismember('M1',acGroups{iGroupIter}{iSubGroupIter})
             abRelevantGroupsMale2(iGroupIter) = true;
        end    
    end
end
abIrrelevant = abRelevantGroupsMale1 & abRelevantGroupsMale2;



%%



for iExpIter=1:iNumCages
    afTmp = squeeze(a3fGroupStat(1,:,iExpIter))/iBlockSizeInFrames;
    afTmp2 = squeeze(a3fGroupStat(15,:,iExpIter))/iBlockSizeInFrames;
    afTmp3 = sum(squeeze(a3fGroupStat(~abIrrelevant&abRelevantGroupsMale1,:,iExpIter))/iBlockSizeInFrames,1);
    afTmp4 = sum(squeeze(a3fGroupStat(~abIrrelevant&abRelevantGroupsMale2,:,iExpIter))/iBlockSizeInFrames,1);

    for iIter=1:10
        a2iFinalStat1Group(iExpIter,iIter) = mean(afTmp(aiStart(iIter):aiEnd(iIter)));
    end
    for iIter=1:10
        a2iFinalStat4Group(iExpIter,iIter) = mean(afTmp2(aiStart(iIter):aiEnd(iIter)));
    end
    for iIter=1:10
        a2iFinalStatMale1Group(iExpIter,iIter) = mean(afTmp3(aiStart(iIter):aiEnd(iIter)));
    end
    for iIter=1:10
        a2iFinalStatMale2Group(iExpIter,iIter) = mean(afTmp4(aiStart(iIter):aiEnd(iIter)));
    end
end

aiPerm = [1,2,5,4,3,6];
figure(16);
clf;
bar(a2iFinalStat4Group(aiPerm,[1,3,5,7,9])')
set(gca,'xticklabel',[]);
set(gca,'ylim',[0 0.7]);
set(gcf,'position',[1000 870 314 226])

A=a2iFinalStat4Group(:,[1,3]);
B=a2iFinalStat4Group(:,[7,9]);
[p,h]=ttest(A(:),B(:))

T = a2iFinalStat4Group(aiPerm,[1,3,5,7,9]);
anova2(T,2)

figure(17);
clf;
bar(a2iFinalStat1Group(aiPerm,[1,3,5,7,9])')
set(gca,'ylim',[0 0.3]);
set(gcf,'position',[1000 870 314 226])
bar(a2iFinalStat(:,[1,3,5,7,9])')
set(gca,'xtick',1:5)
T = a2iFinalStat1Group(aiPerm,[1,3,5,7,9]);
anova2(T,2)
%%
a2iTemp = a2iFinalStatMale1Group'-a2iFinalStatMale2Group';
figure(20);
clf;
bar(12:12:12*10,a2iTemp(:,aiPerm));
set(gca,'ylim',[-0.3 0.9]);
set(gca,'xlim',[0 130]);
box on

signtest(a2iFinalStatMale1Group(:),a2iFinalStatMale2Group(:))

a2fMale1Stat=zeros(iNumCages,72);
a2fMale2Stat=zeros(iNumCages,72);
for iExpIter=1:iNumCages
    afTmp3 = sum(squeeze(a3fGroupStat(~abIrrelevant&abRelevantGroupsMale1,:,iExpIter)),1);
    afTmp4 = sum(squeeze(a3fGroupStat(~abIrrelevant&abRelevantGroupsMale2,:,iExpIter)),1);
    a2fMale1Stat(iExpIter,:)=afTmp3(1:72);
    a2fMale2Stat(iExpIter,:)=afTmp4(1:72);
end

A=cumsum(a2fMale1Stat,2)/30/60;
B=cumsum(a2fMale2Stat,2)/30/60;
afP = zeros(1,72);
for k=1:72
    [~,afP(k)]=ttest(A(:,k),B(:,k));
end

afBlue = [87,175,254]/255;
afGreen = [97,255,106]/255;
afTime = linspace(0,12,72);
figure(500);clf;hold on;
fnFancyPlot2(afTime,mean(A), std(A)/sqrt(6),afBlue,0.5*afBlue);
fnFancyPlot2(afTime,mean(B), std(B)/sqrt(6),afGreen,afGreen*0.5);
set(gca,'xtick',0:2:12,'xlim',[0 12],'ylim',[0 100]);

