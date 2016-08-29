clear all
load('D:\Code\Janelia Farm\CurrentVersion\Annotation.mat');
% Plot behavior as a function of time....
% fStartTime = g_strctExperiment.afTimeStamp(1);
% fEndTime = g_strctExperiment.afTimeStamp(end);

iNumHours = ceil((fEndTime-fStartTime)/3600);
iNumDays = ceil(iNumHours/ 24);
iNumHoursExt = iNumDays*24;

%%
iBehaviorType =1;

figure(2);
clf;
iNumMice = 4;
for iMouseA=1:iNumMice
    aiSelectedBehaviors = find(g_strctBehaviors.m_aiMouseA == iMouseA & g_strctBehaviors.m_aiType == iBehaviorType);
    
    afTimeBins = 0:3600:iNumHoursExt*3600; % divide time into hours.
    afHours = afTimeBins/3600;
    afTimeCount = fndllIntervalHist(g_strctBehaviors.m_afStartTime(aiSelectedBehaviors) - fStartTime,...
        g_strctBehaviors.m_afEndTime(aiSelectedBehaviors) - fStartTime,afTimeBins);
    
    h=subplot(iNumMice,1,iMouseA);
    plot(afHours(1:end-1),afTimeCount/60,'linewidth',2);
    hold on;
    fMax = max(afTimeCount/60);
    for iDayIter=1:iNumDays
        plot([(iDayIter-1)*24 (iDayIter-1)*24],[0 fMax],'g--')
        text((iDayIter-1)*24 + 12, 1.1*fMax, sprintf('Day %d',iDayIter));
    end
    if iMouseA == iNumMice
        xlabel('Hours');
    end;
    ylabel('# min ');
    axis([0 iNumHoursExt 0 fMax*1.2])
    set(h,'XTick',[0:6:iNumHoursExt])
    title(sprintf('Mouse %d',iMouseA));
end;