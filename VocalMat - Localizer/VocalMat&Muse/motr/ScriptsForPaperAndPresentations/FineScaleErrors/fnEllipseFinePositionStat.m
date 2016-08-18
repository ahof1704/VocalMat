function [a2fD, abCorrectId, afStdDfine, aiFineFrac, afScaledError] = fnEllipseFinePositionStat()
%%
cd('D:\Code\Janelia Farm\Rev115\ScriptsForPaperAndPresentations\FineScaleErrors');

load HandMadeEllipsesAnu.mat;
astrctEllipseGT1 = strctBackground.m_astrctTuningEllipses;
clear strctBackground;
abValid = [astrctEllipseGT1.m_bValid];
aiFrame = [astrctEllipseGT1.m_iFrame];
astrctEllipses1 = cat(1,astrctEllipseGT1.m_astrctEllipse);

%%
load HandMadeEllipsesAdi1.mat;
astrctEllipseGT2 = strctBackground.m_astrctTuningEllipses;
clear strctBackground;
astrctEllipses2 = cat(1,astrctEllipseGT2.m_astrctEllipse);

abValid = abValid & [astrctEllipseGT2.m_bValid];

%%
load HandMadeEllipsesAdi2.mat;
astrctEllipseGT3 = strctBackground.m_astrctTuningEllipses;
clear strctBackground;
astrctEllipses3 = cat(1,astrctEllipseGT3.m_astrctEllipse);

abValid = abValid & [astrctEllipseGT3.m_bValid];

%%
aiFrame = aiFrame(abValid);
astrctEllipses1 = astrctEllipses1(find(abValid),:);
astrctEllipses2 = astrctEllipses2(find(abValid),:);
astrctEllipses3 = astrctEllipses3(find(abValid),:);

%%
tmp = load('b6_popcage_16_110405_09.58.30.268.mat');
for i=1:size(astrctEllipses1,1)
   for j=1:size(astrctEllipses1,2)
      astrctTrackers(i,j).m_fX = tmp.astrctTrackers(j).m_afX(aiFrame(i));
      astrctTrackers(i,j).m_fY = tmp.astrctTrackers(j).m_afY(aiFrame(i));
      astrctTrackers(i,j).m_fA = tmp.astrctTrackers(j).m_afA(aiFrame(i));
      astrctTrackers(i,j).m_fB = tmp.astrctTrackers(j).m_afB(aiFrame(i));
      astrctTrackers(i,j).m_fTheta = tmp.astrctTrackers(j).m_afTheta(aiFrame(i));
   end
end
clear tmp;

%%
a2fD = [];
abCorrectId = [];
for i=1:size(astrctEllipses1,1)
   [a2fDframe, bCorrectId] = fnMatchTrackers1(astrctEllipses1(i,:), astrctEllipses2(i,:));
   a2fD = [a2fD; a2fDframe];
   abCorrectId = [abCorrectId; bCorrectId];
end

%%
afMD = median(a2fD);
N = size(a2fD,1);
for i=1:size(a2fD,2)
   aiFine = find(abs(a2fD(:,i) - afMD(i)) < 2.5*sqrt(sum((a2fD(:,i) - afMD(i)).^2)/N));
   aiCoarse = find(abs(a2fD(:,i) - afMD(i)) >= 2.5*sqrt(sum((a2fD(:,i) - afMD(i)).^2)/N));
   afStdDfine(i) = sqrt(sum((a2fD(aiFine,i) - afMD(i)).^2)/length(aiFine));
   afStdDcoarse(i) = sqrt(sum((a2fD(aiCoarse,i) - afMD(i)).^2)/length(aiCoarse));
   aiFineFrac(i) = length(aiFine)/N;
end

%%
a2fD = [];
abCorrectId = [];
for i=1:size(astrctEllipses3,1)
   [a2fDframe, bCorrectId] = fnMatchTrackers1(astrctEllipses3(i,:), astrctTrackers(i,:));
   a2fD = [a2fD; a2fDframe];
   abCorrectId = [abCorrectId; bCorrectId];
end

%%
N = size(a2fD,1);
for i=1:size(a2fD,2)
   aiFine = find(abs(a2fD(:,i) - afMD(i)) < 2.5*afStdDfine(i));
   afScaledError(i) = sqrt(sum((a2fD(aiFine,i) - afMD(i)).^2)/length(aiFine))/afStdDfine(i);
   aiFineFrac(i) = length(aiFine)/N;
end


function [a2fD, bCorrectId] = fnMatchTrackers1(strctP1, strctP2)
%
iNumMice = length(strctP1);
a2fCenterDist = fnDist2D1(cat(1,strctP1.m_fX),cat(1,strctP1.m_fY),...
    cat(1,strctP2.m_fX),cat(1,strctP2.m_fY));
a2fADist = fnDist1D1(cat(1,strctP1.m_fA),cat(1,strctP2.m_fA));
a2fBDist = fnDist1D1(cat(1,strctP1.m_fB),cat(1,strctP2.m_fB));
a2fThetaDist = fnDistAngles1(cat(1,strctP1.m_fTheta),cat(1,strctP2.m_fTheta));
a2fTotalDist = a2fCenterDist + a2fADist + a2fBDist + 0.1 * a2fThetaDist/pi*180;

a2iAllPerm = fliplr(perms(1:iNumMice));
iNumPerms = size(a2iAllPerm,1);
afPermCost = zeros(1,iNumPerms);
for iPermIter=1:iNumPerms
   % Map strctP1[1,2,3,4] to strctP2[a2iAllPerm(iPermIter,:)]
   aiInd = sub2ind(size(a2fTotalDist), 1:iNumMice, a2iAllPerm(iPermIter,:));
   afPermCost(iPermIter) = sum(a2fTotalDist(aiInd));
end
[fMatchDist,iMinIndex]= min(afPermCost);
aiAssignment = a2iAllPerm(iMinIndex,:);
bCorrectId = iMinIndex == 1;
s = size(a2fCenterDist);
a2fD(:,1) = a2fCenterDist(sub2ind(s,aiAssignment,1:iNumMice));
a2fD(:,2) = a2fADist(sub2ind(s,aiAssignment,1:iNumMice));
a2fD(:,3) = a2fBDist(sub2ind(s,aiAssignment,1:iNumMice));
a2fD(:,4) = a2fThetaDist(sub2ind(s,aiAssignment,1:iNumMice));


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

function a2fDist = fnDist2D1(afX,afY,afXj,afYj)
N = length(afX);
a2fDist = zeros(N,N);
for i=1:N
    for j=1:N
        a2fDist(i,j) = sqrt( (afX(i)-afXj(j)).^2+(afY(i)-afYj(j)).^2);
    end;
end;
return;

function a2fDist = fnDist1D1(afU,afV)
N = length(afU);
a2fDist = zeros(N,N);
for i=1:N
    for j=1:N
        a2fDist(i,j) = sqrt((afU(i)-afV(j)).^2);
    end;
end;
return;

function a2fDist = fnDistAngles1(afU,afV)
N = length(afU);
a2fDist = zeros(N,N);
for i=1:N
    for j=1:N
        a2fDist(i,j) = fnAngleDist(afU(i),afV(j),180);
    end;
end;
return;
