function [astrctNewEllipses,abLostMice]= ...
  fnFixNewIntersections(astrctNewEllipses, ...
                        abLostMice, ...
                        astrctPredictedEllipses, ...
                        bRecoveredFromBadTracking, ...
                        astrctTrackersHistory, ...
                        a2iFrame, ...
                        strctAppearance)

global g_strctGlobalParam
fLostMouseBigJumpPixels = ...
  g_strctGlobalParam.m_strctTracking.m_fLostMouseBigJumpPixels;
fLoseMouseReductionInImageCorrelation = ...
  g_strctGlobalParam.m_strctTracking.m_fLoseMouseReductionInImageCorrelation;
clear g_strctGlobalParam

a2bIntersectPrev = fnEllipseIntersectionMatrix2(astrctPredictedEllipses);
a2bIntersectNow = fnEllipseIntersectionMatrix2(astrctNewEllipses);

%if max((a2bIntersectNow(:)-a2bIntersectPrev(:))) > 0 && ~bRecoveredFromBadTracking
a2bIntersectionNew=a2bIntersectNow&~a2bIntersectPrev;
if any(a2bIntersectionNew(:)) && ~bRecoveredFromBadTracking
  % New intersection introduced...
  % This typically poses no problem, unless one of the mice actually
  % disappeared and its tracker "jumped" to a near by mouse
  
  % Find the new intersecting mice....
  %[aiA, aiB] = find(triu(a2bIntersectNow)-triu(a2bIntersectPrev )~=0);
  [aiA, aiB] = find(triu(a2bIntersectionNew));
  for iIter=1:length(aiA)
    % aiA(iIter) intersects with aiB
    
    % find the distance travelled here....
    iLastKnownIndexA = find(~isnan(astrctTrackersHistory(aiA(iIter)).m_afX),1,'last');
    iLastKnownIndexB = find(~isnan(astrctTrackersHistory(aiB(iIter)).m_afX),1,'last');
    
    fJumpDistA = hypot(astrctTrackersHistory(aiA(iIter)).m_afX(iLastKnownIndexA)-astrctNewEllipses(aiA(iIter)).m_fX , ...
                       astrctTrackersHistory(aiA(iIter)).m_afY(iLastKnownIndexA)-astrctNewEllipses(aiA(iIter)).m_fY );
    fJumpDistB = hypot(astrctTrackersHistory(aiB(iIter)).m_afX(iLastKnownIndexB)-astrctNewEllipses(aiB(iIter)).m_fX , ...
                       astrctTrackersHistory(aiB(iIter)).m_afY(iLastKnownIndexB)-astrctNewEllipses(aiB(iIter)).m_fY );
    
    if max(fJumpDistA,fJumpDistB) > fLostMouseBigJumpPixels
      % Who jumped?
      if fJumpDistA > fJumpDistB
        iJumperMouse = aiA(iIter);
        iStatMouse = aiB(iIter);
      else
        iJumperMouse = aiB(iIter);
        iStatMouse = aiA(iIter);
      end;
      
      % Lets verify that image-wise, this also makes sense.
      % We will "merge" the two ellipses into one and check the
      % appearance model. If it is better, it means
      fCorr_Stat = fnScoreFunction(a2iFrame, astrctPredictedEllipses(iStatMouse), strctAppearance);
      fCorr_Stat_New = fnScoreFunction(a2iFrame, astrctNewEllipses(iStatMouse), strctAppearance);
      if fCorr_Stat_New - fCorr_Stat < fLoseMouseReductionInImageCorrelation
        % We lost the jumper mouse....
        astrctNewEllipses(iJumperMouse) = fnEllipseNan();
        abLostMice(iJumperMouse) = true;
        fprintf('We probably lost tracker %d since there is a new intersection and a big jump\n',iJumperMouse);
        fnLog(['Probably lost tracker ' num2str(iJumperMouse) ' since there is a new intersection and a big jump']);
      end
      
    end;
  end;
  
end;

end
