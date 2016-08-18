%Crop GT 
strMovieFileName = 'C:\Users\Shay\Documents\Data\Janelia Farm\Movies\SeqFiles\10.04.19.390_MergeTestSeq.seq';
strctMovInfo = fnReadVideoInfo(strMovieFileName);
aiCropInterval = 120000:140000;%strctMovInfo.m_iNumFrames;
for k=1:4
    astrctTrackers(k).m_afX = astrctTrackers(k).m_afX(aiCropInterval);
    astrctTrackers(k).m_afY = astrctTrackers(k).m_afY(aiCropInterval);
    astrctTrackers(k).m_afA = astrctTrackers(k).m_afA(aiCropInterval);
    astrctTrackers(k).m_afB = astrctTrackers(k).m_afB(aiCropInterval);
    astrctTrackers(k).m_afTheta = astrctTrackers(k).m_afTheta(aiCropInterval);
    astrctTrackers(k).m_astrctClass = astrctTrackers(k).m_astrctClass(aiCropInterval);
end;
save('Raw_Results','strMovieFileName','strctAdditionalInfo','astrctTrackers')