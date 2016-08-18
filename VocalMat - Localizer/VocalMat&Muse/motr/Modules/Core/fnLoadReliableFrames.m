function astrctReliableFrames=fnLoadReliableFrames(strFileName)

strctTmp = load(strFileName);
astrctReliableFrames = strctTmp.astrctReliableFrames;
abValid =  cat(1,astrctReliableFrames.m_bValid) > 0;
astrctReliableFrames = astrctReliableFrames(abValid);

end
