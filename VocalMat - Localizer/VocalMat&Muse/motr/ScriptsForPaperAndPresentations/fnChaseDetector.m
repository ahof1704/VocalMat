 %chase detector
 
 
 strctTemp = load('D:\Data\Janelia Farm\Movies\white mice painted black\Results\Tracks\TestC.mat');
iNumFrames = length( strctTemp.astrctTrackers(1).m_afX);

[acRapidTurnsCCW,acRapidTurnsCW]=fnDetectTurns(strctTemp.astrctTrackers);


fnPlotIntervals([acRapidTurnsCCW,acRapidTurnsCW],{'A CW','B CW','A CCW','B CCW'});
%fnIntervalsToBinary(astrctIntervalsRapidTurnsCCW, iNumFrames);

strctMov = fnReadVideoInfo( 'D:\Data\Janelia Farm\Movies\white mice painted black\TestC.seq');
aiMice=1;
iEvent = 2;
aiFrames = astrctIntervalsRapidTurnsCW(iEvent).m_iStart:astrctIntervalsRapidTurnsCW(iEvent).m_iEnd;
fnPlayScene2(strctMov, aiMice,aiFrames, strctTemp.astrctTrackers,1)



fnPlayScene(