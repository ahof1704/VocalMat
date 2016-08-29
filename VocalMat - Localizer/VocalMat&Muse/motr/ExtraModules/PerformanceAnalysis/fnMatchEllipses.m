function aiAssignment = fnMatchEllipses(strctP1, strctP2)
% Finds the best match between two sets of four ellipses.
iNumMice = length(strctP1);
a2fCenterDist = fnDist2D(cat(1,strctP1.m_fX),cat(1,strctP1.m_fY),...
    cat(1,strctP2.m_fX),cat(1,strctP2.m_fY));
a2fADist = fnDist1D(cat(1,strctP1.m_fA),cat(1,strctP2.m_fA));
a2fBDist = fnDist1D(cat(1,strctP1.m_fB),cat(1,strctP2.m_fB));
a2fThetaDist = fnDistAngles(cat(1,strctP1.m_fTheta),cat(1,strctP2.m_fTheta));
a2fTotalDist = a2fCenterDist + a2fADist + a2fBDist + a2fThetaDist/pi*180;
% create assignment...
abNotAssignedPrev = ones(1,iNumMice) > 0;
abNotAssignedJob = ones(1,iNumMice) > 0;
aiAssignment = zeros(1,iNumMice);
for k=1:iNumMice
    aiNotAssignedPrev = find(abNotAssignedPrev);
    aiNotAssignedJob = find(abNotAssignedJob);
    [afDummy, aiIndices] = min(a2fTotalDist(aiNotAssignedPrev,aiNotAssignedJob),[],2);
    [fDummy, iIndex] = min(afDummy);
    iSelectedPrev = aiNotAssignedPrev(iIndex);
    iSelectedJob = aiNotAssignedJob(aiIndices(iIndex));
%    aiAssignment(:,k) = [iSelectedPrev;iSelectedJob];
    aiAssignment(iSelectedPrev) = iSelectedJob;
    abNotAssignedPrev(iSelectedPrev) = 0;
    abNotAssignedJob(iSelectedJob) = 0;
end;
return;

function a2fDist = fnDist2D(afX,afY,afXj,afYj)
N = length(afX);
a2fDist = zeros(N,N);
for i=1:N
    for j=1:N
        a2fDist(i,j) = sqrt( (afX(i)-afXj(j)).^2+(afY(i)-afYj(j)).^2);
    end;
end;
return;

function a2fDist = fnDist1D(afU,afV)
N = length(afU);
a2fDist = zeros(N,N);
for i=1:N
    for j=1:N
        a2fDist(i,j) = sqrt((afU(i)-afV(j)).^2);
    end;
end;
return;

function a2fDist = fnDistAngles(afU,afV)
N = length(afU);
a2fDist = zeros(N,N);
for i=1:N
    for j=1:N
        a2fDist(i,j) = fnAngleDist(afU(i),afV(j),180);
    end;
end;
return;
