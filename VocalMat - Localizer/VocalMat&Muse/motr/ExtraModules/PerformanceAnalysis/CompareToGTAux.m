function CompareToGTAux(strGTFile, strResultsFile, strResultsViterbiFile)
%%
fprintf('-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\n');
fprintf('-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\n');
fprintf('%s\n',strResultsFile);
fprintf('-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\n');
fprintf('-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\n');

fprintf('Loading...');
strctGT = load(strGTFile);
strctRes = load(strResultsFile); 
strctResViterbi = load(strResultsViterbiFile); 
fprintf('Done!\n');

fPixToCM = 60/630; 
iMouseSizeCM = 80 * fPixToCM;

fprintf('Generating report for %s \n',strctGT.strMovieFileName);
iNumFramesGT = length(strctGT.astrctTrackers(1).m_afX);
iNumFramesRes = length(strctRes.astrctTrackers(1).m_afX);
assert(iNumFramesGT == iNumFramesRes);
iNumFrames = iNumFramesGT;
iNumMice = length(strctGT.astrctTrackers);
% Match 


a2iAssignments = zeros(iNumFrames,iNumMice);
clear strctResMatchedToGT
for iFrameIter=1:iNumFrames
    strctP1 = fnGetTrackersAtFrame(strctRes.astrctTrackers,iFrameIter);
    strctP2 = fnGetTrackersAtFrame(strctGT.astrctTrackers,iFrameIter);
    aiTmp = fnMatchJobToPrevFrame(strctP1,strctP2);
    aiAssignment(aiTmp(1,:)) =aiTmp(2,:);
    a2iAssignments(iFrameIter,:)  = aiAssignment;
    % Meaning, Result(k) was matched to ground truth entry aiAssignment(k)
    for iMouseIter=1:iNumMice
        strctResMatchedToGT.astrctTrackers(aiAssignment(iMouseIter)).m_afX(iFrameIter) = ...
            strctRes.astrctTrackers(iMouseIter).m_afX(iFrameIter);        
        
        strctResMatchedToGT.astrctTrackers(aiAssignment(iMouseIter)).m_afY(iFrameIter) = ...
            strctRes.astrctTrackers(iMouseIter).m_afY(iFrameIter);        
        
        strctResMatchedToGT.astrctTrackers(aiAssignment(iMouseIter)).m_afA(iFrameIter) = ...
            strctRes.astrctTrackers(iMouseIter).m_afA(iFrameIter);        
        
    strctResMatchedToGT.astrctTrackers(aiAssignment(iMouseIter)).m_afB(iFrameIter) = ...
            strctRes.astrctTrackers(iMouseIter).m_afB(iFrameIter);                
        
        strctResMatchedToGT.astrctTrackers(aiAssignment(iMouseIter)).m_afTheta(iFrameIter) = ...
            strctRes.astrctTrackers(iMouseIter).m_afTheta(iFrameIter);                    
        
    end;
end;




%%
a3fDataRes = zeros(5,iNumFrames,iNumMice);
a3fDataResViterbi = zeros(5,iNumFrames,iNumMice);
a3fDataGT = zeros(5,iNumFrames,iNumMice);
for iMouseIter=1:iNumMice
    a3fDataRes(:,:,iMouseIter) = fnArrayStructToMatrix(strctResMatchedToGT.astrctTrackers(iMouseIter));
    a3fDataGT(:,:,iMouseIter) = fnArrayStructToMatrix(strctGT.astrctTrackers(iMouseIter));
    a3fDataResViterbi(:,:,iMouseIter) = fnArrayStructToMatrix(strctResViterbi.astrctTrackers(iMouseIter));
end;

fnOneToOneComparison(a3fDataRes,a3fDataGT);


% Now, performance of Viterbi. If closest ellipse is not the matched one,
% there was probably an identity swap.
a2iAssignments = zeros(iNumFrames,iNumMice);
for iFrameIter=1:iNumFrames
    strctP1 = fnGetTrackersAtFrame(strctResViterbi.astrctTrackers,iFrameIter);
    strctP2 = fnGetTrackersAtFrame(strctGT.astrctTrackers,iFrameIter);
    aiTmp= fnMatchJobToPrevFrame(strctP1,strctP2);
    aiAssignment(aiTmp(1,:)) = aiTmp(2,:);
    a2iAssignments(iFrameIter,:)  = aiAssignment;
end;

for iMouseIter=1:iNumMice
    fprintf('------------------------------\n');
    fprintf('Report statistics for mouse %d\n',iMouseIter);
    abVector = a2iAssignments(:,iMouseIter) ~= iMouseIter;     
    fnPrintIntervalStatistics(abVector, 'Identity swaps');
            
    afTrueX = strctGT.astrctTrackers(iMouseIter).m_afX(abVector);
    afTrueY = strctGT.astrctTrackers(iMouseIter).m_afY(abVector);
    afErrorX = strctResViterbi.astrctTrackers(iMouseIter).m_afX(abVector);
    afErrorY = strctResViterbi.astrctTrackers(iMouseIter).m_afY(abVector);
    afDistanceToCorrectIdentityPix = sqrt((afTrueX-afErrorX).^2 + (afTrueY-afErrorY).^2);
    fprintf('Mean distance to true identity: %.2f cm \n', fPixToCM*mean(afDistanceToCorrectIdentityPix))
    fprintf('Max distance to true identity: %.2f cm \n', fPixToCM*max(afDistanceToCorrectIdentityPix));

    
    
    fprintf('Wrong Identity and far away from true identity : %.2f Sec, reducing error to %.2f%% \n',...
        sum(afDistanceToCorrectIdentityPix * fPixToCM > iMouseSizeCM) / 30,...
        (sum(abVector)-sum(afDistanceToCorrectIdentityPix * fPixToCM > iMouseSizeCM)) / iNumFrames * 100);
end;



%%
% quantify how difficult a sequence is by measuring the percentage of time
% ellipse intersect. Use Ground truth.
a3bIntersect = zeros(iNumMice,iNumMice, iNumFrames);

for iFrameIter=1:iNumFrames
    a3bIntersect(:,:,iFrameIter) = ...
        fnEllipseIntersectionMatrix(strctGT.astrctTrackers, iFrameIter);
end;

fprintf('Intersection analysis (percent intersection from whole sequence)');
round(sum(a3bIntersect,3)/iNumFrames * 100)

aiNumMiceTogether = max(squeeze(sum(a3bIntersect,1)),[],1);

fprintf('No Mice interaction: %.2f \n', 100 * sum(aiNumMiceTogether==0)/iNumFrames);
fprintf('2 Mice interaction: %.2f \n', 100 * sum(aiNumMiceTogether==1)/iNumFrames);
fprintf('3 Mice interaction: %.2f \n', 100 * sum(aiNumMiceTogether==2)/iNumFrames);
fprintf('4 Mice interaction: %.2f \n', 100 * sum(aiNumMiceTogether==3)/iNumFrames);


return;