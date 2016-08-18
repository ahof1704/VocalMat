function [aiJobInd, a2iAssignment] = fnChooseJobsToMergeDijkstra(acstrJobFiles, aiBigJumps)
%
[acTrackers, aiFrames, aiLostMice, aiSort] = fnGetEndPointTrackers(acstrJobFiles);
if length(acstrJobFiles)==1
   aiJobInd = 1;
   a2iAssignment = 1:length(acTrackers{1,1});
   return;
end
aiUframes = unique(aiFrames(:, 1));
[A, C, aiProblematicFrames] = fnPrepareAdjacencyAndCostMatices(acTrackers, aiLostMice, aiFrames, aiUframes);

aiStartFrames = sort([1 aiBigJumps aiProblematicFrames max(aiFrames(:,2))]);
aiJobInd = [];
a2iAssignment = [];
for iClipSegment=1:length(aiStartFrames)-1
   aiSeg = find(aiFrames(:,1)>=aiStartFrames(iClipSegment) & aiFrames(:,1)<aiStartFrames(iClipSegment+1));
   if isempty(aiSeg) % SO Added this for the degenrate case when interval is just one frame (happens when we have frame drops)
    aiSeg = find(aiFrames(:,1)>=aiStartFrames(iClipSegment) & aiFrames(:,1)<=aiStartFrames(iClipSegment+1));
   end

   aiJI = fnChooseUsingDijkstra(aiFrames(aiSeg,:), A(aiSeg,aiSeg), C(aiSeg,aiSeg));
   aiJobInd = [aiJobInd; aiSeg(aiJI)];
   a2iAssignment = [a2iAssignment; fnChooseAssignments(acTrackers(aiSeg(aiJI),:))];
end


% Plot Adjaency matrix and Weight matrix
if 0
    %%

[aiKeyFrames, aiI, aiLayer]=unique(aiFrames(:, 1))
iNumLayers = length(aiKeyFrames);
aiNumVerticesInLayer = zeros(1,iNumLayers);
for iLayerIter=1:iNumLayers
   % Plot circle for each hypothesis.
   aiNumVerticesInLayer(iLayerIter) = sum(aiLayer == iLayerIter);
end

figure(100);
clf;
hold on;
afTheta=linspace(0,2*pi,60);
fRadius = 0.3;

% 
% ahHandle(1) = fnFancyPlot2(0:12, afFaceSel, afStdFaceSel, [79,129,189]/255,0.5*[79,129,189]/255);
% ahHandle(2) = fnFancyPlot2(0:12, afNonFaceSel, afStdNonFaceSel, [192,80,77]/255,0.5*[192,80,77]/255);
iNumVertices = length(aiLayer);

% Plot vertices
aiVertexToLayer = zeros(1,iNumVertices);
apt2fVertexCenter = zeros(2,iNumVertices);
iCounter=1;
for iLayerIter=1:iNumLayers
   iNumVerticesInThisLayer = sum(aiLayer == iLayerIter);
   for iVertexIter=1:iNumVerticesInThisLayer
       apt2fVertexCenter(1,iCounter) = iLayerIter;
       apt2fVertexCenter(2,iCounter) = iVertexIter - 1 - floor(aiNumVerticesInLayer(iLayerIter)/2);
        afX = cos(afTheta)*fRadius + apt2fVertexCenter(1,iCounter) ;
        afY = sin(afTheta)*fRadius + apt2fVertexCenter(2,iCounter) ;
        patch(afX,afY,[79,129,189]/255);
        aiVertexToLayer(iCounter) = iLayerIter;
        iCounter=iCounter+1;
   end
end

a2fC = C/max(C(:));
% Plot Connectivity
[aiFrom,aiTo]=find(A);
iNumEdges = length(aiFrom);
fScale=3;
for iEdgeIter=1:iNumEdges
   pt2fFrom = apt2fVertexCenter(:,aiFrom(iEdgeIter));
   pt2fTo = apt2fVertexCenter(:,aiTo(iEdgeIter));
   fEdgeWeight = sqrt( (a2fC(aiFrom(iEdgeIter),aiTo(iEdgeIter))));
   plot([pt2fFrom(1),pt2fTo(1)],[pt2fFrom(2),pt2fTo(2)],'color',[192,80,77]/255 *(1-fEdgeWeight ),'LineWidth',0.05+(1-fEdgeWeight)*fScale);
end
set(gca,'visible','off')
set(gcf,'color',[1 1 1]);
box on
axis equal

% Plot solution

aiSolution = aiJobInd;
for iEdgeIter=1:length(aiSolution)-1
   pt2fFrom = apt2fVertexCenter(:,aiSolution(iEdgeIter));
   pt2fTo = apt2fVertexCenter(:,aiSolution(iEdgeIter+1));
   fEdgeWeight = sqrt((a2fC(aiFrom(iEdgeIter),aiTo(iEdgeIter))));
   plot([pt2fFrom(1),pt2fTo(1)],[pt2fFrom(2),pt2fTo(2)],'color',[80,180,77]/255,'LineWidth',3);
