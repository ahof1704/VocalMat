aiCages=16:20;
iNumCages = length(aiCages);
iNumMice = 4;
if exist('Approach_And_Following.mat','file')
    load('Approach_And_Following');
else
    acApproach = cell(iCageIter,iNumMice,iNumMice);
    acFollowing = cell(iCageIter,iNumMice,iNumMice);
    for iCageIter=1:iNumCages
        strCageFile = sprintf('D:\\Data\\Janelia Farm\\ResultsFromNewTrunk\\cage%d_matrix.mat',aiCages(iCageIter));
        load(strCageFile);
        for iMouseA=1:iNumMice
            for iMouseB=1:iNumMice
                if iMouseA == iMouseB
                    continue;
                end;
                fprintf('A = %d, B = %d\n',iMouseA,iMouseB);
                acApproach{iCageIter,iMouseA,iMouseB} = fnDetectApparoach(X,Y,A,B,Theta, iMouseA, iMouseB);
                acFollowing{iCageIter,iMouseA,iMouseB} = fnDetectFollowingMatrix(X,Y,A,B,Theta, iMouseA, iMouseB);
            end
        end
    end
    save('Approach_And_Following','acApproach','acFollowing');
end

a2iCageRemap = [fnGet4x4Remapping(4,3,1,2);
                fnGet4x4Remapping(3,1,2,4);
                fnGet4x4Remapping(1,4,2,3);
                fnGet4x4Remapping(1,3,2,4);
                fnGet4x4Remapping(2,4,1,3);];


%%

iNumFrames = 30*60*60*24*5;
iBlockSizeInFrames = 10 * 60 * 30; % Block is 10 minutes
aiBlockStartFrame = 1:iBlockSizeInFrames:iNumFrames;
iNumBlocks = length(aiBlockStartFrame);
a3fActivity = zeros(iNumCages, 12, iNumBlocks);

for iCageIter=1:5
    Tmp = squeeze(acApproach(iCageIter,:,:));
    acFollowingCage = reshape(Tmp(a2iCageRemap(iCageIter,:)),4,4);
    iCounter=1;
    for iMouseA=1:4
        for iMouseB=1:4
            if iMouseA==iMouseB
                continue;
            end;
            abActivity = fnIntervalsToBinary(acFollowingCage{iMouseA,iMouseB},iNumFrames);
            
            for iBlockIter=1:iNumBlocks
                aiRange = aiBlockStartFrame(iBlockIter):min(iNumFrames,aiBlockStartFrame(iBlockIter)+iBlockSizeInFrames-1);
                a3fActivity(iCageIter,iCounter,iBlockIter) = sum(abActivity(aiRange));
            end
            iCounter=iCounter+1;
            
        end
    end
end

figure(13);clf;
for iCageIter=1:iNumCages
    subplot(2,3,iCageIter);
    A=squeeze(a3fActivity(iCageIter,:,:));
    imagesc(conv2(A,ones(1,10),'same'))
    set(gca,'ytick',1:12,'yticklabel',{'F1<-F2','F1<-M1','F1<-M2','F2<-F1','F2<-M1','F2<-M2','M1<-F1','M1<-F2','M1<-M2','M2<-F1','M2<-F2','M2<-M1'});
    title(sprintf('Cage %d: B approach A',aiCages(iCageIter)));
end


%%
figure(13);
clf;
for iCageIter=1:5
Tmp = squeeze(acFollowing(iCageIter,:,:));
acFollowingCage = reshape(Tmp(a2iCageRemap(iCageIter,:)),4,4);

for iMouseA=1:iNumMice
    for iMouseB=1:iNumMice
        if iMouseA==iMouseB
            continue;
        end;
        a2iNumEvents(iMouseA,iMouseB)= length(acFollowingCage{iMouseA,iMouseB});
        a2iMeanEventLength(iMouseA,iMouseB)= mean(cat(1,acFollowingCage{iMouseA,iMouseB}.m_iLength));
    end
end
subplot(5,2,2*(iCageIter-1)+1);
imagesc(a2iNumEvents,[0 900]);
set(gca,'xtick',1:4,'xticklabel',{'F1','F2','M1','M2'});
set(gca,'ytick',1:4,'yticklabel',{'F1','F2','M1','M2'});

title(sprintf('Cage %d : # Events ',aiCages(iCageIter)));
subplot(5,2,2*(iCageIter-1)+2);
imagesc(a2iMeanEventLength,[0 60]);
title(sprintf('Cage %d : avg event length',aiCages(iCageIter)));
set(gca,'xtick',1:4,'xticklabel',{'F1','F2','M1','M2'});
set(gca,'ytick',1:4,'yticklabel',{'F1','F2','M1','M2'});
end

