function [aiAssignment, fMaxMatchDist] = fnMatchJobToPrevFrame(strctP1, strctP2)
iNumMice = length(strctP1);
a2fCenterDist = fnDist2D(cat(1,strctP1.m_fX),cat(1,strctP1.m_fY),...
    cat(1,strctP2.m_fX),cat(1,strctP2.m_fY));
a2fADist = fnDist1D(cat(1,strctP1.m_fA),cat(1,strctP2.m_fA));
a2fBDist = fnDist1D(cat(1,strctP1.m_fB),cat(1,strctP2.m_fB));
a2fThetaDist = fnDistAngles(cat(1,strctP1.m_fTheta),cat(1,strctP2.m_fTheta));
a2fTotalDist = a2fCenterDist + a2fADist + a2fBDist + 0.1 * a2fThetaDist/pi*180;

a2iAllPerm = fliplr(perms(1:iNumMice));
iNumPerms = size(a2iAllPerm,1);
afPermCost = zeros(1,iNumPerms);
for iPermIter=1:iNumPerms
   % Map strctP1[1,2,3,4] to strctP2[a2iAllPerm(iPermIter,:)]
   aiInd = sub2ind(size(a2fTotalDist), 1:iNumMice, a2iAllPerm(iPermIter,:));
   afPermCost(iPermIter) = sum(a2fTotalDist(aiInd));
end
[fDummy,iMinIndex]= min(afPermCost);
aiAssignment = [1:iNumMice; a2iAllPerm(iMinIndex,:)];
aiInd = sub2ind(size(a2fTotalDist), 1:iNumMice, a2iAllPerm(iMinIndex,:));
fMaxMatchDist = max( a2fCenterDist(aiInd));



% Debugging code
if 0
     
   figure(10);
   clf;
   hold on;
   a2fCol = lines(iNumMice);
   
   for k=1:iNumMice
        fnPlotEllipseStrct(strctP1(k), a2fCol(k,:),2,'-');
        acLeg{k} = sprintf('P1 - %d',k);
   end
   for k=1:iNumMice
        fnPlotEllipseStrct(strctP2(k), 0.5*a2fCol(k,:),2,'--');
        acLeg{iNumMice+k} = sprintf('P2 - %d',k);
   end
        
   legend(acLeg);
  axis ij
  axis equal
  
end
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
