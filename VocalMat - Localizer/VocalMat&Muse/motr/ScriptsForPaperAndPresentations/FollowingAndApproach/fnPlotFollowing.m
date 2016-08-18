strctCage1 = load('D:\Data\Janelia Farm\ResultsFromNewTrunk\cage18_matrix.mat');
strctCage2 = load('D:\Data\Janelia Farm\ResultsFromNewTrunk\cage19_matrix.mat');

iNumMice = 4;
acFollowing = cell(iNumMice,iNumMice);
for iMouseA=1:iNumMice
    for iMouseB=1:iNumMice
        if iMouseA == iMouseB
            continue;
        end;
        fprintf('A = %d, B = %d\n',iMouseA,iMouseB);drawnow;
        acFollowing1{iMouseA,iMouseB} = fnDetectFollowingMatrix(strctCage1.X,strctCage1.Y,strctCage1.A,strctCage1.B,strctCage1.Theta, iMouseA, iMouseB);
        acFollowing2{iMouseA,iMouseB} = fnDetectFollowingMatrix(strctCage2.X,strctCage2.Y,strctCage2.A,strctCage2.B,strctCage2.Theta, iMouseA, iMouseB);
        iMin = min(size(strctCage1.X,1),size(strctCage2.X,1));
        X = strctCage1.X(1:iMin,:);
        Y = strctCage1.Y(1:iMin,:);
        A = strctCage1.A(1:iMin,:);
        B = strctCage1.B(1:iMin,:);
        Theta = strctCage1.Theta(1:iMin,:);
        X(1:iMin,iMouseA) = strctCage2.X(1:iMin,iMouseA);
        Y(1:iMin,iMouseA) = strctCage2.Y(1:iMin,iMouseA);
        A(1:iMin,iMouseA) = strctCage2.A(1:iMin,iMouseA);
        B(1:iMin,iMouseA) = strctCage2.B(1:iMin,iMouseA);
        Theta(1:iMin,iMouseA) = strctCage2.Theta(1:iMin,iMouseA);
        % Mouse A is taken from cage 2. Mouse B is from cage 1.
        acFollowingRandom{iMouseA,iMouseB} = fnDetectFollowingMatrix(X,Y,A,B,Theta, iMouseA, iMouseB);
    end
end

%%


%%
%  acFollowing(A,B) contains all the detected interval of B following A
% for example:
iMouseA = 3;
iMouseB = 4;
iEvent = 15;
strctInterval  = acFollowing1{iMouseA,iMouseB}(iEvent);  % First encountered interval of Green following red.
aiFrames = strctInterval.m_iStart:strctInterval.m_iEnd;
fnPlayScene2Matrix([], [iMouseA, iMouseB],aiFrames, strctCage1.X,strctCage1.Y,strctCage1.A,strctCage1.B,strctCage1.Theta,0,60);


%% Analysis of running speed during following
afAllVelA = [];
afAllVelB = [];
aiBountLength = [];
for iMouseA=1:iNumMice
    for iMouseB=1:iNumMice
        if iMouseA == iMouseB
            continue;
        end
        iNumEvents = length(        acFollowing{iMouseA,iMouseB});
        for iEventIter=1:iNumEvents
            aiFrames = acFollowing{iMouseA,iMouseB}(iEventIter).m_iStart:acFollowing{iMouseA,iMouseB}(iEventIter).m_iEnd;
            afVelA = sqrt(diff(X(aiFrames,iMouseA)).^2+diff(Y(aiFrames,iMouseA)).^2);
            afVelB = sqrt(diff(X(aiFrames,iMouseB)).^2+diff(Y(aiFrames,iMouseB)).^2);
            if mean(afVelA) > 30 || mean(afVelB) > 30
                fprintf('A = %d, B = %d, Event = %d\n',iMouseA,iMouseB,iEventIter);
            end;
            afAllVelA = [afAllVelA, mean(afVelA)];
            aiBountLength = [aiBountLength, length(aiFrames)];
        end
    end
end
%%
figure(12);
clf;
hist([afAllVelA],100);
xlabel('Avg. Mouse velocity during bout (pix/frame)');
ylabel('Number of bouts');

figure(13);
clf;
hist(aiBountLength,100)

plot(afAllVelA,aiBountLength,'b.');