end
%%

end

return;




function aiJobInd = fnChooseUsingDijkstra(aiFrames, A, C)
%
aiUframes = unique(aiFrames(:, 1));
iIntervalsNum = length(aiUframes);
if iIntervalsNum==1
   aiJobInd = 1; % as default, since there's no preference.
   fprintf('Nothing to merge, since all jobs ran the same interval. First job is chosen by default.\n');
   return;
end
aiJobInd = zeros(iIntervalsNum, 1);
iNumJobs = size(aiFrames,1);
SID = find(aiFrames(:,1)==min(aiFrames(:)));
FID = find(aiFrames(:,2)==max(aiFrames(:)));
[costs,paths] = dijkstra(A, C, SID, FID);
if iscell(paths)
    [mc,mi] = min(costs(:));
    aiJobInd = paths{mi};
else
    aiJobInd = paths;
end


function a2iAssignment = fnChooseAssignments(acTrackers)
%
iIntervalsNum = size(acTrackers, 1);
iNumMice = length(acTrackers{1,1});
a2iAssignment = zeros(iIntervalsNum, iNumMice);
a2iAssignment(1,:) = 1:iNumMice;
for i=2:iIntervalsNum
   aiAssignment = fnMatchTrackers(acTrackers{i-1,2}, acTrackers{i,1});
   a2iAssignment(i,:) = aiAssignment(a2iAssignment(i-1,:));
end

function [A, C, aiProblematicFrames] = fnPrepareAdjacencyAndCostMatices(acTrackers, aiLostMice, aiFrames, aiUframes)
%
iNumJobs = size(aiFrames,1);
aiProblematicFrames = [];
A = zeros(iNumJobs);
C = A;
if iNumJobs==0
  return;
end
%aiIndEnd = find(aiFrames(:,2)==aiUframes(2));
aiIndEnd = find(aiFrames(:,1)==aiUframes(1));
for i=2:length(aiUframes)
   aiIndStart = find(aiFrames(:,1)==aiUframes(i));
   A(aiIndEnd, aiIndStart) = 1;
   if length(aiIndEnd) > 1 || length(aiIndStart) > 1
      C(aiIndEnd, aiIndStart) = fnCalcDists(acTrackers(aiIndEnd,2), acTrackers(aiIndStart,1), aiLostMice(aiIndEnd), aiLostMice(aiIndStart));
   else
      C(aiIndEnd, aiIndStart) = 1;
   end
   if all(isnan(C(aiIndEnd, aiIndStart)) | C(aiIndEnd, aiIndStart)>10000)
      aiProblematicFrames = [aiProblematicFrames aiUframes(i)];
   end
   aiIndEnd = aiIndStart;
end


function a2fMatchDist = fnCalcDists(acTrackers1, acTrackers2, aiLostMice1, aiLostMice2)
%
for i=1:length(acTrackers1)
   for j=1:length(acTrackers2)
      [aiAssignment, a2fMatchDist(i,j)] = fnMatchTrackers(acTrackers1{i}, acTrackers2{j});
      iLost = max(0,aiLostMice1(i))+max(0,aiLostMice2(j));
      a2fMatchDist(i,j) = abs(a2fMatchDist(i,j) + 100*(iLost>0) + 4*sqrt(iLost));
   end
end


function [acTrackers, aiFrames, aiLostMice, aiSort] = fnGetEndPointTrackers(acstrJobFiles)
%
iJobsNum = length(acstrJobFiles);
aiFrames = zeros(iJobsNum, 2);  % the first and last frame of each job
acTrackers = cell(iJobsNum, 2);  % the trackers for the first and last frame of each job
aiLostMice = zeros(iJobsNum, 1);
for iJobIter=1:iJobsNum
    strctJob = load(acstrJobFiles{iJobIter});
    aiFrameInterval = strctJob.strctJobInfo.m_aiFrameInterval;
    aiFrames(iJobIter,1) = aiFrameInterval(1);
    aiFrames(iJobIter,2) = aiFrameInterval(end);
    acTrackers{iJobIter,1} = fnGetTrackersAtFrame(strctJob.astrctTrackersJob, 1);
    acTrackers{iJobIter,2} = fnGetTrackersAtFrame(strctJob.astrctTrackersJob, length(aiFrameInterval));
    % If the job struct has an abLostMice field, use it.
    % If not, fall back to the older g_a2bLostMice.
    if isfield(strctJob,'a2bLostMice')
        aiLostMice(iJobIter) = sum(sum(strctJob.a2bLostMice));
    else
        aiLostMice(iJobIter) = sum(sum(strctJob.g_a2bLostMice));
    end
end
[aiFramesStart, aiSort] = sort(aiFrames(:,1));  %#ok
aiFrames = aiFrames(aiSort,:);
acTrackers = acTrackers(aiSort,:);
