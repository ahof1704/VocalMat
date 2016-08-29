load('D:\Data\Janelia Farm\ResultsFromNewTrunk\cage18_matrix.mat');

iNumMice = 4;
acFollowing = cell(iNumMice,iNumMice);
for iMouseA=1:iNumMice
    for iMouseB=1:iNumMice
        if iMouseA == iMouseB
            continue;
        end;
        acFollowing{iMouseA,iMouseB} = fnDetectFollowingMatrix(X,Y,A,B,Theta, iMouseA, iMouseB);
    end
end
%%
%  acFollowing(A,B) contains all the detected interval of B following A
% for example:
iMouseA = 2;
iMouseB = 1;
iEvent = 2;
strctInterval  = acFollowing{iMouseA,iMouseB}(iEvent);  % First encountered interval of Green following red.
aiFrames = strctInterval.m_iStart:strctInterval.m_iEnd;
fnPlayScene2Matrix([], [iMouseA, iMouseB],aiFrames, X,Y,A,B,Theta,0);
