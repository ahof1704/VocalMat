function astrctTrackersJob= ...
  fnAddClassifiersInfo(a3iRectified, strctAdditionalInfo,iOutputIndex, astrctTrackersJob)
global g_strctGlobalParam 
if strcmpi(g_strctGlobalParam.m_strctClassifiers.m_strType,'Tdist')
    astrctTrackersJob=fnAddClassifierInfoTdist(a3iRectified, strctAdditionalInfo,iOutputIndex, astrctTrackersJob);
elseif strcmpi(g_strctGlobalParam.m_strctClassifiers.m_strType,'RobustLDA')
    fnAddClassifierInfoRobustLDA(a3iRectified, strctAdditionalInfo,iOutputIndex);
    if nargout>=1
      astrctTrackersJob=[];
    end
elseif strcmpi(g_strctGlobalParam.m_strctClassifiers.m_strType,'LDA_Logistic')
    fnAddClassifierInfoLogistic(a3iRectified, strctAdditionalInfo,iOutputIndex);
    if nargout>=1
      astrctTrackersJob=[];
    end
else
    fnAddClassifierInfoLDA(a3iRectified, strctAdditionalInfo,iOutputIndex);
    if nargout>=1
      astrctTrackersJob=[];
    end
end

return