%% plot approaches
for iCageIter = 1:5
    strCageFile = sprintf('D:\\Data\\Janelia Farm\\ResultsFromNewTrunk\\cage%d_matrix.mat',aiCages(iCageIter));
    load(strCageFile);
    %%
    figure(iCageIter);clf;
    iCounter = 0;
    for iMouseA=1:4
        for iMouseB=1:4
            iCounter=iCounter+1;
            if iMouseA==iMouseB
                continue;
            end;
            
            [Xb, Yb, Ab, Bb, Tb] = fnAlignTrajectoryMatrix(X,Y,A,B,Theta, iMouseA, iMouseB);
            iNumEvents = length(acApproach{iCageIter,iMouseA,iMouseB});
            subplot(4,4,iCounter);
            hold on;
            fnDrawEllipse(gca,0,0,30,15,0,[0 1 0],2,false);
            for iIter=1:iNumEvents
                aiFrames = acApproach{iCageIter,iMouseA,iMouseB}(iIter).m_iStart-50:acApproach{iCageIter,iMouseA,iMouseB}(iIter).m_iStart;
                plot(Xb(aiFrames),Yb(aiFrames));
                plot(Xb(aiFrames(end)),Yb(aiFrames(end)),'r.');
            end
            title(sprintf('Cage %d: %d approach %d',aiCages(iCageIter),iMouseB,iMouseA));
            axis equal
            axis([-400 400 -400 400]);
            drawnow
        end
    end
end


%% plot rose approaches
for iCageIter = 1:5
    strCageFile = sprintf('D:\\Data\\Janelia Farm\\ResultsFromNewTrunk\\cage%d_matrix.mat',aiCages(iCageIter));
    load(strCageFile);
    %%
    figure(iCageIter);clf;
    iCounter = 0;
    for iMouseA=1:4
        for iMouseB=1:4
            iCounter=iCounter+1;
            if iMouseA==iMouseB
                continue;
            end;
            
            [Xb, Yb, Ab, Bb, Tb] = fnAlignTrajectoryMatrix(X,Y,A,B,Theta, iMouseA, iMouseB);
            aiFinish = cat(1,acApproach{iCageIter,iMouseA,iMouseB}.m_iStart);
            tightsubplot(4,4,iCounter);
            h=rose(atan2(Yb(aiFinish),Xb(aiFinish)), linspace(0,2*pi,36));
            set(h,'LineWidth',2)
        end
    end
end
%%

for iMouseA=1:iNumMice
    for iMouseB=1:iNumMice
        if iMouseA == iMouseB
            continue;
        end;
            a2fStayDuration(iMouseA,iMouseB) = mean(cat(1,acApproach{iMouseA,iMouseB}.m_iLength));
    end
end

%%
%  acFollowing(A,B) contains all the detected interval of B following A
% for example:
iMouseA = 1;
iMouseB = 3;
iNumEvents = length(acApproach{iCageIter,iMouseA,iMouseB});
for iEvent = 1:iNumEvents
    strctInterval  = acApproach{iCageIter,iMouseA,iMouseB}(iEvent);  % First encountered interval of Green following red.
    aiFrames = strctInterval.m_iStart-70:strctInterval.m_iStart;
    fnPlayScene2Matrix([], [iMouseA, iMouseB],aiFrames, X,Y,A,B,Theta,0,0);
end

%%
iMouseA = 3;
iMouseB = 4;
iNumEvents = length(acFollowing{iCageIter,iMouseA,iMouseB});
for iEvent = 1:iNumEvents
strctInterval  = acFollowing{iCageIter,iMouseA,iMouseB}(iEvent);  % First encountered interval of Green following red.
aiFrames = strctInterval.m_iStart:strctInterval.m_iEnd;
fnPlayScene2Matrix([], [iMouseA, iMouseB],aiFrames, X,Y,A,B,Theta,0,10);
end

%%
W = 10;
for iCageIter = 1:5
    strCageFile = sprintf('D:\\Data\\Janelia Farm\\ResultsFromNewTrunk\\cage%d_matrix.mat',aiCages(iCageIter));
    load(strCageFile);
figure(iCageIter);clf;
iCounter = 1;    
for iMouseA=1:4
    afRunningPosA = fnRunningMAX(X(:,iMouseA),Y(:,iMouseA),W);
    afRunningAngleA = fnRunningAngle(Theta(:,iMouseA),W);
    abAStationary = afRunningAngleA/pi*180 < 8 & afRunningPosA < 8;
    for iMouseB=iMouseA+1:4
        afRunningPosB = fnRunningMAX(X(:,iMouseB),Y(:,iMouseB),W);
        afRunningAngleB = fnRunningAngle(Theta(:,iMouseB),W);
        aBAStationary = afRunningAngleB/pi*180 < 8 & afRunningPosB < 8;

        [Xb, Yb, Ab, Bb, Tb] = fnAlignTrajectoryMatrix(X,Y,A,B,Theta, iMouseA, iMouseB);
        a2fHist = hist2(Xb(aBAStationary & aBAStationary),Yb(aBAStationary & aBAStationary),-400:400,-400:400);
        tightsubplot(2,3,iCounter);
        iCounter=iCounter+1;
        imagesc(-400:400,-400:400,log10(a2fHist))
        title(sprintf('Cage %d : %d near %d',aiCages(iCageIter),iMouseA,iMouseB));
    end
end
end
